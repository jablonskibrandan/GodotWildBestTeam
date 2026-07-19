class_name ChoiceEffectManager
extends Node


func apply_option(option: ChoiceOptionData) -> void:
	if option == null:
		return

	var selected_option_type: ChoiceEffectData.OptionType
	var found_valid_effect := false

	for effect in option.effects:
		if effect == null:
			continue

		apply_effect(effect)

		if not found_valid_effect:
			selected_option_type = effect.option_type
			found_valid_effect = true
		elif effect.option_type != selected_option_type:
			push_warning(
				"Choice option contains effects with different option types."
			)

	# Change GameData.mult only once for the entire selected choice.
	if found_valid_effect:
		_apply_option_type_multiplier(selected_option_type)


func apply_effect(effect: ChoiceEffectData) -> void:
	match effect.property:
		ChoiceEffectData.MechanicProperty.MUD_SPAWN_RATE:
			GameData.mud_spawn_rate = clampf(
				_apply_operation(
					GameData.mud_spawn_rate,
					effect
				),
				0.1,
				3.0
			)

		ChoiceEffectData.MechanicProperty.MUD_SLOWDOWN_RATE:
			GameData.mud_speed_multiplier = clampf(
				_apply_operation(
					GameData.mud_speed_multiplier,
					effect
				),
				0.1,
				1.0
			)

		ChoiceEffectData.MechanicProperty.HURDLE_SLOWDOWN_AMOUNT:
			GameData.hurdle_speed_multiplier = clampf(
				_apply_operation(
					GameData.hurdle_speed_multiplier,
					effect
				),
				0.25,
				1.0
			)

		ChoiceEffectData.MechanicProperty.PLAYER_SPEED_MULTIPLIER:
			GameData.player_slowdown_multiplier = maxf(
				_apply_operation(
					GameData.player_slowdown_multiplier,
					effect
				),
				0.01
			)

		ChoiceEffectData.MechanicProperty.METRONOME_TIMING_WINDOW:
			GameData.metronome_boost_area_width = maxf(
				_apply_operation(
					GameData.metronome_boost_area_width,
					effect
				),
				1.0
			)

		ChoiceEffectData.MechanicProperty.METRONOME_SPEED:
			GameData.metronome_line_speed = maxf(
				_apply_operation(
					GameData.metronome_line_speed,
					effect
				),
				0.01
			)

		ChoiceEffectData.MechanicProperty.HUNDRED_METER_DASH_GOAL_TIME:
			GameData.added_100m_dash_goal_time = _apply_operation(
				GameData.added_100m_dash_goal_time,
				effect
			)

		ChoiceEffectData.MechanicProperty.HUNDRED_TEN_METER_HURDLES_GOAL_TIME:
			GameData.added_110m_hurdles_goal_time = _apply_operation(
				GameData.added_110m_hurdles_goal_time,
				effect
			)

		ChoiceEffectData.MechanicProperty.JAVELIN_THROW_GOAL_DISTANCE:
			GameData.added_javelin_distance_goal = _apply_operation(
				GameData.added_javelin_distance_goal,
				effect
			)

		_:
			push_warning(
				"Choice property has not been implemented: %s"
				% effect.property
			)
			return

	print(
		"Applied choice effect. Property: %s, value: %s"
		% [effect.property, effect.value]
	)


func _apply_option_type_multiplier(
	option_type: ChoiceEffectData.OptionType
) -> void:
	match option_type:
		ChoiceEffectData.OptionType.BENEFIT:
			# Benefits make the score multiplier smaller.
			GameData.mult = maxf(GameData.mult - 0.25, 0.0)

		ChoiceEffectData.OptionType.DEBUFF:
			# Debuffs make the score multiplier larger.
			GameData.mult += 0.25

	print(
		"Choice type applied: %s. New GameData.mult: %.2f"
		% [option_type, GameData.mult]
	)


func _apply_operation(
	current_value: float,
	effect: ChoiceEffectData
) -> float:
	var new_value := current_value

	match effect.operation:
		ChoiceEffectData.Operation.ADD:
			new_value = current_value + effect.value

		ChoiceEffectData.Operation.MULTIPLY:
			new_value = current_value * effect.value

		ChoiceEffectData.Operation.SET:
			new_value = effect.value

		_:
			push_warning(
				"Unknown effect operation: %s"
				% effect.operation
			)

	print(
		"Effect value changed from %.2f to %.2f"
		% [current_value, new_value]
	)

	return new_value
