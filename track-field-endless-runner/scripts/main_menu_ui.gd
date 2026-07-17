extends Control

@export_file("*.tscn") var game_scene_path: String

@export var start_button: Button
@export var quit_button: Button

@export_category("Button Sounds")
@export var hover_sound: AudioStreamPlayer
@export var click_sound: AudioStreamPlayer

@export_category("Button Colors")
@export var blink_interval: float = 0.15
@export var normal_color: Color = Color.WHITE
@export var blink_color: Color = Color.YELLOW
@onready var normal_menu_music: AudioStreamPlayer = $NormalMenuMusic
@onready var scary_menu_music_first_play:  AudioStreamPlayer = $ScaryMusicIntroNonLoop
@onready var scary_menu_music_looping: AudioStreamPlayer = $ScaryMusicIntroLoop

var hovered_button: Button
var showing_blink_color: bool = false
var blink_timer: Timer

@export var screen_fade: ScreenFade


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	_setup_button(start_button)
	_setup_button(quit_button)

	blink_timer = Timer.new()
	blink_timer.wait_time = blink_interval
	blink_timer.one_shot = false
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	add_child(blink_timer)
	
	scary_menu_music_first_play.finished.connect(_on_scary_intro_finished)
	
	if GameData.has_witnessed_the_horrors:
		scary_menu_music_first_play.play()
	else:
		normal_menu_music.play()
		
		


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
	_play_hover_sound()

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


func _play_hover_sound() -> void:
	if not is_instance_valid(hover_sound):
		return

	if hover_sound.stream == null:
		return

	hover_sound.stop()
	hover_sound.play()


func _play_click_sound() -> void:
	if not is_instance_valid(click_sound):
		return

	if click_sound.stream == null:
		return

	click_sound.stop()
	click_sound.play()

	# Wait so the sound is not destroyed immediately when changing scenes.
	await click_sound.finished
	
func _on_scary_intro_finished() -> void:
	scary_menu_music_looping.play()


func _on_start_button_pressed() -> void:
	start_button.disabled = true
	quit_button.disabled = true

	await _play_click_sound()
	_start_game()


func _on_quit_button_pressed() -> void:
	start_button.disabled = true
	quit_button.disabled = true

	await _play_click_sound()
	_quit_game()


func _start_game() -> void:
	if game_scene_path.is_empty():
		push_error("No game scene path assigned on main_menu.")

		start_button.disabled = false
		quit_button.disabled = false
		return

	get_tree().change_scene_to_file(game_scene_path)


func _quit_game() -> void:
	get_tree().quit()
