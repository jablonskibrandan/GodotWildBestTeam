class_name Coach
extends CharacterBody2D

@export var player: Player

func _physics_process(delta: float) -> void:
	velocity.x = GameData.player_current_speed
	move_and_slide()

func transform() -> void:
	print("Here the coach will transform and the world will glitch out.")
