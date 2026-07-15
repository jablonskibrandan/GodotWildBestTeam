extends HBoxContainer

@export var player: Player

func _process(delta: float) -> void:
	$DistanceAmount.text = str("%0.2f" % player.distance_travelled)
