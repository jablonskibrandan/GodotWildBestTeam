extends Control

func add_loss() -> void:
	match GameData.loss_amount:
		1:
			$LossAmount.text = "X"
		2:
			$LossAmount.text = "XX"
		3:
			$LossAmount.text = "XXX"
	
	await get_tree().create_timer(0.5).timeout
	$LossAmount.visible = false
	await get_tree().create_timer(0.2).timeout
	$LossAmount.visible = true
	await get_tree().create_timer(0.5).timeout
	$LossAmount.visible = false
	await get_tree().create_timer(0.2).timeout
	$LossAmount.visible = true
	await get_tree().create_timer(0.5).timeout
	$LossAmount.visible = false
	await get_tree().create_timer(0.2).timeout
	$LossAmount.visible = true
