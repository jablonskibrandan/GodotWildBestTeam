class_name Hazard
extends Area2D


enum HazardType {
	MUD,
	HURDLE
}

@export var associated_sprite: Sprite2D

@export var set_hazard_type: HazardType = HazardType.MUD

var hurdle_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match set_hazard_type:
		HazardType.MUD:
			if body.has_method("enter_mud"):
				body.enter_mud()

		HazardType.HURDLE:
			if hurdle_triggered:
				return

			if body.has_method("hit_hurdle"):
				hurdle_triggered = true
				body.hit_hurdle()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if set_hazard_type == HazardType.MUD:
		if body.has_method("exit_mud"):
			body.exit_mud()
