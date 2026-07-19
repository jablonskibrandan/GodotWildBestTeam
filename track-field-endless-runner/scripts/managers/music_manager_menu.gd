extends Node
# In the interest of time, this is how I'm doing it.
# Given more time, I would have implemented this in a different way.
@export var normal_music: AudioStreamPlayer
@export var scary_music_first: AudioStreamPlayer
@export var scary_music_loop: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	scary_music_first.finished.connect(_on_scary_intro_finished)
	if GameData.should_resume_music and GameData.scary_music_non_loop_playing:
		scary_music_first.play(
			GameData.music_playback_position
		)

		GameData.should_resume_music = false
		GameData.scary_music_non_loop_playing = false
		GameData.music_playback_position = 0.0
	elif GameData.should_resume_music and GameData.scary_music_loop_playing:
		scary_music_loop.play(
			GameData.music_playback_position
		)

		GameData.should_resume_music = false
		GameData.scary_music_loop_playing = false
		GameData.music_playback_position = 0.0
	else:
		normal_music.play()

func _on_scary_intro_finished() -> void:
	scary_music_loop.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
