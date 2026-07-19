extends RichTextLabel

func _on_timer_timeout() -> void:
	if self.visible == true:
		self.visible = false
		$FlashingTimer.wait_time = 0.1
	else:
		self.visible = true
		$FlashingTimer.wait_time = 0.5

func _on_turn_off_flashing_timer_timeout() -> void:
	SportEventSignalBus.event_name_label_finished_flashing.emit()
	$FlashingTimer.stop()
	$"..".visible = false
