extends Node

@export var player: Player
@export var score_label: RichTextLabel
@export var new_javelin_parent: Node2D

var distance: float = 0.0
var start_line_location: float = 0.0
var event_in_progress: bool = false

var javelin: Sprite2D
var javelin_speed: float = 800.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SportEventSignalBus.start_line_passed.connect(_on_start_line_passed)
	SportEventSignalBus.javelin_thrown.connect(_on_javelin_thrown)

func _on_javelin_thrown() -> void:
	if event_in_progress == true:
		javelin.rotation_degrees = player.javelin_angle * -1.0
		var angle_in_rad = deg_to_rad(javelin.rotation_degrees)
		var direction = Vector2(cos(angle_in_rad), -sin(angle_in_rad))
		var end_position = javelin.position + direction * javelin_speed * 3.0
		javelin.rotation_degrees = javelin.rotation_degrees * -1.0
		var tween = create_tween()
		tween.tween_property(javelin,"position", end_position, 3.0)
		player.is_holding_javelin = false
		calculate_throw_distance()
		AudioSignalBus.play_javelin_throw.emit()
		await get_tree().create_timer(4.0).timeout
		score_label.text = str("%0.2f" % distance)
		await get_tree().create_timer(2.0).timeout
		SportEventSignalBus.finish_event.emit()
		place_javelin_on_ground()

func calculate_throw_distance() -> void:
	var min_distance: float = 20.0
	var max_distance: float = 200.0
	
	var distance_to_start_line: float = start_line_location - player.distance_travelled
	var speed_factor: float = clamp(player.speed / GameData.player_max_speed, 0.0, 1.0)
	var angle_in_rad: float = deg_to_rad(javelin.rotation_degrees * -1.0)
	var angle_factor: float = sin(angle_in_rad * 2.0)
	
	distance = (min_distance + (max_distance - min_distance) * speed_factor * angle_factor) - distance_to_start_line

func _on_start_line_passed() -> void:
	if player.is_holding_javelin == true:
		player.is_holding_javelin = false
		javelin.queue_free()
		SportEventSignalBus.finish_event.emit()

func place_javelin_on_ground() -> void:
	var placement_distance: float = 0.0
	
	if distance < 30.0:
		placement_distance = 30
	else:
		placement_distance = distance
	
	javelin.reparent(new_javelin_parent)
	javelin.position = Vector2(player.position.x, 0.0) + Vector2(placement_distance * 100.0, 1050)
	javelin.rotation_degrees = -170.0
