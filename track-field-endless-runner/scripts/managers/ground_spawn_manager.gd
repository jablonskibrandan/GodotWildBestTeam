extends Node

@export var ground_chunk: PackedScene
var chunk_width: float = 1920.0
var next_spawn_x: float = 1920.0

@onready var player: Player = $"../../Player"
@onready var ground: Node2D = $"../../Ground"

func _process(_delta: float) -> void:
	if player.position.x > next_spawn_x - 1920.0:
		spawn_ground_chunk()
	
func spawn_ground_chunk() -> void:
	var new_chunk = ground_chunk.instantiate()
	new_chunk.position = Vector2(next_spawn_x, 1080.0)
	ground.add_child(new_chunk)
	next_spawn_x = next_spawn_x + chunk_width
