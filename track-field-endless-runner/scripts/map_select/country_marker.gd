extends Area2D
class_name CountryMarker


@export_category("Country")
@export var country_name: String = "Canada"
@export var country_label: Label
@export var marker_visual: Node2D

@export_category("Appearance")
@export var normal_color: Color = Color(0.65, 0.0, 0.0)
@export var hover_color: Color = Color(1.0, 0.25, 0.25)
@export var selected_color: Color = Color(1.0, 0.0, 0.0)

@export var hover_scale: float = 1.25
@export var selected_scale: float = 1.4

@export_category("Text")
@export var default_text: String = "SELECT A COUNTRY"

@export_category("Related Audio")
@export var hover_noise: AudioStreamPlayer
@export var confirm_noise: AudioStreamPlayer

var is_hovered: bool = false
var is_selected: bool = false
var original_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	add_to_group("country_markers")

	# Required for mouse hover/click detection.
	input_pickable = true

	if marker_visual != null:
		original_scale = marker_visual.scale

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

	_update_visual()


func _on_mouse_entered() -> void:
	is_hovered = true

	if country_label != null:
		country_label.text = country_name
	
	if hover_noise != null: 
		hover_noise.play()

	_update_visual()


func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visual()
	_update_label_after_exit()


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_index: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if confirm_noise != null: 
				confirm_noise.play()
			
			await get_tree().create_timer(1.75).timeout
			_select_country()


func _select_country() -> void:
	GameData.selected_country = country_name
	await get_tree().create_timer(0.15).timeout
	if GameData.has_witnessed_the_horrors:
		get_tree().change_scene_to_file("res://scenes/running_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

	


func set_selected(value: bool) -> void:
	is_selected = value
	_update_visual()


func _update_visual() -> void:
	if marker_visual == null:
		return

	if is_selected:
		marker_visual.modulate = selected_color
		marker_visual.scale = original_scale * selected_scale
	elif is_hovered:
		marker_visual.modulate = hover_color
		marker_visual.scale = original_scale * hover_scale
	else:
		marker_visual.modulate = normal_color
		marker_visual.scale = original_scale


func _update_label_after_exit() -> void:
	if country_label == null:
		return

	var selected_marker := _get_selected_marker()

	if selected_marker != null:
		country_label.text = selected_marker.country_name
	else:
		country_label.text = default_text


func _get_selected_marker() -> CountryMarker:
	for marker in get_tree().get_nodes_in_group("country_markers"):
		if marker is CountryMarker and marker.is_selected:
			return marker

	return null
