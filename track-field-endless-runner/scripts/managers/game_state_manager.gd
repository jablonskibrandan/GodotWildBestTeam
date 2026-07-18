class_name GameStateManager
extends Node

var game_over: bool
@export var game_over_control: GameOverControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if GameData.loss_amount >= 3: 
		game_over = true
		
	if game_over:
		game_over_control.show_game_over(GameData.score)
