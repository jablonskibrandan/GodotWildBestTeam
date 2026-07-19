extends Node2D
class_name MonsterChase


@export_category("References")
@export var player: Player
@export var attack_audio: AudioStreamPlayer


@export_category("Startup")
# The monster starts this far behind the player.
# This should be greater than far_distance.
@export var starting_distance: float = 500.0

# How long the opening catch-up lasts before normal
# chase behavior can begin.
@export var startup_grace_time: float = 4.0

# How quickly the monster moves from starting_distance
# toward far_distance at the beginning.
@export var startup_catchup_speed: float = 65.0


@export_category("Monster Distance")
# Farthest normal distance behind the player.
@export var far_distance: float = 300.0

# Distance at which the monster can attack.
@export var catch_distance: float = 75.0

# Minimum distance added after an attack.
@export var attack_fallback_distance: float = 140.0


@export_category("Pace Balance")
# Below this percentage of maximum speed, the monster
# begins approaching the player.
@export_range(0.0, 1.0, 0.01)
var safe_speed_ratio: float = 0.25

# At or below this percentage, the monster approaches
# at maximum_approach_speed.
@export_range(0.0, 1.0, 0.01)
var full_danger_speed_ratio: float = 0.10

# Minimum approach speed whenever the player is below
# safe_speed_ratio.
@export var minimum_approach_speed: float = 60.0

# Approach speed when the player is stopped or extremely slow.
@export var maximum_approach_speed: float = 150.0

# How quickly good movement pushes the monster backward.
@export var maximum_fallback_speed: float = 45.0

# Higher values make the monster react more quickly
# to changes in the player's speed.
@export var speed_smoothing: float = 3.0

# The player must remain vulnerable for this long before
# the monster is allowed to attack.
@export var slow_time_before_hit: float = 1.5


@export_category("Metronome Fairness")
# A successful metronome hit prevents the monster from
# approaching for this amount of time.
#
# Set this slightly longer than the usual time between
# successful metronome opportunities.
@export var successful_hit_grace_time: float = 1.25

# Immediate breathing room gained from each successful hit.
@export var successful_hit_pushback: float = 8.0

# How quickly repeated successful hits move the monster
# back toward far_distance.
@export var successful_pace_fallback_speed: float = 30.0


@export_category("Attack and Retreat")
# How quickly the monster retreats after attacking.
@export var retreat_speed: float = 260.0

# Minimum time between attacks.
@export var attack_cooldown: float = 1.5


@export_category("Post-Hit Recovery")
# How long the monster waits after retreating before
# reacting to the player's speed again.
@export var post_hit_grace_time: float = 2.5

# Distance the monster retreats to after hitting the player.
@export var recovery_distance: float = 240.0


@export_category("Appearance")
# Vertical position relative to the player.
@export var monster_y_offset: float = 0.0

@export var normal_color: Color = Color.WHITE
@export var attack_color: Color = Color.RED


@onready var monster_visual: CanvasItem = (
	_get_monster_visual()
)


var distance_behind_player: float = 0.0
var retreat_target_distance: float = 0.0

var startup_timer: float = 0.0
var slow_timer: float = 0.0
var cooldown_timer: float = 0.0
var post_hit_timer: float = 0.0
var successful_hit_grace_timer: float = 0.0

var smoothed_speed_ratio: float = 1.0

var startup_finished: bool = false
var is_retreating: bool = false


func _ready() -> void:
	if player == null:
		player = get_parent() as Player

	if player == null:
		push_error(
			"MonsterChase must be a child of Player "
			+ "or have Player assigned in the Inspector."
		)

		set_physics_process(false)
		return

	if not PlayerSignalBus.boost_speed_success.is_connected(
		_on_metronome_success
	):
		PlayerSignalBus.boost_speed_success.connect(
			_on_metronome_success
		)

	if not PlayerSignalBus.boost_speed_fail.is_connected(
		_on_metronome_fail
	):
		PlayerSignalBus.boost_speed_fail.connect(
			_on_metronome_fail
		)

	startup_timer = maxf(
		startup_grace_time,
		0.0
	)

	startup_finished = false

	distance_behind_player = maxf(
		starting_distance,
		far_distance
	)

	retreat_target_distance = far_distance
	smoothed_speed_ratio = 1.0

	if monster_visual != null:
		monster_visual.self_modulate = normal_color

	_update_position()


func _physics_process(delta: float) -> void:
	if player == null:
		return

	_update_cooldown(delta)
	_update_successful_hit_timer(delta)

	if not startup_finished:
		_process_startup_catchup(delta)
		return

	var maximum_speed := maxf(
		GameData.player_max_speed,
		0.01
	)

	# velocity.x includes active mud slowdown and other
	# movement modifiers.
	var current_player_speed := absf(
		player.velocity.x
	)

	var raw_speed_ratio := clampf(
		current_player_speed / maximum_speed,
		0.0,
		1.0
	)

	_update_smoothed_speed(
		raw_speed_ratio,
		delta
	)

	if is_retreating:
		_process_retreat(delta)
		_update_position()
		return

	if post_hit_timer > 0.0:
		_process_post_hit_grace(delta)
		_update_position()
		return

	# Successful metronome hits protect the player from
	# the monster approaching.
	if successful_hit_grace_timer > 0.0:
		_process_successful_pace(delta)
		_update_position()
		return

	_update_slow_timer(
		smoothed_speed_ratio,
		delta
	)

	_process_pace_chase(
		smoothed_speed_ratio,
		delta
	)

	_update_position()

	if _can_attack():
		_attack_player()


func _process_startup_catchup(delta: float) -> void:
	startup_timer = maxf(
		startup_timer - delta,
		0.0
	)

	slow_timer = 0.0
	smoothed_speed_ratio = 1.0

	var catchup_speed := maxf(
		startup_catchup_speed,
		0.0
	)

	distance_behind_player = move_toward(
		distance_behind_player,
		far_distance,
		catchup_speed * delta
	)

	_update_position()

	var reached_normal_distance := (
		distance_behind_player
		<= far_distance + 0.1
	)

	if startup_timer <= 0.0 and reached_normal_distance:
		distance_behind_player = far_distance
		startup_finished = true


func _update_cooldown(delta: float) -> void:
	cooldown_timer = maxf(
		cooldown_timer - delta,
		0.0
	)


func _update_successful_hit_timer(
	delta: float
) -> void:
	successful_hit_grace_timer = maxf(
		successful_hit_grace_timer - delta,
		0.0
	)


func _update_smoothed_speed(
	raw_speed_ratio: float,
	delta: float
) -> void:
	var smoothing_strength := maxf(
		speed_smoothing,
		0.01
	)

	var smoothing_weight := (
		1.0
		- exp(-smoothing_strength * delta)
	)

	smoothed_speed_ratio = lerpf(
		smoothed_speed_ratio,
		raw_speed_ratio,
		smoothing_weight
	)


func _update_slow_timer(
	speed_ratio: float,
	delta: float
) -> void:
	var safe_threshold := (
		_get_safe_speed_threshold()
	)

	if speed_ratio < safe_threshold:
		slow_timer += delta
	else:
		# Good play removes accumulated danger more
		# quickly than it was accumulated.
		slow_timer = maxf(
			slow_timer - delta * 2.5,
			0.0
		)


func _process_pace_chase(
	speed_ratio: float,
	delta: float
) -> void:
	var safe_threshold := (
		_get_safe_speed_threshold()
	)

	if speed_ratio >= safe_threshold:
		var good_pace_strength := inverse_lerp(
			safe_threshold,
			1.0,
			speed_ratio
		)

		good_pace_strength = clampf(
			good_pace_strength,
			0.0,
			1.0
		)

		distance_behind_player += (
			maximum_fallback_speed
			* good_pace_strength
			* delta
		)

	else:
		var danger_strength := (
			1.0
			- inverse_lerp(
				full_danger_speed_ratio,
				safe_threshold,
				speed_ratio
			)
		)

		danger_strength = clampf(
			danger_strength,
			0.0,
			1.0
		)

		var current_approach_speed := lerpf(
			minimum_approach_speed,
			maximum_approach_speed,
			danger_strength
		)

		distance_behind_player -= (
			current_approach_speed
			* delta
		)

	distance_behind_player = clampf(
		distance_behind_player,
		catch_distance,
		far_distance
	)


func _process_successful_pace(
	delta: float
) -> void:
	# Successful metronome timing completely removes
	# accumulated attack danger.
	slow_timer = 0.0

	distance_behind_player = move_toward(
		distance_behind_player,
		far_distance,
		successful_pace_fallback_speed * delta
	)


func _on_metronome_success() -> void:
	successful_hit_grace_timer = maxf(
		successful_hit_grace_time,
		0.0
	)

	slow_timer = 0.0

	if not startup_finished:
		return

	if is_retreating:
		return

	if post_hit_timer > 0.0:
		return

	# Each successful timing input gives a small,
	# immediate amount of breathing room.
	distance_behind_player = minf(
		distance_behind_player
			+ successful_hit_pushback,
		far_distance
	)


func _on_metronome_fail() -> void:
	# A missed input immediately removes the protection
	# created by successful metronome timing.
	successful_hit_grace_timer = 0.0


func _process_retreat(delta: float) -> void:
	slow_timer = 0.0

	distance_behind_player = move_toward(
		distance_behind_player,
		retreat_target_distance,
		retreat_speed * delta
	)

	if distance_behind_player >= (
		retreat_target_distance - 0.1
	):
		distance_behind_player = retreat_target_distance

		is_retreating = false
		post_hit_timer = post_hit_grace_time

		if monster_visual != null:
			monster_visual.self_modulate = (
				normal_color
			)


func _process_post_hit_grace(
	delta: float
) -> void:
	post_hit_timer = maxf(
		post_hit_timer - delta,
		0.0
	)

	slow_timer = 0.0

	var safe_distance := clampf(
		recovery_distance,
		catch_distance,
		far_distance
	)

	distance_behind_player = move_toward(
		distance_behind_player,
		safe_distance,
		retreat_speed * delta
	)


func _can_attack() -> bool:
	if not startup_finished:
		return false

	if successful_hit_grace_timer > 0.0:
		return false

	if post_hit_timer > 0.0:
		return false

	if is_retreating:
		return false

	if cooldown_timer > 0.0:
		return false

	if slow_timer < slow_time_before_hit:
		return false

	return (
		distance_behind_player
		<= catch_distance + 5.0
	)


func _attack_player() -> void:
	if attack_audio != null:
		attack_audio.play()

	slow_timer = 0.0
	successful_hit_grace_timer = 0.0
	cooldown_timer = attack_cooldown
	is_retreating = true

	var safe_recovery_distance := clampf(
		recovery_distance,
		catch_distance,
		far_distance
	)

	retreat_target_distance = minf(
		maxf(
			distance_behind_player
				+ attack_fallback_distance,
			safe_recovery_distance
		),
		far_distance
	)

	if monster_visual != null:
		monster_visual.self_modulate = attack_color

	print(
		"MONSTER HIT PLAYER | Retreat distance: ",
		retreat_target_distance
	)

	if player.has_method("take_monster_hit"):
		player.take_monster_hit()
	else:
		push_warning(
			"Player does not have take_monster_hit()."
		)


func _get_safe_speed_threshold() -> float:
	return clampf(
		maxf(
			safe_speed_ratio,
			full_danger_speed_ratio + 0.01
		),
		0.01,
		1.0
	)


func _update_position() -> void:
	position = Vector2(
		-distance_behind_player,
		monster_y_offset
	)


func _get_monster_visual() -> CanvasItem:
	var monster_sprite := get_node_or_null(
		"MonsterSprite"
	) as CanvasItem

	if monster_sprite != null:
		return monster_sprite

	var sprite := get_node_or_null(
		"Sprite2D"
	) as CanvasItem

	if sprite != null:
		return sprite

	return get_node_or_null(
		"MeshInstance2D"
	) as CanvasItem
