class_name BoostLine
extends CharacterBody2D

var moving_right: bool = true

func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	velocity.x = 1 * GameData.metronome_line_speed

func _process(_delta: float) -> void:
	if moving_right == true:
		if position.x >= $"..".size.x - $Sprite2D.texture.width:
			moving_right = false
		velocity.x = 1 * GameData.metronome_line_speed
	else:
		if position.x <= 0:
			moving_right = true
		velocity.x = -1 * GameData.metronome_line_speed
	move_and_slide()

func _on_boost_speed_success() -> void:
	if $"../BoostArea".left_leg_ready == true:
		moving_right = false
	else:
		moving_right = true
