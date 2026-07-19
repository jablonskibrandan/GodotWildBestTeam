class_name ChoiceEventManager
extends Node


@export_category("Choice Events")
@export var choice_event: ChoiceEvent
@export var possible_choices: Array[ChoiceEventData] = []

@export_category("Choice Timing")
@export_range(0.0, 10.0, 0.25)
var choice_show_delay: float = 8.0

@export_category("Effect Processing")
@export var choice_effect_processor: ChoiceEffectManager

var choices_shown: int = 0
var choice_active: bool = false
var choice_pending: bool = false

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	if choice_event == null:
		push_error("No ChoiceEvent node assigned.")
	else:
		choice_event.hide()

		if not choice_event.choice_finished.is_connected(
			_on_choice_finished
		):
			choice_event.choice_finished.connect(
				_on_choice_finished
			)

	if not SportEventSignalBus.finish_event.is_connected(
		_on_sport_event_finished
	):
		SportEventSignalBus.finish_event.connect(
			_on_sport_event_finished
		)


func _on_sport_event_finished() -> void:
	if choice_active or choice_pending:
		return

	choice_pending = true

	await get_tree().create_timer(
		choice_show_delay
	).timeout

	choice_pending = false

	if choice_active:
		return

	_show_random_choice()


func _show_random_choice() -> void:
	if choice_event == null:
		push_error("No ChoiceEvent node assigned.")
		return

	var valid_choices := _get_valid_choices()

	if valid_choices.is_empty():
		push_error(
			"No valid ChoiceEventData resources assigned."
		)
		return

	var selected_data: ChoiceEventData = (
		valid_choices.pick_random()
	)

	choice_active = true
	choices_shown += 1

	choice_event.show_choice(selected_data)


func _get_valid_choices() -> Array[ChoiceEventData]:
	var valid_choices: Array[ChoiceEventData] = []

	for choice_data in possible_choices:
		if choice_data != null:
			valid_choices.append(choice_data)

	return valid_choices


func _on_choice_finished(
	selected_option: ChoiceOptionData,
	timed_out: bool
) -> void:
	choice_active = false

	if timed_out:
		print("Choice timed out")
		return

	if selected_option == null:
		push_warning("No choice option was selected.")
		return

	print(
		"Selected option: ",
		selected_option.option_text
	)

	_apply_choice_option(selected_option)


func _apply_choice_option(
	option: ChoiceOptionData
) -> void:
	if option == null:
		return

	if choice_effect_processor == null:
		push_error(
			"No ChoiceEffectManager assigned."
		)
		return

	choice_effect_processor.apply_option(option)
