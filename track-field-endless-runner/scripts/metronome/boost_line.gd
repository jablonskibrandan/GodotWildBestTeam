class_name BoostLine
extends CharacterBody2D

@export var current_line_speed: float = 200.0

var moving_right: bool = true


func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	update_velocity()


func _physics_process(_delta: float) -> void:
	var sprite_width: float = (
		$Sprite2D.texture.get_width()
		* absf($Sprite2D.scale.x)
	)

	var half_sprite_width: float = sprite_width / 2.0

	if moving_right == true:
		if position.x >= $"..".size.x - half_sprite_width:
			moving_right = false
			update_velocity()
	else:
		if position.x <= half_sprite_width:
			moving_right = true
			update_velocity()

	move_and_slide()


func set_metronome_speed(new_speed: float) -> void:
	current_line_speed = maxf(new_speed, 0.0)
	update_velocity()


func update_velocity() -> void:
	if moving_right == true:
		velocity.x = current_line_speed
	else:
		velocity.x = -current_line_speed


func _on_boost_speed_success() -> void:
	if $"../BoostArea".left_leg_ready == true:
		moving_right = false
	else:
		moving_right = true

	update_velocity()
