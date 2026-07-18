class_name Coach
extends CharacterBody2D

@export var player: Player

var transformed: bool = false

func _physics_process(_delta: float) -> void:
	if transformed == false:
		velocity.x = GameData.player_current_speed
	else:
		velocity.x = -400.0
	move_and_slide()

func play_trip_sound() -> void:
	$Fall.play()

func run_away() -> void:
	$Sprite2D.flip_h = true
	transformed = true

func transform() -> void:
	$AnimationPlayer.play("transformation")
