class_name MapResize
extends Node2D

@onready var map_sprite: Sprite2D = $MapSprite


func _ready() -> void:
	get_viewport().size_changed.connect(_fit_map_to_screen)
	call_deferred("_fit_map_to_screen")


func _fit_map_to_screen() -> void:
	if map_sprite.texture == null:
		return

	var map_size := Vector2(map_sprite.texture.get_size())
	var viewport_size := get_viewport().get_visible_rect().size

	# Start at the upper-left corner.
	position = Vector2.ZERO

	# Stretch X and Y independently so the map fills the whole screen.
	scale = Vector2(
		viewport_size.x / map_size.x,
		viewport_size.y / map_size.y
	)
