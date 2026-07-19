extends Node


@export var normal_running_audio: AudioStreamPlayer
@export var scary_non_loop: AudioStreamPlayer
@export var scary_loop: AudioStreamPlayer


func _ready() -> void:
	# Keep this manager processing while the game is paused.
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
	if scary_loop != null:
		scary_loop.play()
