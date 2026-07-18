class_name GameOverControl
extends Control


@export_file("*.tscn")
var main_menu_scene: String = "res://scenes/main_menu.tscn"

@onready var score_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/FinalScoreLabel
)

@export_category("Controls To Hide")
@export var controls_to_hide: Array[Control] = []

var game_over_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func show_game_over(score: int) -> void:
	for control in controls_to_hide:
		if control != null:
			control.visible = false
			
	game_over_active = true

	score_label.text = "SCORE: %d" % score

	visible = true
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if not game_over_active:
		return

	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_R:
				get_viewport().set_input_as_handled()
				_return_to_main_menu()


func _return_to_main_menu() -> void:

	game_over_active = false
	GameData.loss_amount = 0
	# Unpause before changing scenes.
	get_tree().paused = false

	get_tree().change_scene_to_file(
		main_menu_scene
	)
