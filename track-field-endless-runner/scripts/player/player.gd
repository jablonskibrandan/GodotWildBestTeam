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
@export_category("Physics")
@export var max_speed: float = 700.0

var selected_sprite: Texture

var speed: float = 10.0
var starting_pos: float = 0.0
var distance_travelled: float = 0.0
var is_jumping: bool = false

var slow_down_multiplier: float = 1.0
var mud_speed_multiplier: float = 1.0
var hurdle_speed_multiplier: float = 1.0

var hurdle_slow_id: int = 0


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
	if Input.is_action_just_pressed("jump") == true:
		is_jumping = true
		$AnimationPlayer.play("jump")
	if is_jumping == true:
		$CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	speed = maxf(speed - slow_down_multiplier * delta, 0.0)
	
	if speed > max_speed:
		speed = max_speed
	
	if speed < 0.0:
		speed = 0.0
	
	var final_speed := (
		speed
		* mud_speed_multiplier
		* hurdle_speed_multiplier
	)
	
	velocity.x = final_speed
	$SpeedLabel.text = str("%0.2f" % final_speed)
	move_and_slide()


func _on_boost_speed_success() -> void:
	speed *= 1.5


func enter_mud(multiplier: float = 0.6) -> void:
	mud_speed_multiplier = clampf(multiplier, 0.0, 1.0)


func exit_mud() -> void:
	mud_speed_multiplier = 1.0


func hit_hurdle(multiplier: float = 0.5, duration: float = 2.0) -> void:
	hurdle_slow_id += 1
	var current_slow_id := hurdle_slow_id

	hurdle_speed_multiplier = clampf(multiplier, 0.0, 1.0)

	await get_tree().create_timer(duration).timeout

	if current_slow_id == hurdle_slow_id:
		hurdle_speed_multiplier = 1.0


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "jump":
		is_jumping = false
		$CollisionShape2D.disabled = false
