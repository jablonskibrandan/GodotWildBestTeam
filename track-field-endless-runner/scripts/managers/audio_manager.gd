extends Node

@export var normal_running_audio: AudioStreamPlayer
@export var scary_non_loop: AudioStreamPlayer
@export var scary_loop: AudioStreamPlayer

# For the running scene.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if scary_loop == null:
		return
	
	if scary_non_loop == null:
		return 
	
	if normal_running_audio == null:
		return
	
	scary_non_loop.finished.connect(play_scary_loop)
	
	if GameData.has_witnessed_the_horrors: 
		scary_non_loop.play()
	else: 
		normal_running_audio.play()

func play_scary_loop() -> void:
	scary_loop.play()
