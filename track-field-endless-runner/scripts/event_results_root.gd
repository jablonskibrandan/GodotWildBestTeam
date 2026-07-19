extends Control

var count: int = 0

func _on_results_timer_timeout() -> void:
	if count == 0:
		$ScoreDifferenceRoot.visible = true
		count = count + 1
		$ResultsTimer.start()
	elif count == 1:
		$ScoreExplanationRoot.visible = true
		count = count + 1
		$ResultsTimer.start()
	elif count == 2:
		$TotalScoreRoot.visible = true
		count = count + 1
		$ResultsTimer.wait_time = 5.0
		$ResultsTimer.start()
	elif count == 3:
		$ScoreDifferenceRoot.visible = false
		$ScoreExplanationRoot.visible = false
		$TotalScoreRoot.visible = false
		$ResultsTimer.wait_time = 1.0
		count = 0
