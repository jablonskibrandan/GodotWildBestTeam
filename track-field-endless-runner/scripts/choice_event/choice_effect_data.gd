class_name ChoiceEffectData
extends Resource


enum MechanicType {
	MUD,
	HURDLE,
	PLAYER_SPEED,
	METRONOME,
	SPORTS_EVENTS
}


enum MechanicProperty {
	# Mud properties
	MUD_SLOWDOWN_RATE,
	MUD_MAX_SLOWDOWN,
	MUD_RECOVERY_RATE,
	MUD_SPAWN_RATE,

	# Hurdle properties
	HURDLE_SLOWDOWN_AMOUNT,
	HURDLE_SPAWN_RATE,

	# General speed properties
	PLAYER_SPEED_MULTIPLIER,

	# Metronome properties
	METRONOME_TIMING_WINDOW,
	METRONOME_SPEED,
	
	#Events
 	HUNDRED_METER_DASH_GOAL_TIME,
	HUNDRED_TEN_METER_HURDLES_GOAL_TIME,
	JAVELIN_THROW_GOAL_DISTANCE
}


enum Operation {
	ADD,
	MULTIPLY,
	SET
}

enum OptionType {
	BENEFIT,
	DEBUFF
}


@export var mechanic: MechanicType = MechanicType.MUD

@export var property: MechanicProperty = MechanicProperty.MUD_SLOWDOWN_RATE

@export var operation: Operation = Operation.MULTIPLY

@export var value: float = 1.0

@export var option_type: OptionType = OptionType.BENEFIT
