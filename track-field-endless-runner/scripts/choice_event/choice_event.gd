class_name ChoiceEvent
extends Control


signal choice_finished(selected_option: ChoiceOptionData, timed_out: bool)

@export var game_state_manager: GameStateManager
@export_category("Timer")
@export_range(0.5, 30.0, 0.5)
var decision_time: float = 5.0


@onready var title_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/TitleLabel
)

@onready var option_a_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/BenefitLabel
)

@onready var option_b_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/CostLabel
)

var choice_data: ChoiceEventData

var remaining_time: float = 0.0
var resolved: bool = true
var paused_by_this_event: bool = false


func _ready() -> void:
	# Keeps the choice window running if gameplay is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()

	set_process(false)
	set_process_input(false)


func show_choice(selected_data: ChoiceEventData) -> void:
	if selected_data == null:
		push_error("ChoiceEvent received null ChoiceEventData.")
		return

	choice_data = selected_data
	resolved = false

	_populate_choice_data()
	_reset_timer()

	show()

	set_process(true)
	set_process_input(true)


func _populate_choice_data() -> void:
	title_label.text = choice_data.event_text

	if choice_data.option_a != null:
		option_a_label.text = ("Option 1: " + choice_data.option_a.option_text)
	else:
		option_a_label.text = "OPTION A UNAVAILABLE"

	if choice_data.option_b != null:
		option_b_label.text = ("Option 2: " + choice_data.option_b.option_text)
	else:
		option_b_label.text = "OPTION B UNAVAILABLE"


func _reset_timer() -> void:
	remaining_time = decision_time


func _process(delta: float) -> void:
	if not game_state_manager.game_over:
		if resolved:
			return

		remaining_time = maxf(remaining_time - delta, 0.0)

		if remaining_time <= 0.0:
			_resolve_choice(null, true)


func _input(event: InputEvent) -> void:
	if resolved or not visible:
		return

	if choice_data == null:
		return

	if event.is_action_pressed("option1"):
		get_viewport().set_input_as_handled()

		_resolve_choice(choice_data.option_a, false)

	elif event.is_action_pressed("option2"):
		get_viewport().set_input_as_handled()

		_resolve_choice(choice_data.option_b, false)


func _resolve_choice(selected_option: ChoiceOptionData, timed_out: bool) -> void:
	if resolved:
		return

	resolved = true

	if paused_by_this_event:
		get_tree().paused = false
		paused_by_this_event = false

	hide()

	set_process(false)
	set_process_input(false)

	choice_finished.emit(selected_option, timed_out)
