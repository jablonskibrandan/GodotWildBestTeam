extends HBoxContainer

func _process(_delta: float) -> void:
	$MultAmount.text = str(GameData.mult)
