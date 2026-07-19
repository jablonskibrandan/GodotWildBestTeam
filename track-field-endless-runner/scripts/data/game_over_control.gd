class_name GameOverControl
extends Control


@export_file("*.tscn")
var main_menu_scene: String = "res://scenes/main_menu.tscn"

@export_category("Transition Timing")
@export_range(0.0, 3.0, 0.05)
var fade_to_black_duration: float = 0.75

@export_range(0.0, 3.0, 0.05)
var image_fade_duration: float = 1.0

@export_range(0.0, 3.0, 0.05)
var text_fade_duration: float = 0.5

@export var death_scream: AudioStreamPlayer
@export var black_fade: ColorRect 
@export var death_image: TextureRect 
@export var text_root: Control 

@export var score_label: Label 


var game_over_active: bool = false
var transition_finished: bool = false
var game_over_tween: Tween


func _ready() -> void:
	# Allows the game-over screen and R input to work
	# while the rest of the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false
	_reset_visuals()


func show_game_over(final_score: int) -> void:
	death_scream.play()
	if game_over_active:
		return

	game_over_active = true
	transition_finished = false

	score_label.text = "FINAL SCORE: %d" % final_score

	_reset_visuals()

	visible = true
	move_to_front()

	# Pause gameplay immediately.
	get_tree().paused = true

	if game_over_tween != null:
		game_over_tween.kill()

	game_over_tween = create_tween()

	# Continue the transition while the scene tree is paused.
	game_over_tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	# First fade the gameplay to black.
	game_over_tween.tween_property(
		black_fade,
		"modulate:a",
		1.0,
		fade_to_black_duration
	)

	# Then fade the death image into the black screen.
	game_over_tween.tween_property(
		death_image,
		"modulate:a",
		1.0,
		image_fade_duration
	)

	# Finally reveal the game-over text.
	game_over_tween.tween_property(
		text_root,
		"modulate:a",
		1.0,
		text_fade_duration
	)

	game_over_tween.finished.connect(
		_on_game_over_transition_finished
	)


func _reset_visuals() -> void:
	if black_fade != null:
		black_fade.modulate.a = 0.0

	if death_image != null:
		death_image.modulate.a = 0.0

	if text_root != null:
		text_root.modulate.a = 0.0


func _on_game_over_transition_finished() -> void:
	transition_finished = true


func _input(event: InputEvent) -> void:
	if not game_over_active:
		return

	if not transition_finished:
		return

	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_R
	):
		_return_to_main_menu()


func _return_to_main_menu() -> void:
	game_over_active = false

	if game_over_tween != null:
		game_over_tween.kill()

	get_tree().paused = false

	# Prevent the next run from immediately starting
	# in the game-over state.
	GameData.loss_amount = 0

	get_tree().change_scene_to_file(
		main_menu_scene
	)
