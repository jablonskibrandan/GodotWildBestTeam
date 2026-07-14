extends Area2D
class_name Hazard

enum HazardType {
	WATER,
	HURDLE
}

@export var associated_sprite: Sprite2D

@export var set_hazard_type: HazardType = HazardType.WATER

@export_group("Water Hazard")
@export_range(0.0, 1.0, 0.05) var water_speed_multiplier: float = 0.5

@export_group("Hurdle Hazard")
@export_range(0.0, 1.0, 0.05) var hurdle_speed_multiplier: float = 0.5
@export var hurdle_slow_time: float = 2.0

var hurdle_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match set_hazard_type:
		HazardType.WATER:
			if body.has_method("enter_water"):
				body.enter_water(water_speed_multiplier)

		HazardType.HURDLE:
			if hurdle_triggered:
				return

			if body.has_method("apply_temporary_slow"):
				hurdle_triggered = true
				body.apply_temporary_slow(
					hurdle_speed_multiplier,
					hurdle_slow_time
				)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if set_hazard_type == HazardType.WATER:
		if body.has_method("exit_water"):
			body.exit_water()
