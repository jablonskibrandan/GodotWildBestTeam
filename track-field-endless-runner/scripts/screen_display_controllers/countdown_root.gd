extends Control

var count: int = 3

func _on_countdown_timer_timeout() -> void:
	if count == 0:
		$CountdownTimer.stop()
		self.visible = false
		count = 3
		$CountdownText.text = str(count)
	elif count == 1:
		$CountdownText.text = str("GO!")
		SportEventSignalBus.countdown_finished.emit()
		count = count - 1
	else:
		count = count - 1
		$CountdownText.text = str(count)
