class_name GameStateManager
extends Node


@export var game_over_control: GameOverControl

var game_over: bool = false


func _ready() -> void:
	game_over = false


func _process(_delta: float) -> void:
	if game_over:
		return

	if GameData.loss_amount < 3:
		return

	game_over = true

	var base_score: int = GameData.score
	var score_multiplier: float = GameData.mult

	var final_score: int = roundi(
		float(base_score) * score_multiplier
	)

	print(
		"Base score: %d | Multiplier: %.2f | Final score: %d"
		% [
			base_score,
			score_multiplier,
			final_score
		]
	)

	if game_over_control == null:
		push_error(
			"GameStateManager does not have GameOverControl assigned."
		)
		return

	game_over_control.show_game_over(final_score)
