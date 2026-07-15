extends RichTextLabel

func _process(_delta: float) -> void:
	self.text = str("%0.2f" % $"../../Player".speed)
