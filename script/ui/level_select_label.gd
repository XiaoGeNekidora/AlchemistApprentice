extends Label

const ACTIVE_COLOR := Color(0.78, 0.42, 0.96)
const HOVER_COLOR := Color(1.18, 0.72, 0.24)

var _selected := false
var _hovered := false
var _tween: Tween


func _ready() -> void:
	_selected = Globals.last_visited_chapter == name
	modulate = ACTIVE_COLOR if _selected else Color.WHITE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	EventBus.select.connect(on_select)
	call_deferred("_set_pivot")


func _set_pivot() -> void:
	pivot_offset = size * 0.5


func _on_mouse_entered() -> void:
	_hovered = true
	_kill_tween()
	_tween = create_tween().set_parallel(true)
	_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate", HOVER_COLOR, 0.18)
	_tween.tween_property(self, "scale", Vector2(1.16, 0.94), 0.2)
	_tween.tween_property(self, "rotation", deg_to_rad(-2.0), 0.2)


func _on_mouse_exited() -> void:
	_hovered = false
	_animate_to_rest()


func on_select(chapter: String) -> void:
	_selected = chapter == name
	_kill_tween()
	if _selected:
		# A brief horizontal/vertical mismatch resembles an imperfect stamped numeral.
		_tween = create_tween()
		_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "scale", Vector2(1.28, 0.78), 0.13)
		_tween.parallel().tween_property(self, "rotation", deg_to_rad(4.0), 0.13)
		_tween.parallel().tween_property(self, "modulate", HOVER_COLOR, 0.1)
		_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "scale", Vector2.ONE, 0.4)
		_tween.parallel().tween_property(self, "rotation", 0.0, 0.32)
		_tween.parallel().tween_property(self, "modulate", ACTIVE_COLOR, 0.35)
	else:
		_animate_to_rest()


func _animate_to_rest() -> void:
	_kill_tween()
	var destination_color := HOVER_COLOR if _hovered else (ACTIVE_COLOR if _selected else Color.WHITE)
	_tween = create_tween().set_parallel(true)
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate", destination_color, 0.22)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.22)
	_tween.tween_property(self, "rotation", 0.0, 0.22)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not _selected:
			EventBus.select.emit(name)


func _kill_tween() -> void:
	if is_instance_valid(_tween):
		_tween.kill()
