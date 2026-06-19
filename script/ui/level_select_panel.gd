extends Control

func _ready() -> void:
	# Set initial state instantly based on last visited chapter (no animation on first load)
	if Globals.last_visited_chapter != self.name:
		self.modulate = Color(1, 1, 1, 0)
	else:
		self.modulate = Color(1, 1, 1, 1)
	EventBus.select.connect(on_select)

func on_select(name: String):
	if name != self.name:
		var tw = get_tree().create_tween()
		tw.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	else:
		var tw = get_tree().create_tween()
		tw.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

func _process(delta: float) -> void:
	self.visible = self.modulate.a != 0
