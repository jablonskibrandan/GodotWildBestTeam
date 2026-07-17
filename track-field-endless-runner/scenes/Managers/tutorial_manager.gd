extends Node

@export var dialogue_control: DialogueControl
@export var player: Player
@export var coach: Coach
@export var metronome: ColorRect
@export var hurdle_template: PackedScene
@export var sports_objects_root: Node2D
@export var javelin_template: PackedScene
@export var javelin_sound: AudioStreamPlayer

var javelin: Sprite2D

var moving_to_next_tutorial_step: bool = false
var tutorial_step: int = 0
var hurdle_pos: Vector2 = Vector2(0, 0)

func _ready() -> void:
	player.speed = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dialogue_control._is_typing == false and moving_to_next_tutorial_step == false:
		moving_to_next_tutorial_step = true
		tutorial_step = tutorial_step + 1
		next_tutorial_step()
	
	if tutorial_step == 4 and Input.is_action_just_pressed("left_leg") and metronome.should_boost == true:
		moving_to_next_tutorial_step = false
	
	if tutorial_step == 5 and Input.is_action_just_pressed("right_leg") and metronome.should_boost == true:
		moving_to_next_tutorial_step = false
	
	if tutorial_step == 8 and Input.is_action_just_pressed("action"):
		moving_to_next_tutorial_step = false
	
	if tutorial_step == 11 and Input.is_action_just_pressed("action"):
		throw_javelin()
		moving_to_next_tutorial_step = false
		

func next_tutorial_step() -> void:
	match tutorial_step:
		1:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		2:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		3:
			await get_tree().create_timer(3.0).timeout
			BackgroundSignalBus.next_bg.emit()
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		4:
			await get_tree().create_timer(3.0).timeout
			player.speed = 10.0
			player.get_node("AudioStreamPlayer").play()
			dialogue_control._advance_dialogue()
			metronome.visible = true
		5:
			dialogue_control._advance_dialogue()
		6:
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		7:
			await get_tree().create_timer(3.0).timeout
			BackgroundSignalBus.next_bg.emit()
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		8:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			player.current_event = "110m"
			var hurdle: ObstacleMove = hurdle_template.instantiate()
			hurdle_pos = Vector2(player.position.x + 5000, 820)
			hurdle.position = hurdle_pos
			sports_objects_root.add_child(hurdle)
		9:
			BackgroundSignalBus.next_bg.emit()
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		10:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		11:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			javelin = javelin_template.instantiate()
			javelin.position = Vector2(0, -90)
			javelin.rotation_degrees = -30.0
			player.add_child(javelin)
			player.is_holding_javelin = true
			player.current_event = "javelin"
		12:
			await get_tree().create_timer(3.0).timeout
			BackgroundSignalBus.next_bg.emit()
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		13:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		14:
			await get_tree().create_timer(3.0).timeout
			BackgroundSignalBus.next_bg.emit()
			dialogue_control._advance_dialogue()
			moving_to_next_tutorial_step = false
		15:
			await get_tree().create_timer(3.0).timeout
			dialogue_control._advance_dialogue()
			coach
			
	
func throw_javelin() -> void:
	javelin.rotation_degrees = player.javelin_angle * -1.0
	var angle_in_rad = deg_to_rad(javelin.rotation_degrees)
	var direction = Vector2(cos(angle_in_rad), -sin(angle_in_rad))
	var end_position = javelin.position + direction * 800.0 * 3.0
	javelin.rotation_degrees = javelin.rotation_degrees * -1.0
	var tween = create_tween()
	tween.tween_property(javelin, "position", end_position, 3.0)
	player.is_holding_javelin = false
	javelin_sound.play()
