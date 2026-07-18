extends Node2D
class_name MonsterChase


@export_category("References")
@export var player: Player

@export_category("Startup")
# How long the monster waits before reacting to the player's pace.
@export var startup_grace_time: float = 4.0

@export var attack_audio: AudioStreamPlayer

@export_category("Monster Distance")
# Maximum distance the monster can fall behind the player.
@export var far_distance: float = 300.0

# Distance at which the monster can attack the player.
@export var catch_distance: float = 75.0

# Minimum amount the monster moves backward after attacking.
@export var attack_fallback_distance: float = 140.0


@export_category("Pace Balance")
# At or above this percentage of maximum speed, the player
# is considered to be keeping a safe pace.
@export_range(0.0, 1.0, 0.01)
var safe_speed_ratio: float = 0.50

# At or below this percentage, the monster approaches
# at its maximum approach speed.
@export_range(0.0, 1.0, 0.01)
var full_danger_speed_ratio: float = 0.15

# Maximum speed at which the monster approaches.
@export var maximum_approach_speed: float = 35.0

# Maximum speed at which good play pushes the monster backward.
@export var maximum_fallback_speed: float = 45.0

# Higher values react more quickly to speed changes.
# Lower values average the player's speed for longer.
@export var speed_smoothing: float = 3.0

# How long the player must remain below the safe pace before
# the monster is allowed to attack.
@export var slow_time_before_hit: float = 1.5


@export_category("Attack and Retreat")
# How quickly the monster falls backward after attacking.
@export var retreat_speed: float = 260.0

# Minimum time between attacks.
@export var attack_cooldown: float = 1.5


@export_category("Post-Hit Recovery")
# How long the monster waits after retreating before reacting
# to the player's speed again.
@export var post_hit_grace_time: float = 2.5

# Distance the monster retreats to after landing a hit.
@export var recovery_distance: float = 240.0


@export_category("Debug Appearance")
# Vertical position relative to the player.
@export var monster_y_offset: float = 0.0

# Normal color for the temporary MeshInstance2D.
@export var normal_color: Color = Color.WHITE

# Color used when the monster attacks and retreats.
@export var attack_color: Color = Color.RED


@onready var debug_body: CanvasItem = (
	get_node_or_null("MeshInstance2D") as CanvasItem
)


var distance_behind_player: float = 0.0
var retreat_target_distance: float = 0.0

var startup_timer: float = 0.0
var slow_timer: float = 0.0
var cooldown_timer: float = 0.0
var post_hit_timer: float = 0.0

var smoothed_speed_ratio: float = 1.0

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

	startup_timer = startup_grace_time
	distance_behind_player = far_distance
	retreat_target_distance = far_distance
	smoothed_speed_ratio = 1.0

	if debug_body != null:
		debug_body.self_modulate = normal_color

	_update_position()


func _physics_process(delta: float) -> void:
	if player == null:
		return

	_update_cooldown(delta)

	if startup_timer > 0.0:
		_process_startup_grace(delta)
		return

	var maximum_speed = maxf(
		GameData.player_max_speed,
		0.01
	)

	# velocity.x includes the effects of mud and hurdle multipliers,
	# we want to make sure we get the TRUE speed
	var current_player_speed = absf(
		player.velocity.x
	)

	var raw_speed_ratio = clampf(
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


func _process_startup_grace(delta: float) -> void:
	startup_timer = maxf(
		startup_timer - delta,
		0.0
	)

	slow_timer = 0.0
	smoothed_speed_ratio = 1.0
	distance_behind_player = far_distance

	_update_position()


func _update_cooldown(delta: float) -> void:
	cooldown_timer = maxf(
		cooldown_timer - delta,
		0.0
	)


func _update_smoothed_speed(
	raw_speed_ratio: float,
	delta: float
) -> void:
	var smoothing_strength = maxf(
		speed_smoothing,
		0.01
	)

	var smoothing_weight = 1.0 - exp(
		-smoothing_strength * delta
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
	var safe_threshold = _get_safe_speed_threshold()

	if speed_ratio < safe_threshold:
		slow_timer += delta
	else:
		# Consistently good play quickly removes accumulated danger.
		slow_timer = maxf(
			slow_timer - delta * 2.5,
			0.0
		)


func _process_pace_chase(
	speed_ratio: float,
	delta: float
) -> void:
	var safe_threshold = _get_safe_speed_threshold()

	if speed_ratio >= safe_threshold:
		# The player is performing well, so the monster falls behind.
		var good_pace_strength = inverse_lerp(
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
		# The player is below the safe pace.
		# The slower they are, the faster the monster approaches.
		var danger_strength := 1.0 - inverse_lerp(
			full_danger_speed_ratio,
			safe_threshold,
			speed_ratio
		)

		danger_strength = clampf(
			danger_strength,
			0.0,
			1.0
		)

		distance_behind_player -= (
			maximum_approach_speed
			* danger_strength
			* delta
		)

	distance_behind_player = clampf(
		distance_behind_player,
		catch_distance,
		far_distance
	)


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

		if debug_body != null:
			debug_body.self_modulate = normal_color


func _process_post_hit_grace(delta: float) -> void:
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

	# Keep the monster at its recovery position during the grace period.
	distance_behind_player = move_toward(
		distance_behind_player,
		safe_distance,
		retreat_speed * delta
	)

	# Continue smoothing the player's current pace during recovery.
	# This allows the monster to resume naturally afterward.


func _can_attack() -> bool:
	if startup_timer > 0.0:
		return false

	if post_hit_timer > 0.0:
		return false

	if is_retreating:
		return false

	if cooldown_timer > 0.0:
		return false

	if slow_timer < slow_time_before_hit:
		return false

	return distance_behind_player <= catch_distance + 5.0


func _attack_player() -> void:
	attack_audio.play()
	slow_timer = 0.0
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

	if debug_body != null:
		debug_body.self_modulate = attack_color

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
	# Prevent the safe and full-danger thresholds from overlapping.
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
