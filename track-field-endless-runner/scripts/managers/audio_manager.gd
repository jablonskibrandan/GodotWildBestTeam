class_name GameAudioManager
extends Node


@export var normal_running_audio: AudioStreamPlayer
@export var scary_non_loop: AudioStreamPlayer
@export var scary_loop: AudioStreamPlayer


var music_has_been_stopped: bool = false


func _ready() -> void:
	# Allows explicit audio control while gameplay is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_set_music_to_always_process(normal_running_audio)
	_set_music_to_always_process(scary_non_loop)
	_set_music_to_always_process(scary_loop)

	if scary_non_loop != null:
		if not scary_non_loop.finished.is_connected(
			play_scary_loop
		):
			scary_non_loop.finished.connect(
				play_scary_loop
			)

	music_has_been_stopped = false

	if GameData.has_witnessed_the_horrors:
		if scary_non_loop != null:
			scary_non_loop.play()
	else:
		if normal_running_audio != null:
			normal_running_audio.play()


func _set_music_to_always_process(
	music_player: AudioStreamPlayer
) -> void:
	if music_player == null:
		return

	music_player.process_mode = Node.PROCESS_MODE_ALWAYS


func play_scary_loop() -> void:
	# Prevent the loop from starting after game over.
	if music_has_been_stopped:
		return

	if scary_loop != null:
		scary_loop.play()


func stop_all_music() -> void:
	music_has_been_stopped = true

	if normal_running_audio != null:
		normal_running_audio.stop()

	if scary_non_loop != null:
		scary_non_loop.stop()

	if scary_loop != null:
		scary_loop.stop()
