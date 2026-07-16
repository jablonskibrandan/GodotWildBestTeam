class_name ChoiceEffectManager
extends Node


func apply_option(option: ChoiceOptionData) -> void:
	if option == null:
		return

	for effect in option.effects:
		if effect == null:
			continue

		apply_effect(effect)


func apply_effect(effect: ChoiceEffectData) -> void:
	match effect.property:
		ChoiceEffectData.MechanicProperty.MUD_SLOWDOWN_RATE:
			GameData.mud_speed_multiplier = clampf(
				_apply_operation(
					GameData.mud_speed_multiplier,
					effect
				),
				0.0,
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
		
		ChoiceEffectData.MechanicProperty.HURDLE_SLOWDOWN_AMOUNT:
			GameData.hurdle_speed_multiplier = maxf(
				_apply_operation(
					GameData.hurdle_speed_multiplier,
					effect
				),
				0.25
			)

		_:
			
			return

	print("Applied choice effect. Property: %s, value: %s" % [effect.property, effect.value])


func _apply_operation(current_value: float, effect: ChoiceEffectData) -> float:
	match effect.operation:
		ChoiceEffectData.Operation.ADD:
			print(current_value + effect.value)
			return current_value + effect.value

		ChoiceEffectData.Operation.MULTIPLY:
			print(current_value * effect.value)
			return current_value * effect.value

		ChoiceEffectData.Operation.SET:
			print(effect.value)
			return effect.value

		_:
			push_warning("Unknown effect operation: %s" % effect.operation)

			return current_value
