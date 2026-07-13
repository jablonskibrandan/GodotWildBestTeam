class_name BoostArea
extends Area2D

@onready var boost_line: BoostLine = $"../BoostLine"

@export var sprite_width: float = 20.0
@export var max_width: float = 200.0
@export var coyote_space: float = 8.0

var collision_shape_width: float = 20.0
var sprite_pos: float = 0.0
var collision_shape_pos: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	calculate_boost_area_spacing()
	update_boost_area_visuals()

func calculate_boost_area_spacing() -> void:
	collision_shape_width = sprite_width + coyote_space
	sprite_pos = (max_width / 4.0) - (sprite_width / 2.0)
	collision_shape_pos = sprite_pos

func update_boost_area_visuals() -> void:
	$Sprite2D.texture.width = sprite_width
	$Sprite2D.position.x = sprite_pos
	$CollisionShape2D.shape.size.x = collision_shape_width
	$CollisionShape2D.position.x = collision_shape_pos

func _on_boost_speed_success() -> void:
	if boost_line.moving_right == true:
		update_boost_area_pos("right")
	else:
		update_boost_area_pos("left")

func update_boost_area_pos(spawn_side: String) -> void:
	match spawn_side:
		"right":
			sprite_pos = max_width - (max_width / 4.0) - (sprite_width / 2.0)
			collision_shape_pos = sprite_pos
			update_boost_area_visuals()
		"left":
			sprite_pos = (max_width / 4.0) - (sprite_width / 2.0)
			collision_shape_pos = sprite_pos
			update_boost_area_visuals()
