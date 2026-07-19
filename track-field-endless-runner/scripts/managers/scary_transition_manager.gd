extends Node
@export var tutorial_manager : TutorialManager
@export var static_audio: AudioStreamPlayer
@export var normal_audio: AudioStreamPlayer
@export_file("*.tscn")
var running_scene: String = "res://scenes/running_scene.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_manager.scary_transition.connect(_do_scary_stuff)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _do_scary_stuff() -> void: 
	print("got to scary transition")
	GameData.has_witnessed_the_horrors = true 
	normal_audio.stop()
	await get_tree().create_timer(2.0).timeout
	static_audio.play()
	await get_tree().create_timer(10.0).timeout
	
	
	get_tree().change_scene_to_file(
		running_scene
	)
	
	
