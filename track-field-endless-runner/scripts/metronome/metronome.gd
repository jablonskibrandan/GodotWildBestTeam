class_name Metronome
extends ColorRect

@export var player: Player
@export var boost_line: BoostLine
@export var timer: Timer
@export var standard_colour: Color
@export var success_colour: Color
@export var fail_colour: Color

@export_category("Metronome speed")
@export var base_player_speed: float = 10.0
@export var base_metronome_speed: float = 200.0
@export var max_metronome_speed: float = 400.0
@export var metronome_speed_change_rate: float = 300.0

@export_category("Success streak")
@export var successes_needed_for_bonus: int = 8
@export var streak_speed_bonus: float = 0.5

var should_boost: bool = true
var current_metronome_speed: float = 0.0
var successful_metronomes_in_a_row: int = 0


func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	PlayerSignalBus.boost_speed_fail.connect(_on_boost_speed_fail)

	current_metronome_speed = (
		base_metronome_speed
		* GameData.metronome_line_speed
	)

	if boost_line != null:
		boost_line.set_metronome_speed(current_metronome_speed)


func _process(delta: float) -> void:
	update_metronome_speed(delta)

	if Input.is_action_just_pressed("left_leg") and should_boost == true and $BoostArea.left_leg_ready == true:
		left_boost()
		PlayerSignalBus.boost_speed_success.emit()
	elif Input.is_action_just_pressed("right_leg") and should_boost == true and $BoostArea.right_leg_ready == true:
		right_boost()
		PlayerSignalBus.boost_speed_success.emit()
	elif Input.is_action_just_pressed("right_leg") and should_boost == false:
		PlayerSignalBus.boost_speed_fail.emit()
	elif Input.is_action_just_pressed("left_leg") and should_boost == false:
		PlayerSignalBus.boost_speed_fail.emit()
	elif Input.is_action_just_pressed("right_leg") and $BoostArea.right_leg_ready == false:
		PlayerSignalBus.boost_speed_fail.emit()
	elif Input.is_action_just_pressed("left_leg") and $BoostArea.left_leg_ready == false:
		PlayerSignalBus.boost_speed_fail.emit()

	if player != null:
		$SpeedLabel.text = str("%0.2f" % player.velocity.x)


func update_metronome_speed(delta: float) -> void:
	if player == null or boost_line == null:
		return

	var player_speed: float = absf(player.velocity.x)

	var max_player_speed: float = maxf(
		GameData.player_max_speed,
		base_player_speed + 0.01
	)

	var player_speed_percentage: float = inverse_lerp(
		base_player_speed,
		max_player_speed,
		player_speed
	)

	player_speed_percentage = clampf(
		player_speed_percentage,
		0.0,
		1.0
	)

	var target_metronome_speed: float = (
		lerpf(
			base_metronome_speed,
			max_metronome_speed,
			player_speed_percentage
		)
		* GameData.metronome_line_speed
	)

	current_metronome_speed = move_toward(
		current_metronome_speed,
		target_metronome_speed,
		metronome_speed_change_rate * delta
	)

	boost_line.set_metronome_speed(current_metronome_speed)


func left_boost() -> void:
	pass


func right_boost() -> void:
	pass


func _on_boost_area_body_entered(body: Node) -> void:
	if body == boost_line:
		should_boost = true


func _on_boost_area_body_exited(body: Node) -> void:
	if body == boost_line:
		should_boost = false


func _on_boost_speed_success() -> void:
	color = success_colour
	timer.start()

	successful_metronomes_in_a_row += 1

	print(
		"Successful metronome streak: ",
		successful_metronomes_in_a_row,
		"/",
		successes_needed_for_bonus
	)

	if successful_metronomes_in_a_row >= successes_needed_for_bonus:
		successful_metronomes_in_a_row = 0

		if player != null:
			player.add_metronome_streak_boost(
				streak_speed_bonus
			)


func _on_boost_speed_fail() -> void:
	color = fail_colour
	timer.start()

	successful_metronomes_in_a_row = 0


func _on_visual_feedback_timer_timeout() -> void:
	color = standard_colour
