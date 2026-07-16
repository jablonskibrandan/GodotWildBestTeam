extends Polygon2D

var spin_right: bool = true

func _process(delta: float) -> void:
	if spin_right == true:
		if $AngleIndicator.rotation_degrees <= 0.0:
			$AngleIndicator.rotation_degrees = $AngleIndicator.rotation_degrees + GameData.javelin_gauge_speed * delta
		else:
			spin_right = false
	else:
		if $AngleIndicator.rotation_degrees >= -90.0:
			$AngleIndicator.rotation_degrees = $AngleIndicator.rotation_degrees - GameData.javelin_gauge_speed * delta
		else:
			spin_right = true
			
	if $"..".is_holding_javelin == true:
		self.visible = true
	else:
		self.visible = false
		
	if self.visible == true:
		if Input.is_action_just_pressed("action"):
			$"..".javelin_angle = $AngleIndicator.rotation_degrees
			SportEventSignalBus.javelin_thrown.emit()
			$"..".is_holding_javelin = false
