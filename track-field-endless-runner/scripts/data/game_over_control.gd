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


@export_category("Game Over Audio")
@export var audio_manager: GameAudioManager
@export var death_scream: AudioStreamPlayer
@export var knock_knock_sound: AudioStreamPlayer

# Delay measured from the beginning of the game-over sequence.
@export_range(0.0, 10.0, 0.1)
var knock_knock_delay: float = 3.0


@export_category("UI References")
@export var black_fade: ColorRect
@export var death_image: TextureRect
@export var text_root: Control
@export var score_label: Label


var game_over_active: bool = false
var transition_finished: bool = false
var game_over_tween: Tween


func _ready() -> void:
	# Allows the game-over screen, timer, audio and R input
	# to continue while gameplay is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false
	_reset_visuals()

	if death_scream != null:
		death_scream.process_mode = Node.PROCESS_MODE_ALWAYS

	if knock_knock_sound != null:
		knock_knock_sound.process_mode = Node.PROCESS_MODE_ALWAYS


func show_game_over(final_score: int) -> void:
	if game_over_active:
		return

	game_over_active = true
	transition_finished = false

	_stop_gameplay_music()
	_play_death_scream()

	if score_label != null:
		score_label.text = (
			"FINAL SCORE: %d" % final_score
		)

	_reset_visuals()

	visible = true
	move_to_front()

	# Gameplay stops, but this node continues because its
	# process mode is Always.
	get_tree().paused = true

	# Starts the delayed sound without delaying the visual
	# transition below.
	_play_knock_knock_after_delay()

	if game_over_tween != null:
		game_over_tween.kill()

	game_over_tween = create_tween()

	game_over_tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	game_over_tween.tween_property(
		black_fade,
		"modulate:a",
		1.0,
		fade_to_black_duration
	)

	game_over_tween.tween_property(
		death_image,
		"modulate:a",
		1.0,
		image_fade_duration
	)

	game_over_tween.tween_property(
		text_root,
		"modulate:a",
		1.0,
		text_fade_duration
	)

	game_over_tween.finished.connect(
		_on_game_over_transition_finished
	)


func _stop_gameplay_music() -> void:
	if audio_manager == null:
		push_warning(
			"GameOverControl has no AudioManager assigned."
		)
		return

	audio_manager.stop_all_music()


func _play_death_scream() -> void:
	if death_scream == null:
		push_warning(
			"GameOverControl has no death scream assigned."
		)
		return

	death_scream.play()


func _play_knock_knock_after_delay() -> void:
	await get_tree().create_timer(
		knock_knock_delay,
		true
	).timeout

	# Prevent the delayed sound from playing after the
	# game-over screen has already been exited.
	if not game_over_active:
		return

	if knock_knock_sound == null:
		push_warning(
			"GameOverControl has no knock-knock sound assigned."
		)
		return

	knock_knock_sound.play()


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

	if death_scream != null:
		death_scream.stop()

	if knock_knock_sound != null:
		knock_knock_sound.stop()

	get_tree().paused = false

	GameData.loss_amount = 0

	get_tree().change_scene_to_file(
		main_menu_scene
	)
