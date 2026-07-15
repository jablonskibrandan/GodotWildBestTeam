class_name ObstacleSpawner
extends Node2D

@export_category("Obstacle Scenes")
@export var hurdle_scene: PackedScene
@export var mud_puddle_scene: PackedScene

# Three phases: (possibly?) easy (at the beginning), medium, hard
@export_category("Spawn Timing")
@export var phase_one_end: float = 60.0
@export var phase_two_end: float = 150.0

@export var phase_one_min_time: float = 3.5
@export var phase_one_max_time: float = 4.5

@export var phase_two_min_time: float = 2.5
@export var phase_two_max_time: float = 3.5

@export var phase_three_min_time: float = 1.8
@export var phase_three_max_time: float = 2.8

@export_category("Obstacle Chances")
@export_range(0.0, 1.0, 0.05) var early_mud_chance: float = 0.25
@export_range(0.0, 1.0, 0.05) var middle_mud_chance: float = 0.35
@export_range(0.0, 1.0, 0.05) var late_mud_chance: float = 0.45

@export_category("Spawn Location")
@export var obstacle_parent: Node

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_point: Marker2D = $SpawnPoint

var elapsed_time: float = 0.0
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	_schedule_next_obstacle()


func _process(delta: float) -> void:
	elapsed_time += delta


func _on_spawn_timer_timeout() -> void:
	_spawn_obstacle()
	_schedule_next_obstacle()


func _schedule_next_obstacle() -> void:
	var wait_time := _get_next_spawn_time()
	spawn_timer.start(wait_time)


func _get_next_spawn_time() -> float:
	if elapsed_time < phase_one_end:
		return rng.randf_range(
			phase_one_min_time,
			phase_one_max_time
		)

	if elapsed_time < phase_two_end:
		return rng.randf_range(
			phase_two_min_time,
			phase_two_max_time
		)

	return rng.randf_range(
		phase_three_min_time,
		phase_three_max_time
	)


func _spawn_obstacle() -> void:
	var obstacle_scene := _choose_obstacle_scene()

	if obstacle_scene == null:
		push_error("ObstacleSpawner is missing an obstacle scene.")
		return

	var obstacle := obstacle_scene.instantiate() as Node2D

	if obstacle == null:
		push_error("Obstacle scenes must have a Node2D root.")
		return

	var parent := obstacle_parent

	if parent == null:
		parent = get_tree().current_scene

	parent.add_child(obstacle)
	obstacle.global_position = spawn_point.global_position


func _choose_obstacle_scene() -> PackedScene:
	var mud_chance := _get_mud_chance()

	if rng.randf() < mud_chance:
		return mud_puddle_scene

	return hurdle_scene


func _get_mud_chance() -> float:
	if elapsed_time < phase_one_end:
		return early_mud_chance

	if elapsed_time < phase_two_end:
		return middle_mud_chance

	return late_mud_chance
