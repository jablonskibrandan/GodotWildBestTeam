class_name Player
extends CharacterBody2D

@export var boost_line: BoostLine

var speed: float = 0.0

var mud_speed_multiplier: float = 1.0
var hurdle_speed_multiplier: float = 1.0

var hurdle_slow_id: int = 0


func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)

	speed = boost_line.speed / 10.0


func _physics_process(delta: float) -> void:
	speed = maxf(speed - 0.2 * delta, 0.0)

	var final_speed := (
		speed
		* mud_speed_multiplier
		* hurdle_speed_multiplier
	)

	velocity.x = final_speed
	move_and_slide()


func _on_boost_speed_success() -> void:
	speed *= 1.1


func enter_mud(multiplier: float = 0.6) -> void:
	mud_speed_multiplier = clampf(multiplier, 0.0, 1.0)


func exit_mud() -> void:
	mud_speed_multiplier = 1.0


func hit_hurdle(multiplier: float = 0.5, duration: float = 2.0) -> void:
	hurdle_slow_id += 1
	var current_slow_id := hurdle_slow_id

	hurdle_speed_multiplier = clampf(multiplier, 0.0, 1.0)

	await get_tree().create_timer(duration).timeout

	if current_slow_id == hurdle_slow_id:
		hurdle_speed_multiplier = 1.0
