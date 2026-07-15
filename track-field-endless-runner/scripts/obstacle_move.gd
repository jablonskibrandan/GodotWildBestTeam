class_name ObstacleMove
extends Area2D

@export var movement_speed: float = 400.0
@export var delete_x_position: float = -300.0


func _physics_process(delta: float) -> void:
	global_position.x -= movement_speed * delta

	if global_position.x <= delete_x_position:
		queue_free()
