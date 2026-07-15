extends Control
class_name DialogueControl

signal dialogue_finished


@export_category("Dialogue")

## Each element is a separate dialogue entry.
## Increase the array size in the Inspector to add more entries.
@export var dialogue_lines: Array[String] = []

## Starts the dialogue automatically when the scene loads.
@export var start_automatically: bool = true


@export_category("Nodes")
@export var dialogue_text: RichTextLabel
@export var continue_indicator: Control
@export var type_timer: Timer


@export_category("Typing")

## Base delay between each displayed character.
@export_range(0.005, 0.25, 0.005)
var character_delay: float = 0.035

## Additional pause after commas, semicolons, and colons.
@export_range(0.0, 1.0, 0.01)
var comma_pause: float = 0.08

## Additional pause after periods, exclamation marks, and question marks.
@export_range(0.0, 1.0, 0.01)
var sentence_pause: float = 0.18


@export_category("Input")

## Input Map action used to reveal or advance dialogue.
@export var advance_action: StringName = &"advance_dialogue"


## Contains the final pages after each Inspector entry has been measured.
## A long dialogue entry may be split into multiple fitting pages.
var _pages: Array[String] = []

var _current_page_index: int = -1
var _current_page_text: String = ""

var _is_typing: bool = false
var _is_active: bool = false
var _is_preparing: bool = false


func _ready() -> void:
	hide()

	if not _validate_nodes():
		return

	type_timer.one_shot = true
	type_timer.timeout.connect(_on_type_timer_timeout)

	continue_indicator.hide()

	if start_automatically:
		call_deferred("_start_dialogue")


func _validate_nodes() -> bool:
	if not is_instance_valid(dialogue_text):
		push_error(
			"DialogueControl: Dialogue Text has not been assigned."
		)
		return false

	if not is_instance_valid(continue_indicator):
		push_error(
			"DialogueControl: Continue Indicator has not been assigned."
		)
		return false

	if not is_instance_valid(type_timer):
		push_error(
			"DialogueControl: Type Timer has not been assigned."
		)
		return false

	return true


## Starts or restarts the dialogue entered in the Inspector.
func _start_dialogue() -> void:
	if dialogue_lines.is_empty():
		push_warning(
			"DialogueControl: No dialogue lines were entered."
		)
		return

	if _is_active or _is_preparing:
		return

	_is_preparing = true
	_is_active = true
	_is_typing = false

	_pages.clear()
	_current_page_index = -1
	_current_page_text = ""

	show()
	continue_indicator.hide()

	# Temporarily hide the text while Godot measures each entry.
	dialogue_text.modulate.a = 0.0

	for entry: String in dialogue_lines:
		var cleaned_entry := entry.strip_edges()

		if cleaned_entry.is_empty():
			continue

		var entry_pages: Array[String] = await _create_pages(
			cleaned_entry
		)

		_pages.append_array(entry_pages)

	dialogue_text.modulate.a = 1.0
	_is_preparing = false

	if _pages.is_empty():
		_end_dialogue()
		return

	_show_next_page()


## Measures one inspector entry and splits it into fitting pages if needed.
func _create_pages(source_text: String) -> Array[String]:
	var created_pages: Array[String] = []
	var cleaned_text := source_text.strip_edges()

	if cleaned_text.is_empty():
		return created_pages

	## Place the complete entry in the label so Godot can wrap it.
	dialogue_text.text = cleaned_text
	dialogue_text.visible_characters = -1
	dialogue_text.scroll_to_line(0)

	## Wait for the RichTextLabel to calculate its wrapped lines.
	await get_tree().process_frame
	await get_tree().process_frame

	var total_lines := dialogue_text.get_line_count()

	var lines_per_page := maxi(
		1,
		dialogue_text.get_visible_line_count()
	)

	if total_lines <= lines_per_page:
		created_pages.append(cleaned_text)
		return created_pages

	var first_character: int = 0
	var first_line: int = 0

	while first_line < total_lines:
		var last_line := mini(
			first_line + lines_per_page - 1,
			total_lines - 1
		)

		var line_range := dialogue_text.get_line_range(last_line)

		# get_line_range() returns an inclusive final character index.
		var last_character_exclusive: int = line_range.y + 1

		var page_length: int = (
			last_character_exclusive - first_character
		)

		var page_text := cleaned_text.substr(
			first_character,
			page_length
		).strip_edges()

		if not page_text.is_empty():
			created_pages.append(page_text)

		first_character = last_character_exclusive

		# Prevent the next page from beginning with whitespace.
		while (
			first_character < cleaned_text.length()
			and _is_whitespace(
				cleaned_text.substr(first_character, 1)
			)
		):
			first_character += 1

		first_line = last_line + 1

	# Catch any remaining text not included in a visible line.
	if first_character < cleaned_text.length():
		var remainder := cleaned_text.substr(
			first_character
		).strip_edges()

		if not remainder.is_empty():
			created_pages.append(remainder)

	return created_pages


func _show_next_page() -> void:
	type_timer.stop()
	continue_indicator.hide()

	_current_page_index += 1

	if _current_page_index >= _pages.size():
		_end_dialogue()
		return

	_current_page_text = _pages[_current_page_index]

	dialogue_text.text = _current_page_text
	dialogue_text.visible_characters = 0
	dialogue_text.scroll_to_line(0)

	_is_typing = true

	# Display the first character immediately.
	_reveal_next_character()


func _reveal_next_character() -> void:
	var total_characters := (
		dialogue_text.get_total_character_count()
	)

	if dialogue_text.visible_characters >= total_characters:
		_finish_typing_page()
		return

	dialogue_text.visible_characters += 1

	var character_index := (
		dialogue_text.visible_characters - 1
	)

	var character := _current_page_text.substr(
		character_index,
		1
	)

	var delay := _get_character_delay(character)
	type_timer.start(delay)


func _on_type_timer_timeout() -> void:
	_reveal_next_character()


func _get_character_delay(character: String) -> float:
	match character:
		".", "!", "?":
			return character_delay + sentence_pause

		",", ";", ":":
			return character_delay + comma_pause

		_:
			return character_delay


func _finish_typing_page() -> void:
	type_timer.stop()

	# Reveal all remaining characters immediately.
	dialogue_text.visible_characters = -1

	_is_typing = false
	continue_indicator.show()


func _advance_dialogue() -> void:
	if _is_preparing:
		return

	if _is_typing:
		# The first press reveals the entire current page.
		_finish_typing_page()
	else:
		# The next press moves to the next page.
		_show_next_page()


func _end_dialogue() -> void:
	type_timer.stop()

	_is_active = false
	_is_typing = false
	_is_preparing = false

	_pages.clear()
	_current_page_index = -1
	_current_page_text = ""

	continue_indicator.hide()

	dialogue_text.text = ""
	dialogue_text.visible_characters = -1

	hide()

	dialogue_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return

	if event.is_action_pressed(advance_action):
		_advance_dialogue()
		get_viewport().set_input_as_handled()


func _is_whitespace(character: String) -> bool:
	return (
		character == " "
		or character == "\n"
		or character == "\r"
		or character == "\t"
	)
