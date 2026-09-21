extends Label

signal clicked

var _hover_tween: Tween


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(enter)
	mouse_exited.connect(exit)
	gui_input.connect(click)
	call_deferred("_set_pivot")


func _set_pivot() -> void:
	pivot_offset = size * 0.5


func click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()


func enter() -> void:
	_kill_hover_tween()
	_hover_tween = create_tween().set_parallel(true)
	_hover_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2(1.055, 1.055), 0.2)
	_hover_tween.tween_property(self, "rotation", deg_to_rad(-1.2), 0.2)
	_hover_tween.tween_property(self, "self_modulate", Color(1.12, 0.84, 0.42, 1.0), 0.16)
	if label_settings:
		_hover_tween.tween_property(label_settings, "shadow_size", 10, 0.12)


func exit() -> void:
	_kill_hover_tween()
	_hover_tween = create_tween().set_parallel(true)
	_hover_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	_hover_tween.tween_property(self, "rotation", 0.0, 0.2)
	_hover_tween.tween_property(self, "self_modulate", Color.WHITE, 0.2)
	if label_settings:
		_hover_tween.tween_property(label_settings, "shadow_size", 0, 0.12)


func _kill_hover_tween() -> void:
	if is_instance_valid(_hover_tween):
		_hover_tween.kill()
