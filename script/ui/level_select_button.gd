extends Button

@export var level: String

var _motion_tween: Tween
var _ready_for_input := false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	call_deferred("_set_pivot")


func _set_pivot() -> void:
	pivot_offset = size * 0.5


func prepare_for_reveal() -> void:
	_kill_motion()
	_ready_for_input = false
	disabled = true
	pivot_offset = size * 0.5
	modulate = Color(1.25, 0.65, 0.2, 0.0)
	scale = Vector2(0.08, 0.08)
	rotation = _ritual_angle() * 2.5


func reveal(delay: float) -> void:
	_kill_motion()
	_motion_tween = create_tween()
	_motion_tween.tween_interval(delay)
	_motion_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2(1.15, 0.88), 0.32)
	_motion_tween.parallel().tween_property(self, "rotation", -_ritual_angle() * 0.35, 0.32)
	_motion_tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.22)
	_motion_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2.ONE, 0.28)
	_motion_tween.parallel().tween_property(self, "rotation", 0.0, 0.24)
	_motion_tween.tween_callback(_enable_after_reveal)


func conceal() -> void:
	_kill_motion()
	_ready_for_input = false
	disabled = true
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_motion_tween.tween_property(self, "scale", Vector2(0.72, 0.72), 0.18)
	_motion_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_motion_tween.tween_property(self, "rotation", -_ritual_angle(), 0.18)


func _enable_after_reveal() -> void:
	_ready_for_input = true
	disabled = false


func _on_mouse_entered() -> void:
	if not _ready_for_input:
		return
	_kill_motion()
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2(1.17, 1.17), 0.2)
	_motion_tween.tween_property(self, "rotation", _ritual_angle() * 0.28, 0.2)
	_motion_tween.tween_property(self, "self_modulate", Color(1.3, 0.72, 0.28), 0.17)


func _on_mouse_exited() -> void:
	if not _ready_for_input:
		return
	_kill_motion()
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2.ONE, 0.28)
	_motion_tween.tween_property(self, "rotation", 0.0, 0.28)
	_motion_tween.tween_property(self, "self_modulate", Color.WHITE, 0.2)


func _on_pressed() -> void:
	if not _ready_for_input or SceneTransition.is_busy():
		return
	if not Globals.all_levels.has(level):
		push_error("Unknown level: %s" % level)
		return
	_ready_for_input = false
	disabled = true
	Globals.current_level = Globals.all_levels[level].new()
	SceneTransition.change_scene("res://game.tscn")


func _ritual_angle() -> float:
	var number := level.to_int()
	var direction := -1.0 if number % 2 == 0 else 1.0
	return deg_to_rad(direction * (5.0 + number % 4))


func _kill_motion() -> void:
	if is_instance_valid(_motion_tween):
		_motion_tween.kill()
