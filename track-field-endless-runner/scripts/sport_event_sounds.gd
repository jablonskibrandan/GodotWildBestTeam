extends AudioStreamPlayer


@export_category("Event Action Sounds")
@export var gunshot: AudioStream
@export var javelin_throw: AudioStream


@export_category("Event Result Sounds")
@export var event_success: AudioStream
@export var event_failure: AudioStream


func _ready() -> void:
	if not AudioSignalBus.play_gunshot.is_connected(
		_on_play_gunshot
	):
		AudioSignalBus.play_gunshot.connect(
			_on_play_gunshot
		)

	if not AudioSignalBus.play_javelin_throw.is_connected(
		_on_play_javelin_throw
	):
		AudioSignalBus.play_javelin_throw.connect(
			_on_play_javelin_throw
		)


func _on_play_gunshot() -> void:
	_play_sound(gunshot)


func _on_play_javelin_throw() -> void:
	_play_sound(javelin_throw)


func play_event_success() -> void:
	_play_sound(event_success)


func play_event_failure() -> void:
	_play_sound(event_failure)


func _play_sound(sound: AudioStream) -> void:
	if sound == null:
		push_warning(
			"SportEventSounds was asked to play "
			+ "an unassigned sound."
		)
		return

	stop()
	stream = sound
	play()
