class_name Metronome
extends ColorRect

@export var boost_line: BoostLine
@export var timer: Timer
@export var standard_colour: Color
@export var success_colour: Color
@export var fail_colour: Color

var should_boost: bool = true

func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	PlayerSignalBus.boost_speed_fail.connect(_on_boost_speed_fail)

func _process(_delta: float) -> void:
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

func _on_boost_speed_fail() -> void:
	color = fail_colour
	timer.start()

func _on_visual_feedback_timer_timeout() -> void:
	color = standard_colour
