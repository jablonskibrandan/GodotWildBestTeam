extends Node

var selected_country: String = ""

var score: int = 0
var score_multiplier_per_ms: int = 1000
var score_multiplier_per_cm: int = 1000
var mult: float = 1.0

var metronome_boost_area_width: float = 20.0
var metronome_line_speed: float = 100.0

var player_max_speed: float = 700.0
var player_slowdown_multiplier: float = 1.0
var mud_speed_multiplier: float = 1.0
var hurdle_speed_multiplier: float = 1.0

var added_100m_dash_goal_time: float = 0.0
var added_110m_hurdles_goal_time: float = 0.0
var added_javelin_distance_goal: float = 0.0

var loss_amount: int = 0
