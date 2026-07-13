class_name Player
extends CharacterBody2D

@export var boost_line: BoostLine

var speed: float = 0.0

func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	
	speed = boost_line.speed / 10.0

func _physics_process(delta: float) -> void:
	speed = speed - 0.2 * delta
	velocity.x = 1 * speed
	move_and_slide()

func _on_boost_speed_success() -> void:
	speed = speed * 1.1
