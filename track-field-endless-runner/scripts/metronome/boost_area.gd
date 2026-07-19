class_name BoostArea
extends Area2D


@onready var boost_line: BoostLine = $"../BoostLine"

@export var max_width: float = 200.0
@export var coyote_space: float = 16.0

var collision_shape_width: float = 20.0
var sprite_pos: float = 0.0
var collision_shape_pos: float = 0.0

var left_leg_ready: bool = true
var right_leg_ready: bool = false

var last_applied_window_width: float = -1.0


func _ready() -> void:
	PlayerSignalBus.boost_speed_success.connect(
		_on_boost_speed_success
	)

	refresh_from_game_data()


func _process(_delta: float) -> void:
	if not is_equal_approx(
		last_applied_window_width,
		GameData.metronome_boost_area_width
	):
		refresh_from_game_data()


func refresh_from_game_data() -> void:
	var window_width := clampf(
		GameData.metronome_boost_area_width,
		1.0,
		max_width
	)

	collision_shape_width = window_width + coyote_space

	if right_leg_ready:
		sprite_pos = (
			max_width
			- (max_width / 4.0)
			- (window_width / 2.0)
		)
	else:
		sprite_pos = (
			(max_width / 4.0)
			- (window_width / 2.0)
		)

	collision_shape_pos = sprite_pos
	last_applied_window_width = (
		GameData.metronome_boost_area_width
	)

	update_boost_area_visuals()


func update_boost_area_visuals() -> void:
	$Sprite2D.texture.width = clampf(
		GameData.metronome_boost_area_width,
		1.0,
		max_width
	)

	$Sprite2D.position.x = sprite_pos
	$CollisionShape2D.shape.size.x = collision_shape_width
	$CollisionShape2D.position.x = collision_shape_pos


func _on_boost_speed_success() -> void:
	if left_leg_ready:
		left_leg_ready = false
		right_leg_ready = true
	else:
		left_leg_ready = true
		right_leg_ready = false

	refresh_from_game_data()


func update_boost_area_pos(spawn_side: String) -> void:
	match spawn_side:
		"right":
			left_leg_ready = false
			right_leg_ready = true

		"left":
			left_leg_ready = true
			right_leg_ready = false

	refresh_from_game_data()
