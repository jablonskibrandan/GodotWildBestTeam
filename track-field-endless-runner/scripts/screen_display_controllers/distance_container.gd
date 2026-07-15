extends HBoxContainer

@export var player: Player

func _process(_delta: float) -> void:
	if player == null:
		return
	$DistanceTravelledAmount.text = str("%0.2f" % player.distance_travelled)
