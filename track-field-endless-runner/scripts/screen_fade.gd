extends CanvasLayer
class_name ScreenFade

signal fade_in_finished

@export var fade_rect: ColorRect

## Number of hard opacity changes.
## We do this to make a more retro look. 
@export_range(2, 16, 1)
var fade_steps: int = 5

## Time between each opacity step.
@export_range(0.01, 0.5, 0.01)
var step_duration: float = 0.08

## Automatically fade in when this scene starts.
@export var fade_in_on_ready: bool = true

var _is_fading: bool = false


func _ready() -> void:
	if not is_instance_valid(fade_rect):
		push_error("Fade Rect has not been assigned.")
		return

	## Need this because fade_rect covers the entire screen, so inputs could possibly be blocked.
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if fade_in_on_ready:
		call_deferred("_fade_in")
	else:
		_set_fade_alpha(0.0)
		fade_rect.hide()


func _fade_in() -> void:
	if _is_fading:
		return

	_is_fading = true
	fade_rect.show()

	## Begin with the screen completely covered.
	_set_fade_alpha(1.0)

	## Slowly fade in given the fade steps. Each step decreases the alpha more.
	for step: int in range(fade_steps, -1, -1):
		var alpha = float(step) / float(fade_steps)

		_set_fade_alpha(alpha)

		await get_tree().create_timer(
			step_duration
		).timeout

	_set_fade_alpha(0.0)
	fade_rect.hide()

	_is_fading = false
	fade_in_finished.emit()


func _set_fade_alpha(alpha: float) -> void:
	var fade_color = fade_rect.color
	fade_color.a = clampf(alpha, 0.0, 1.0)
	fade_rect.color = fade_color
