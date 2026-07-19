class_name Hazard
extends Area2D


enum HazardType {
	MUD,
	HURDLE
}

@export var associated_sprite: Sprite2D
@export var normal_sprite: Texture2D
@export var horror_sprite: Texture2D

@export var set_hazard_type: HazardType = HazardType.MUD

var hurdle_triggered: bool = false
var has_been_visible_on_screen: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	print(
		"Hazard touched by: ",
		body.name,
		" | Groups: ",
		body.get_groups()
	)

	if not body.is_in_group("player"):
		return

	match set_hazard_type:
		HazardType.MUD:
			print("Mud successfully triggered on player")

			if body.has_method("enter_mud"):
				body.enter_mud(self)

		HazardType.HURDLE:
			if hurdle_triggered:
				return

			if body.has_method("hit_hurdle"):
				hurdle_triggered = true
				body.hit_hurdle()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not body.is_in_group("player"):
		return

	# Mud is no longer escaped merely by crossing the edge.
	# The player must complete the Space-bar mash.
	if set_hazard_type == HazardType.MUD:
		return
		
func remove_after_escape() -> void:
	set_deferred("monitoring", false)

	var mud_root := get_parent()

	if mud_root != null:
		mud_root.call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if set_hazard_type != HazardType.MUD:
		return

	has_been_visible_on_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if set_hazard_type != HazardType.MUD:
		return

	# Prevent mud from being deleted while it is initially
	# spawned ahead of the camera.
	if not has_been_visible_on_screen:
		return

	var mud_root := get_parent()

	if mud_root != null:
		mud_root.call_deferred("queue_free")
