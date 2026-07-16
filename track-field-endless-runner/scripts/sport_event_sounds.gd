extends AudioStreamPlayer

@export var gunshot: AudioStreamMP3
@export var javelin_throw: AudioStreamMP3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioSignalBus.play_gunshot.connect(_on_play_gunshot)
	AudioSignalBus.play_javelin_throw.connect(_on_play_javeling_throw)

func _on_play_gunshot() -> void:
	stream = gunshot
	play()

func _on_play_javeling_throw() -> void:
	stream = javelin_throw
	play()
