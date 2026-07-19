class_name Player
extends CharacterBody2D


@export_category("All Sprites")
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


@export_category("All Sounds")
@export var footsteps_sound: AudioStreamMP3
@export var footsteps_mud_sound: AudioStreamMP3
@export var jump_sound: AudioStreamMP3
@export var trip_sound: AudioStreamMP3
@export var hit_hurdle_sound: AudioStreamMP3


@export_category("Animation")
@export_range(0.1, 5.0, 0.1)
var run_animation_speed_multiplier: float = 2.0


@export_category("Metronome")
@export_range(0.0, 1.0, 0.05)
var failed_input_speed_multiplier: float = 0.65


@export_category("Monster Damage")
@export var maximum_loss: int = 3
@export var recovery_speed_after_hit: float = 10.0


@export_category("UI")
@export var loss_root: Control


@export_category("Mud Escape")
@export_range(1, 10, 1)
var mud_mashes_required: int = 5


signal monster_hit(loss_amount: int)
signal monster_game_over


var is_in_mud: bool = false
var mud_mash_count: int = 0
var current_mud_hazard: Hazard

var selected_sprite: Texture

var speed: float = 10.0
var starting_pos: float = 0.0
var distance_travelled: float = 0.0

var is_running: bool = false
var is_jumping: bool = false
var is_tripping: bool = false
var is_holding_javelin: bool = false

var javelin_angle: float = 0.0
var current_event: String = ""

var hurdle_slow_id: int = 0

var current_mud_speed_multiplier: float = 1.0
var current_hurdle_speed_multiplier: float = 1.0

var player_flash_tween: Tween


func _ready() -> void:
	PlayerSignalBus.boost_speed_fail.connect(
		_on_boost_speed_fail
	)

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

	PlayerSignalBus.boost_speed_success.connect(
		_on_boost_speed_success
	)

	PlayerSignalBus.trip_player.connect(
		_on_trip_player
	)

	starting_pos = position.x


func _process(_delta: float) -> void:
	if (
		is_in_mud
		and not is_instance_valid(current_mud_hazard)
	):
		_clear_mud_state()

	if velocity.x == 0:
		$AnimationPlayer.play("idle")

	if not is_jumping and not is_tripping:
		if velocity.x > 0:
			$AnimationPlayer.play("run")
			is_running = true
		else:
			is_running = false

	if Input.is_action_just_pressed("action"):
		if is_in_mud:
			_mash_out_of_mud()

		elif current_event == "110m":
			is_jumping = true

			$AnimationPlayer.play("jump")

			$AudioStreamPlayer.stream = jump_sound
			$AudioStreamPlayer.play()

	if is_jumping:
		$CollisionShape2D.disabled = true

	distance_travelled = (
		position.x - starting_pos
	) / 100.0

	GameData.player_position_x = position.x

	_update_animation_speed()


func _physics_process(delta: float) -> void:
	speed *= pow(
		GameData.player_speed_retention_per_second,
		delta
	)

	if speed < 0.01:
		speed = 0.0

	if speed > GameData.player_max_speed:
		speed = GameData.player_max_speed

	if speed < 0.0:
		speed = 0.0

	var final_speed := (
		speed
		* current_mud_speed_multiplier
	)

	velocity.x = final_speed
	GameData.player_current_speed = final_speed

	move_and_slide()


func _update_animation_speed() -> void:
	if $AnimationPlayer.current_animation != "run":
		$AnimationPlayer.speed_scale = 1.0
		return

	var safe_max_speed := maxf(
		GameData.player_max_speed,
		1.0
	)

	var player_speed_percentage := clampf(
		speed / safe_max_speed,
		0.5,
		1.0
	)

	$AnimationPlayer.speed_scale = (
		player_speed_percentage
		* run_animation_speed_multiplier
	)


func _on_boost_speed_success() -> void:
	if speed == 0:
		$AudioStreamPlayer.stream = footsteps_sound
		$AudioStreamPlayer.play()

	if speed < 1.0:
		speed = 10.0
	else:
		var new_speed := speed * 1.5

		if new_speed > 20.0:
			new_speed = 20.0

		speed += new_speed


func enter_mud(mud_hazard: Hazard) -> void:
	if is_in_mud:
		return

	is_in_mud = true
	mud_mash_count = 0
	current_mud_hazard = mud_hazard

	current_mud_speed_multiplier = clampf(
		GameData.mud_speed_multiplier,
		0.05,
		1.0
	)

	if footsteps_mud_sound != null:
		$AudioStreamPlayer.stream = footsteps_mud_sound
		$AudioStreamPlayer.play()

	print(
		"Entered mud. Mash Space ",
		mud_mashes_required,
		" times."
	)


func _mash_out_of_mud() -> void:
	if not is_in_mud:
		return

	mud_mash_count += 1

	print(
		"Mud mash: %d/%d"
		% [
			mud_mash_count,
			mud_mashes_required
		]
	)

	if mud_mash_count < mud_mashes_required:
		return

	# Free the player without deleting the puddle.
	_clear_mud_state()


func _clear_mud_state() -> void:
	is_in_mud = false
	mud_mash_count = 0
	current_mud_hazard = null
	current_mud_speed_multiplier = 1.0

	if footsteps_sound != null and is_running:
		$AudioStreamPlayer.stream = footsteps_sound
		$AudioStreamPlayer.play()


func hit_hurdle() -> void:
	$AudioStreamPlayer.stream = hit_hurdle_sound
	$AudioStreamPlayer.play()

	var applied_multiplier := clampf(
		GameData.hurdle_speed_multiplier,
		0.0,
		1.0
	)

	var previous_speed := speed

	speed *= applied_multiplier

	_player_flash(Color.WHITE)

	print(
		"HURDLE HIT | GameData multiplier: ",
		applied_multiplier,
		" | Speed: ",
		previous_speed,
		" -> ",
		speed
	)


func _on_trip_player() -> void:
	is_tripping = true

	$AnimationPlayer.play("trip")

	$AudioStreamPlayer.stream = trip_sound
	$AudioStreamPlayer.play()

	speed /= 2.0


func _on_animation_player_animation_finished(
	anim_name: StringName
) -> void:
	if anim_name == "jump":
		is_jumping = false
		$CollisionShape2D.disabled = false

	if anim_name == "trip":
		is_tripping = false


func _on_audio_stream_player_finished() -> void:
	var safe_speed := maxf(speed, 0.01)

	var wait_time := (
		GameData.player_max_speed
		/ safe_speed
	) / 10.0

	await get_tree().create_timer(
		clampf(wait_time, 0.5, 2.0)
	).timeout

	if is_running:
		$AudioStreamPlayer.stream = footsteps_sound
		$AudioStreamPlayer.pitch_scale = randf_range(
			0.8,
			1.2
		)
		$AudioStreamPlayer.play()
	else:
		$AudioStreamPlayer.pitch_scale = 1.0


func take_monster_hit() -> void:
	GameData.loss_amount += 1
	loss_root.add_loss()

	print(
		"Monster hit! Loss amount: ",
		GameData.loss_amount
	)

	monster_hit.emit(GameData.loss_amount)

	speed = maxf(
		speed,
		GameData.player_max_speed * 0.75
	)

	_player_flash(Color.RED)

	if GameData.loss_amount >= maximum_loss:
		print(
			"PLAYER HAS REACHED MAXIMUM RED X MARKS"
		)

		monster_game_over.emit()


func _on_boost_speed_fail() -> void:
	var previous_speed := speed

	speed *= clampf(
		failed_input_speed_multiplier,
		0.0,
		1.0
	)

	print(
		"Metronome failed | Speed: ",
		previous_speed,
		" -> ",
		speed
	)


func add_metronome_streak_boost(
	boost_amount: float
) -> void:
	var previous_speed := speed

	speed = minf(
		speed + maxf(boost_amount, 0.0),
		GameData.player_max_speed
	)

	print(
		"Eight-hit streak bonus | Speed: ",
		previous_speed,
		" -> ",
		speed
	)


func _player_flash(color: Color) -> void:
	var player_sprite := $Sprite2D as Sprite2D

	if player_sprite == null:
		return

	if player_flash_tween != null:
		player_flash_tween.kill()

	var normal_color := Color.WHITE

	player_sprite.modulate = normal_color

	player_flash_tween = create_tween()
	player_flash_tween.set_loops(4)

	player_flash_tween.tween_property(
		player_sprite,
		"modulate",
		color,
		0.08
	)

	player_flash_tween.tween_property(
		player_sprite,
		"modulate",
		normal_color,
		0.08
	)
