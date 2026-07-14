class_name ChoiceEvent
extends Control

signal choice_finished(accepted: bool, timed_out: bool)

@export_category("Choice/Deal")
@export var title_text: String = "STRANGE OPPORTUNITY!"
@export_multiline var benefit_text: String = "BENEFIT: Stronger boosts"
@export_multiline var cost_text: String = "COST: Lose some current speed"

@export_category("Timer")
@export_range(0.5, 30.0, 0.5) var decision_time: float = 5.0

@onready var title_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/TitleLabel
)

@onready var benefit_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/BenefitLabel
)

@onready var cost_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/CostLabel
)

@onready var time_bar: TextureProgressBar = (
	$CenterContainer/PanelContainer/VBoxContainer/TimeBar
)

var remaining_time: float = 0.0
var resolved: bool = false
var paused_by_this_event: bool = false


func _ready() -> void:
	# Allows this UI to keep processing while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	title_label.text = title_text
	benefit_label.text = benefit_text
	cost_label.text = cost_text

	remaining_time = decision_time

	time_bar.min_value = 0.0
	time_bar.max_value = decision_time
	time_bar.value = decision_time


func _process(delta: float) -> void:
	if resolved:
		return

	remaining_time = maxf(remaining_time - delta, 0.0)
	time_bar.value = remaining_time

	if remaining_time <= 0.0:
		_resolve_choice(false, true)


func _input(event: InputEvent) -> void:
	if resolved:
		return

	if event.is_action_pressed("deal_accept"):
		get_viewport().set_input_as_handled()
		_resolve_choice(true, false)

	elif event.is_action_pressed("deal_deny"):
		get_viewport().set_input_as_handled()
		_resolve_choice(false, false)


func _resolve_choice(accepted: bool, timed_out: bool) -> void:
	if resolved:
		return

	resolved = true

	if paused_by_this_event:
		get_tree().paused = false
		paused_by_this_event = false

	choice_finished.emit(accepted, timed_out)
	queue_free()
