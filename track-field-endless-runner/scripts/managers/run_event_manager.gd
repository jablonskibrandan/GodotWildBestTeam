extends Node

@export var player_time_display: RichTextLabel
@export var player: Player
@export var audio_controller: AudioStreamPlayer

var starting_distance: float = 0.0
var race_length: float = 0.0
var finish_distance: float = 0.0
var time: float = 0.0
var event_in_progress: bool = false
var count_time: bool = false

func _ready() -> void:
	SportEventSignalBus.start_line_passed.connect(_on_start_line_passed)
	SportEventSignalBus.finish_event.connect(_on_finish_event)

func _process(delta: float) -> void:
	time = time + delta
	if event_in_progress == true and count_time == true:
		player_time_display.text = str("%0.2f" % time)
	
func _on_start_line_passed() -> void:
	if event_in_progress == true:
		AudioSignalBus.play_gunshot.emit()
		count_time = true

func _on_finish_event() -> void:
	count_time = false
