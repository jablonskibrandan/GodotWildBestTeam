extends Node

@export var player_time_display: RichTextLabel
@export var player: Player

var starting_distance: float = 0.0
var race_length: float = 0.0
var finish_distance: float = 0.0
var time: float = 0.0
var event_in_progress: bool = false

func _ready() -> void:
	SportEventSignalBus.countdown_finished.connect(_on_countdown_finished)

func _process(delta: float) -> void:
	time = time + delta
	if event_in_progress == true:
		player_time_display.text = str("%0.2f" % time)
		if player.distance_travelled >= finish_distance:
			finish_event()
	
func _on_countdown_finished() -> void:
	event_in_progress = true

func finish_event() -> void:
	event_in_progress = false
	SportEventSignalBus.finish_event.emit()
