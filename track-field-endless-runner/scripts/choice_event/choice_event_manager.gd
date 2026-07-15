class_name ChoiceEventManager
extends Node

# Causes choices to happen every x seconds, starting off with a first choice
# then later choices, it takes longer
@export var choice_event_scene: PackedScene

@export_category("Choice Timing")
@export var first_choice_min_time: float = 35.0
@export var first_choice_max_time: float = 45.0

@export var later_choice_min_time: float = 55.0
@export var later_choice_max_time: float = 70.0

# In case we figure out we need to limit them.
@export var maximum_choices: int = 5

@onready var choice_timer: Timer = $ChoiceTimer

var choices_shown: int = 0
var choice_active: bool = false
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	choice_timer.one_shot = true
	choice_timer.timeout.connect(_on_choice_timer_timeout)

	_schedule_next_choice()


func _schedule_next_choice() -> void:
	if choices_shown >= maximum_choices:
		return

	var wait_time: float

	if choices_shown == 0:
		wait_time = rng.randf_range(
			first_choice_min_time,
			first_choice_max_time
		)
	else:
		wait_time = rng.randf_range(
			later_choice_min_time,
			later_choice_max_time
		)

	choice_timer.start(wait_time)


func _on_choice_timer_timeout() -> void:
	if choice_active:
		return

	_show_choice()


func _show_choice() -> void:
	if choice_event_scene == null:
		push_error("No choice event scene assigned.")
		return

	var choice_event := choice_event_scene.instantiate() as ChoiceEvent

	if choice_event == null:
		push_error("Choice scene must inherit from ChoiceEvent.")
		return

	choice_active = true
	choices_shown += 1

	add_child(choice_event)

	choice_event.choice_finished.connect(
		_on_choice_finished,
		CONNECT_ONE_SHOT
	)


func _on_choice_finished(accepted: bool, timed_out: bool) -> void:
	choice_active = false

	if accepted:
		print("Choice accepted")
	elif timed_out:
		print("Choice timed out")
	else:
		print("Choice denied")

	_schedule_next_choice()
