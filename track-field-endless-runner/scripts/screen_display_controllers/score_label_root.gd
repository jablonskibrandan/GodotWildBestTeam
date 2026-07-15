extends HBoxContainer

func _process(_delta: float) -> void:
	$ScoreAmount.text = str(GameData.score)
