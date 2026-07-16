class_name Player
extends CharacterBody2D

@export_category("All sprites")
@export var australia_sprite: Texture
@export var brazil_sprite: Texture
@export var canada_sprite: Texture
@export var china_sprite: Texture
@export var germany_sprite: Texture
@export var japan_sprite: Texture
@export var poland_sprite: Texture
@export var south_africa_sprite: Texture
@export var uk_sprite: Texture
@export var united_states_sprite: Texture

var selected_sprite: Texture

var speed: float = 100.0
var starting_pos: float = 0.0
var distance_travelled: float = 0.0
var is_jumping: bool = false

var hurdle_slow_id: int = 0

var current_mud_speed_multiplier: float = 1.0
var current_hurdle_speed_multiplier: float = 1.0


func _ready() -> void:
	match GameData.selected_country:
		"Australia":
			selected_sprite = australia_sprite
		"Brazil":
			selected_sprite = brazil_sprite
		"Canada":
			selected_sprite = canada_sprite
		"China":
			selected_sprite = china_sprite
		"Germany":
			selected_sprite = germany_sprite
		"Japan":
			selected_sprite = japan_sprite
		"Poland":
			selected_sprite = poland_sprite
		"South Africa":
			selected_sprite = south_africa_sprite
		"UK":
			selected_sprite = uk_sprite
		"United States":
			selected_sprite = united_states_sprite
	$Sprite2D.texture = selected_sprite
	
	PlayerSignalBus.boost_speed_success.connect(_on_boost_speed_success)
	starting_pos = position.x

func _process(_delta: float) -> void:
	if velocity.x == 0:
		$AnimationPlayer.play("idle")
	if is_jumping == false:
		if velocity.x > 0:
			$AnimationPlayer.play("run")
		distance_travelled = (position.x - starting_pos) / 100.0
	if Input.is_action_just_pressed("action") == true:
		is_jumping = true
		$AnimationPlayer.play("jump")
	if is_jumping == true:
		$CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	speed = maxf(speed - GameData.player_slowdown_multiplier * delta, 0.0)
	
	if speed > GameData.player_max_speed:
		speed = GameData.player_max_speed
	
	if speed < 0.0:
		speed = 0.0
	
	var final_speed = (
		speed
		* current_mud_speed_multiplier
		* current_hurdle_speed_multiplier
	)
	
	velocity.x = final_speed
	$SpeedLabel.text = str("%0.2f" % final_speed)
	move_and_slide()


func _on_boost_speed_success() -> void:
	if speed < 1.0:
		speed = 2.0
	else:
		speed *= 1.5


func enter_mud() -> void:
	current_mud_speed_multiplier = clampf(
		GameData.mud_speed_multiplier,
		0.0,
		1.0
	)


func exit_mud() -> void:
	current_mud_speed_multiplier = 1.0


func hit_hurdle() -> void:
	current_hurdle_speed_multiplier *= clampf(
		GameData.hurdle_speed_multiplier,
		0.0,
		1.0
	)
	current_hurdle_speed_multiplier = maxf(
		current_hurdle_speed_multiplier,
		0.1
	)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "jump":
		is_jumping = false
		$CollisionShape2D.disabled = false
