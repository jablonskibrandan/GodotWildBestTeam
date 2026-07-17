extends Node

@export_category("Game Objects")
@export var player: Player
@export var hurdle_template: PackedScene
@export var start_line_template: PackedScene
@export var finish_line_template: PackedScene
@export var sports_objects_root: Node2D
@export var javelin_template: PackedScene
@export_category("UI Objects")
@export var event_name_label_root: Control
@export var event_name_label: RichTextLabel
@export var event_goal_root: HBoxContainer
@export var event_goal_text: RichTextLabel 
@export var event_goal_amount: RichTextLabel 
@export var player_score_root: HBoxContainer
@export var player_score_text: RichTextLabel
@export var player_score_amount: RichTextLabel
@export var countdown_root: Control
@export var countdown_text: RichTextLabel
@export var event_results_root: Control
@export var score_difference_root: HBoxContainer
@export var score_difference_text: RichTextLabel
@export var score_difference_amount: RichTextLabel
@export var score_explanation_root: HBoxContainer
@export var score_explanation_text: RichTextLabel
@export var score_explanation_amount: RichTextLabel
@export var total_score_root: HBoxContainer
@export var total_score_amount: RichTextLabel
@export var loss_root: Control

var event_start_pos: float = 1.0
var event_started: bool = false
var event_score: float = 0.0

var current_event_index: int = 0

var distance_between_hurdles: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SportEventSignalBus.event_name_label_finished_flashing.connect(_on_event_name_label_finished_flashing)
	SportEventSignalBus.event_goal_label_finished_flashing.connect(_on_event_goal_label_finished_flashing)
	SportEventSignalBus.player_score_label_finished_flashing.connect(_on_player_score_label_finished_flashing)
	SportEventSignalBus.start_line_passed.connect(_on_start_line_passed)
	SportEventSignalBus.finish_event.connect(_on_finish_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if event_started == false:
		if event_start_pos <= player.distance_travelled:
			spawn_event()

func spawn_event() -> void:
	event_started = true
	var rand = randi_range(1, EventList.event_list.size())
	current_event_index = 3
	start_event()

func _on_start_line_passed() -> void:
	pass

func start_event() -> void:
	display_event_name()

func display_event_name() -> void:
	event_name_label_root.visible = true
	event_name_label.text = str(EventList.event_list[current_event_index]["name"], "!")
	event_name_label.get_node("TurnOffFlashingTimer").start()

func _on_event_name_label_finished_flashing() -> void:
	display_win_conditions()

func _on_event_goal_label_finished_flashing() -> void:
	display_player_score()

func _on_player_score_label_finished_flashing() -> void:
	play_event()
	event_goal_root.visible = true
	player_score_root.visible = true

func display_win_conditions() -> void:
	if EventList.event_list[current_event_index]["is_time_based_event"] == true:
		event_goal_text.text = str("Time to beat:")
		event_goal_amount.text = str(EventList.event_list[current_event_index]["score_to_beat"])
	elif EventList.event_list[current_event_index]["is_distance_based_event"] == true:
		event_goal_text.text = str("Distance to beat:")
		event_goal_amount.text = str(EventList.event_list[current_event_index]["score_to_beat"])
	event_goal_root.visible = true
	event_goal_root.get_node("FlashingTimer").start()
	event_goal_root.get_node("TurnOffFlashingTimer").start()

func display_player_score() -> void:
	if EventList.event_list[current_event_index]["is_time_based_event"] == true:
		player_score_text.text = str("Your Time:")
		player_score_amount.text = str("00.00")
	elif EventList.event_list[current_event_index]["is_distance_based_event"] == true:
		player_score_text.text = str("Your Distance:")
		player_score_amount.text = str("0")
	player_score_root.visible = true
	player_score_root.get_node("FlashingTimer").start()
	player_score_root.get_node("TurnOffFlashingTimer").start()

func play_event() -> void:
	match current_event_index:
		1:
			$RunEventManager.time = 0.0
			$RunEventManager.starting_distance = player.distance_travelled + 15.0
			$RunEventManager.race_length = 100.0
			$RunEventManager.finish_distance = $RunEventManager.starting_distance + $RunEventManager.race_length
			$RunEventManager.event_in_progress = true
			var start_line: Area2D = start_line_template.instantiate()
			start_line.position = Vector2($RunEventManager.starting_distance * 100.0, 820)
			sports_objects_root.add_child(start_line)
			var finish_line: Area2D = finish_line_template.instantiate()
			finish_line.position = Vector2($RunEventManager.finish_distance * 100.0, 820)
			sports_objects_root.add_child(finish_line)
			player.current_event = "100m"
		2:
			$RunEventManager.time = 0.0
			$RunEventManager.starting_distance = player.distance_travelled + 15.0
			$RunEventManager.race_length = 110.0
			$RunEventManager.finish_distance = $RunEventManager.starting_distance + $RunEventManager.race_length
			$RunEventManager.event_in_progress = true
			var start_line: Area2D = start_line_template.instantiate()
			start_line.position = Vector2($RunEventManager.starting_distance * 100.0, 820)
			sports_objects_root.add_child(start_line)
			var finish_line: Area2D = finish_line_template.instantiate()
			finish_line.position = Vector2($RunEventManager.finish_distance * 100.0, 820)
			sports_objects_root.add_child(finish_line)
			for i in range(10):
				var hurdle: ObstacleMove = hurdle_template.instantiate()
				hurdle.position = Vector2(($RunEventManager.starting_distance * 100.0 + (10.0 * (100 * (i + 1)))), 820)
				sports_objects_root.add_child(hurdle)
			player.current_event = "110m"
		3:
			$DistanceEventManager.distance = 0.0
			var rand = randi_range(15, 30)
			$DistanceEventManager.start_line_location = player.distance_travelled + rand
			$DistanceEventManager.event_in_progress = true
			var start_line: Area2D = start_line_template.instantiate()
			start_line.position = Vector2($DistanceEventManager.start_line_location * 100.0, 820)
			sports_objects_root.add_child(start_line)
			var javelin: Sprite2D = javelin_template.instantiate()
			javelin.position = Vector2(0, -90)
			javelin.rotation_degrees = -30.0
			player.add_child(javelin)
			player.is_holding_javelin = true
			$DistanceEventManager.javelin = javelin
			player.current_event = "javelin"

func _on_finish_event() -> void:
	if current_event_index == 1 or current_event_index == 2:
		if $RunEventManager.time <= EventList.event_list[current_event_index]["score_to_beat"]:
			add_score_and_display_results()
			increase_event_difficulty()
			reset_state()
			clean_up_objects()
			calculate_new_event_pos()
		else:
			add_loss()
			await get_tree().create_timer(3.0).timeout
			reset_state()
			clean_up_objects()
			calculate_new_event_pos()
	elif current_event_index == 3:
		if $DistanceEventManager.distance >= EventList.event_list[current_event_index]["score_to_beat"]:
			add_score_and_display_results()
			increase_event_difficulty()
			reset_state()
			clean_up_objects()
			calculate_new_event_pos()
		else:
			add_loss()
			await get_tree().create_timer(3.0).timeout
			reset_state()
			clean_up_objects()
			calculate_new_event_pos()

func reset_state() -> void:
	$RunEventManager.event_in_progress = false
	$DistanceEventManager.event_in_progress = false
	event_started = false
	event_goal_root.visible = false
	player_score_root.visible = false
	current_event_index = 0
	player.current_event = ""

func clean_up_objects() -> void:
	for child in sports_objects_root.get_children():
		child.queue_free()

func calculate_new_event_pos() -> void:
	var rand = randf_range(GameData.event_distance_min, GameData.event_distance_max)
	event_start_pos = player.distance_travelled + rand

func add_score_and_display_results() -> void:
	if EventList.event_list[current_event_index]["is_time_based_event"] == true:
		event_score = EventList.event_list[current_event_index]["score_to_beat"] - $RunEventManager.time
		score_difference_amount.text = str("%0.2f" % event_score)
		event_score = roundi(event_score * GameData.score_multiplier_per_ms * GameData.mult)
	elif EventList.event_list[current_event_index]["is_distance_based_event"] == true:
		event_score = $DistanceEventManager.distance - EventList.event_list[current_event_index]["score_to_beat"]
		score_difference_amount.text = str("%0.2f" % event_score)
		event_score = roundi(event_score * GameData.score_multiplier_per_cm * GameData.mult)
	GameData.score = int(GameData.score + event_score)
	
	if EventList.event_list[current_event_index]["is_time_based_event"] == true:
		score_difference_text.text = "Time Difference:"
		score_explanation_text.text = "Points per ms:"
		score_explanation_amount.text = str(GameData.score_multiplier_per_ms)
	elif EventList.event_list[current_event_index]["is_distance_based_event"] == true:
		score_difference_text.text = "Distance Difference:"
		score_explanation_text.text = "Points per cm:"
		score_explanation_amount.text = str(GameData.score_multiplier_per_cm)
	
	total_score_amount.text = str(int(event_score))
	
	await get_tree().create_timer(1.0).timeout
	score_difference_root.visible = true
	await get_tree().create_timer(1.0).timeout
	score_explanation_root.visible = true
	await get_tree().create_timer(1.0).timeout
	total_score_root.visible = true
	await get_tree().create_timer(3.0).timeout
	score_difference_root.visible = false
	score_explanation_root.visible = false
	total_score_root.visible = false

func increase_event_difficulty() -> void:
	if EventList.event_list[current_event_index]["is_time_based_event"] == true:
		EventList.event_list[current_event_index]["score_to_beat"] = EventList.event_list[current_event_index]["score_to_beat"] * 0.95
	elif EventList.event_list[current_event_index]["is_distance_based_event"] == true:
		EventList.event_list[current_event_index]["score_to_beat"] = EventList.event_list[current_event_index]["score_to_beat"] * 1.20

func add_loss() -> void:
	event_goal_root.visible = true
	player_score_root.visible = true
	GameData.loss_amount = GameData.loss_amount + 1
	loss_root.add_loss()
	await get_tree().create_timer(3.0).timeout
	PlayerSignalBus.trip_player.emit()
