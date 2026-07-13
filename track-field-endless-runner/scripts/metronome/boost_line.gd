class_name BoostLine
extends CharacterBody2D

@export var speed: float = 100.0

var moving_right: bool = true

func _ready() -> void:
	velocity.x = 1 * speed

func _process(_delta: float) -> void:
	if moving_right == true:
		if position.x >= $"..".size.x - $Sprite2D.texture.width:
			moving_right = false
		velocity.x = 1 * speed
	else:
		if position.x <= 0:
			moving_right = true
		velocity.x = -1 * speed
	move_and_slide()
