extends Control

@export_file("*.tscn") var game_scene_path: String

@export var start_button: Button
@export var quit_button: Button

@export var blink_interval: float = 0.15
@export var normal_color: Color = Color.WHITE
@export var blink_color: Color = Color.YELLOW

var hovered_button: Button
var showing_blink_color: bool = false
var blink_timer: Timer


func _ready() -> void:
	start_button.pressed.connect(_start_game)
	quit_button.pressed.connect(_quit_game)

	_setup_button(start_button)
	_setup_button(quit_button)

	blink_timer = Timer.new()
	blink_timer.wait_time = blink_interval
	blink_timer.one_shot = false
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	add_child(blink_timer)


func _setup_button(button: Button) -> void:
	button.flat = true

	button.add_theme_color_override("font_color", normal_color)
	button.add_theme_color_override("font_hover_color", normal_color)
	button.add_theme_color_override("font_pressed_color", blink_color)

	button.mouse_entered.connect(
		_on_button_mouse_entered.bind(button)
	)

	button.mouse_exited.connect(
		_on_button_mouse_exited.bind(button)
	)


func _on_button_mouse_entered(button: Button) -> void:
	_reset_hovered_button()

	hovered_button = button
	showing_blink_color = true

	_set_button_hover_color(button, blink_color)

	blink_timer.wait_time = blink_interval
	blink_timer.start()


func _on_button_mouse_exited(button: Button) -> void:
	if hovered_button != button:
		return

	blink_timer.stop()
	_set_button_hover_color(button, normal_color)

	hovered_button = null
	showing_blink_color = false


func _on_blink_timer_timeout() -> void:
	if not is_instance_valid(hovered_button):
		blink_timer.stop()
		return

	showing_blink_color = not showing_blink_color

	var color := blink_color if showing_blink_color else normal_color
	_set_button_hover_color(hovered_button, color)


func _set_button_hover_color(button: Button, color: Color) -> void:
	button.add_theme_color_override("font_hover_color", color)


func _reset_hovered_button() -> void:
	if is_instance_valid(hovered_button):
		_set_button_hover_color(hovered_button, normal_color)

	hovered_button = null


func _start_game() -> void:
	if game_scene_path.is_empty():
		push_error("No game scene path assigned on MainMenu.")
		return

	get_tree().change_scene_to_file(game_scene_path)


func _quit_game() -> void:
	get_tree().quit()
