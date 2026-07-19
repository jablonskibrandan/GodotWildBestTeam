extends Node

var selected_country: String = ""

var player_position_x: float = 0.0

var score: int = 0
var score_multiplier_per_ms: int = 1000
var score_multiplier_per_cm: int = 1000
var mult: float = 1.0

var metronome_boost_area_width: float = 20.0
var metronome_line_speed: float = 1.0

var player_current_speed: float = 0.0
var player_max_speed: float = 700.0
var player_slowdown_multiplier: float = 1.0

var mud_spawn_rate: float = 1.0
var hurdle_spawn_rate: float = 1.0
var mud_speed_multiplier: float = 0.20
var hurdle_speed_multiplier: float = 0.65

var javelin_gauge_speed: float = 200.0

var added_100m_dash_goal_time: float = 0.0
var added_110m_hurdles_goal_time: float = 0.0
var added_javelin_distance_goal: float = 0.0

var event_distance_min: float = 100.0
var event_distance_max: float = 300.0

# This is just a little hack/workaround. Don't try this at home,
# kids! 
var music_playback_position: float = 0.0
var should_resume_music: bool = false
var scary_music_non_loop_playing: bool = false
var scary_music_loop_playing: bool = false 

# Change this if we want the exponential speed to be
# harsher or mor subtle

var player_speed_retention_per_second: float = 0.98

var loss_amount: int = 0

var has_witnessed_the_horrors: bool = false
