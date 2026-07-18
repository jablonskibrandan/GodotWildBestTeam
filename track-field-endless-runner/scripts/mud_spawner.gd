class_name MudSpawner
extends Node2D


@export_category("Required References")
@export var player: Player
@export var sports_event_manager: Node
@export var mud_parent: Node2D
@export var mud_scene: PackedScene

@export_category("First Spawn Timing")
@export var minimum_first_spawn_delay: float = 3.0
@export var maximum_first_spawn_delay: float = 6.0

@export_category("Spawn Timing")
# Mud will attempt to spawn somewhere in this time range.
@export var minimum_spawn_delay: float = 10.0
@export var maximum_spawn_delay: float = 16.0


# Even when the timer finishes, mud does not always spawn.
# This makes placement less predictable and more sparse.
@export_range(0.0, 1.0, 0.05)
var base_spawn_chance: float = 0.65

@export_category("Spawn Limits")
# Prevent several mud puddles from appearing simultaneously.
@export_range(1, 10, 1)
var maximum_active_mud: int = 1

# Prevent two puddles from spawning close together.
@export var minimum_mud_spacing: float = 700.0

@export_category("Spawn Position")
@export var minimum_spawn_distance_ahead: float = 900.0
@export var maximum_spawn_distance_ahead: float = 1400.0

# The player's root is at approximately y = 807,
# while the running surface is at y = 820.
@export var ground_offset_from_player: float = 6.0
@export var ground_y: float = 820.0

# Mud will be removed when the player reaches this distance
# before the next sports event.
@export var cleanup_before_event_distance: float = 1500.0

# Your event position appears to use meters while the world
# position uses approximately 100 pixels per meter.
@export var event_position_scale: float = 100.0

# Remove mud once it is safely behind the player.
@export var despawn_distance_behind: float = 800.0

@onready var spawn_timer: Timer = $SpawnTimer

var mud_spawning_enabled: bool = false
var spawned_mud: Array[Node2D] = []

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# Mud does not spawn before the first sports event.
	mud_spawning_enabled = false

	if not SportEventSignalBus.finish_event.is_connected(
		_on_sports_event_finished
	):
		SportEventSignalBus.finish_event.connect(
			_on_sports_event_finished
		)


func _process(_delta: float) -> void:
	_remove_invalid_mud_references()

	if not mud_spawning_enabled:
		return

	# This is the primary early-cleanup check. Mud disappears
	# before the player reaches the next sports event.
	if _player_is_approaching_next_event():
		_stop_and_clear_mud()
		return

	# Safety check in case the event begins through another path.
	if _sports_event_is_active():
		_stop_and_clear_mud()


func _on_sports_event_finished() -> void:
	# Wait until the SportsEventManager has fully ended
	# and cleaned up the current event.
	while _sports_event_is_active():
		await get_tree().process_frame

	mud_spawning_enabled = true

	# Guarantee the first mud spawn shortly after the event.
	_schedule_next_spawn(true)


func _on_spawn_timer_timeout() -> void:
	if not mud_spawning_enabled:
		return

	_remove_invalid_mud_references()

	if _sports_event_is_active():
		_stop_and_clear_mud()
		return

	if _player_is_approaching_next_event():
		_stop_and_clear_mud()
		return

	if spawned_mud.size() < maximum_active_mud:
		_try_spawn_mud()

	_schedule_next_spawn()


func _schedule_next_spawn(
	is_first_spawn: bool = false
) -> void:
	if not mud_spawning_enabled:
		return

	if is_first_spawn:
		spawn_timer.start(
			rng.randf_range(
				minimum_first_spawn_delay,
				maximum_first_spawn_delay
			)
		)
		return

	spawn_timer.start(
		rng.randf_range(
			minimum_spawn_delay,
			maximum_spawn_delay
		)
	)


func _try_spawn_mud() -> void:
	if mud_scene == null:
		push_error("MudSpawner has no mud scene assigned.")
		return

	if player == null:
		return

	var minimum_spawn_x := (
		player.global_position.x
		+ minimum_spawn_distance_ahead
	)

	var maximum_spawn_x := (
		player.global_position.x
		+ maximum_spawn_distance_ahead
	)

	var next_event_x := _get_next_event_world_x()

	if not is_inf(next_event_x):
		maximum_spawn_x = minf(
			maximum_spawn_x,
			next_event_x - cleanup_before_event_distance
		)

	if maximum_spawn_x <= minimum_spawn_x:
		print("No room to spawn mud before next event.")
		return

	for attempt in range(10):
		var spawn_x := rng.randf_range(
			minimum_spawn_x,
			maximum_spawn_x
		)

		if not _has_enough_spacing(spawn_x):
			continue

		_spawn_mud_at(spawn_x)
		return

	print("Could not find a valid mud position.")


func _spawn_mud_at(spawn_x: float) -> void:
	var mud := mud_scene.instantiate() as Node2D

	if mud == null:
		push_error("The mud scene must have a Node2D root.")
		return

	var parent_node: Node = mud_parent

	if parent_node == null:
		parent_node = self

	parent_node.add_child(mud)

	mud.global_position = Vector2(
		spawn_x,
		player.global_position.y + ground_offset_from_player
	)
	
	print(
		"Mud spawned at: ",
		mud.global_position,
		" | Player at: ",
		player.global_position
	)	

	spawned_mud.append(mud)


func _has_enough_spacing(spawn_x: float) -> bool:
	for mud in spawned_mud:
		if not is_instance_valid(mud):
			continue

		var distance_from_other_mud := absf(
			mud.global_position.x - spawn_x
		)

		if distance_from_other_mud < minimum_mud_spacing:
			return false

	return true


func _position_is_before_next_event(spawn_x: float) -> bool:
	var next_event_x := _get_next_event_world_x()

	if is_inf(next_event_x):
		return true

	return (
		spawn_x
		< next_event_x - cleanup_before_event_distance
	)


func _player_is_approaching_next_event() -> bool:
	if player == null:
		return false

	var next_event_x := _get_next_event_world_x()

	if is_inf(next_event_x):
		return false

	return (
		player.global_position.x
		>= next_event_x - cleanup_before_event_distance
	)


func _get_next_event_world_x() -> float:
	if sports_event_manager == null:
		return INF

	var event_start_value = sports_event_manager.get(
		"event_start_pos"
	)

	if event_start_value == null:
		return INF

	return float(event_start_value) * event_position_scale


func _sports_event_is_active() -> bool:
	if sports_event_manager == null:
		return false

	var event_started_value = sports_event_manager.get(
		"event_started"
	)

	if event_started_value == null:
		return false

	return bool(event_started_value)


#func _remove_mud_behind_player() -> void:
	#if player == null:
		#return
#
	#for mud in spawned_mud:
		#if not is_instance_valid(mud):
			#continue
#
		#if (
			#mud.global_position.x
			#< player.global_position.x - despawn_distance_behind
		#):
			#mud.queue_free()


func _remove_invalid_mud_references() -> void:
	for index in range(
		spawned_mud.size() - 1,
		-1,
		-1
	):
		var mud := spawned_mud[index]

		if (
			not is_instance_valid(mud)
			or mud.is_queued_for_deletion()
		):
			spawned_mud.remove_at(index)


func _stop_and_clear_mud() -> void:
	mud_spawning_enabled = false
	spawn_timer.stop()

	for mud in spawned_mud:
		if is_instance_valid(mud):
			mud.queue_free()

	spawned_mud.clear()
