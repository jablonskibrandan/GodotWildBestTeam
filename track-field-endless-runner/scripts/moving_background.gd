extends Node2D

@export_category("Assets")
@export var sky_1: Texture
@export var sky_2: Texture
@export var sky_3: Texture
@export var sky_4: Texture
@export var sky_5: Texture
@export var sky_6: Texture
@export var scary_bg: Texture
@export_category("Reference Nodes")
@export var bg_sprite: Sprite2D
@export var glitch_sound: AudioStreamPlayer

var bg_no: int = 0
var bg_list: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BackgroundSignalBus.next_bg.connect(_on_next_bg)
	BackgroundSignalBus.scary_transition.connect(_on_scary_transition)
	
	bg_no = 0
	
	bg_list.append(sky_1)
	bg_list.append(sky_2)
	bg_list.append(sky_3)
	bg_list.append(sky_4)
	bg_list.append(sky_5)
	bg_list.append(sky_6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_next_bg() -> void:
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no + 1]
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no]
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no + 1]
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no]
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no + 1]
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no]
	await get_tree().create_timer(0.2).timeout
	bg_sprite.texture = bg_list[bg_no + 1]
	bg_no = bg_no + 1

func _on_scary_transition() -> void:
	$Crowd/Sprite2D.visible = false
	$Wall/Sprite2D.visible = false
	$Ground/Sprite2D.visible = false
	$Ground/Sprite2D2.visible = false
	$Background/Sprite2D.texture = scary_bg
	$Background/Sprite2D.hframes = 14
	$AnimationPlayer.play("scary_transition")
	glitch_sound.play()
	BackgroundSignalBus.expand_screen.emit()

func change_bg_colour() -> void:
	$Background/ColorRect.color = Color(0.616, 0.137, 0.267, 1.0)
