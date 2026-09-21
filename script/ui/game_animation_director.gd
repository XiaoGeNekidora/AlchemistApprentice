extends Node
class_name GameAnimationDirector

## Presentation-only animation controller for the game screen.
## GameRoot owns rules and state; this node only receives visual state changes.

const HINT_OPENING_OFFSET := Vector2(96.0, 0.0)

var _root: Control
var _prepared := false
var _opening_finished := false
var _action_available := false
var _action_tween: Tween
var _hint_tween: Tween
var _upb_tween: Tween
var _ambient_tweens: Array[Tween] = []
var _input_blocker: ColorRect

var _base_positions: Dictionary = {}
var _base_scales: Dictionary = {}
var _base_rotations: Dictionary = {}


func _ready() -> void:
	_root = get_parent() as Control
	_cache_pose($"../Mission")
	_cache_pose($"../TextureRect2")
	_cache_pose($"../Inventory")
	_cache_pose($"../Methods")
	_cache_pose($"../HintText")
	_cache_pose($"../ButtonList")
	_cache_pose($"../LevelName")
	_cache_pose($"../TargetItem")
	_cache_pose($"../TransformButton")
	_cache_pose($"../Seal")

	_setup_button_motion($"../ButtonList/BackBtn", -1.0)
	_setup_button_motion($"../ButtonList/RetryBtn", 1.0)
	_setup_button_motion($"../ButtonList/NextButton", -1.0)
	_setup_action_button_motion()


func prepare_opening() -> void:
	if _prepared:
		return
	_prepared = true
	_stop_ambient()
	_create_input_blocker()

	var background := $"../bg" as TextureRect
	background.pivot_offset = background.size * 0.5
	background.modulate.a = 0.18
	background.scale = Vector2(1.045, 1.045)

	var mission := $"../Mission" as TextureRect
	mission.pivot_offset = mission.size * Vector2(0.18, 0.12)
	mission.position = _position_of(mission) + Vector2(-86.0, -54.0)
	mission.scale = _scale_of(mission) * 0.84
	mission.rotation = _rotation_of(mission) + deg_to_rad(-6.0)
	mission.modulate.a = 0.0
	var mission_text := $"../Mission/RichTextLabel" as RichTextLabel
	mission_text.visible_ratio = 0.0

	var halo := $"../TextureRect2" as TextureRect
	halo.pivot_offset = halo.size * 0.5
	halo.scale = _scale_of(halo) * 0.12
	halo.rotation = deg_to_rad(-42.0)
	halo.modulate = Color(1.35, 0.72, 0.28, 0.0)

	var inventory := $"../Inventory" as TextureRect
	inventory.pivot_offset = inventory.size * 0.5
	inventory.position = _position_of(inventory) + Vector2(-36.0, 148.0)
	inventory.rotation = _rotation_of(inventory) + deg_to_rad(13.0)
	inventory.scale = _scale_of(inventory) * 0.72
	inventory.modulate.a = 0.0

	var methods := $"../Methods" as HBoxContainer
	methods.position = _position_of(methods) + Vector2(0.0, 74.0)
	methods.scale = _scale_of(methods) * 0.78
	methods.rotation = deg_to_rad(2.5)
	methods.modulate.a = 0.0
	for child in methods.get_children():
		if child.has_method("prepare_for_reveal"):
			child.prepare_for_reveal()

	var hint := $"../HintText" as Label
	hint.position = _position_of(hint) + HINT_OPENING_OFFSET
	hint.modulate.a = 0.0

	var button_list := $"../ButtonList" as HBoxContainer
	button_list.position = _position_of(button_list) + Vector2(0.0, 78.0)
	button_list.modulate.a = 0.0

	var level_name := $"../LevelName" as Label
	level_name.position = _position_of(level_name) + Vector2(-34.0, 0.0)
	level_name.modulate.a = 0.0

	var target := $"../TargetItem" as Control
	target.pivot_offset = target.size * 0.5
	target.scale = _scale_of(target) * 0.08
	target.rotation = deg_to_rad(-24.0)
	target.modulate = Color(1.32, 0.7, 0.28, 0.0)

	var action := $"../TransformButton" as Button
	action.pivot_offset = action.size * 0.5
	action.position = _position_of(action) + Vector2(330.0, 0.0)
	action.scale = _scale_of(action) * Vector2(0.82, 1.08)
	action.modulate.a = 0.0

	$"../UPBInfo".modulate.a = 0.0
	$"../UPBInfo".hide()


func play_opening() -> void:
	if not _prepared:
		prepare_opening()

	var background := $"../bg" as TextureRect
	var background_tween := create_tween().set_parallel(true)
	background_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	background_tween.tween_property(background, "modulate:a", 1.0, 0.9)
	background_tween.tween_property(background, "scale", Vector2.ONE, 1.35)

	var mission := $"../Mission" as TextureRect
	var mission_tween := create_tween()
	mission_tween.tween_interval(0.08)
	mission_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	mission_tween.tween_property(mission, "position", _position_of(mission) + Vector2(7.0, 4.0), 0.68)
	mission_tween.parallel().tween_property(mission, "scale", _scale_of(mission) * Vector2(1.025, 0.985), 0.68)
	mission_tween.parallel().tween_property(mission, "rotation", deg_to_rad(0.8), 0.68)
	mission_tween.parallel().tween_property(mission, "modulate:a", 1.0, 0.32)
	mission_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	mission_tween.tween_property(mission, "position", _position_of(mission), 0.2)
	mission_tween.parallel().tween_property(mission, "scale", _scale_of(mission), 0.2)
	mission_tween.parallel().tween_property(mission, "rotation", _rotation_of(mission), 0.2)

	var mission_text := $"../Mission/RichTextLabel" as RichTextLabel
	var writing_tween := create_tween()
	writing_tween.tween_interval(0.48)
	writing_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	writing_tween.tween_property(mission_text, "visible_ratio", 1.0, 0.82)

	var halo := $"../TextureRect2" as TextureRect
	var halo_tween := create_tween()
	halo_tween.tween_interval(0.2)
	halo_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	halo_tween.tween_property(halo, "scale", _scale_of(halo) * 1.06, 0.9)
	halo_tween.parallel().tween_property(halo, "rotation", deg_to_rad(8.0), 0.9)
	halo_tween.parallel().tween_property(halo, "modulate", Color(1.0, 0.88, 0.7, 0.72), 0.42)
	halo_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	halo_tween.tween_property(halo, "scale", _scale_of(halo), 0.24)
	halo_tween.parallel().tween_property(halo, "rotation", _rotation_of(halo), 0.24)

	var inventory := $"../Inventory" as TextureRect
	var inventory_tween := create_tween()
	inventory_tween.tween_interval(0.42)
	inventory_tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	inventory_tween.tween_property(inventory, "position", _position_of(inventory), 0.68)
	inventory_tween.parallel().tween_property(inventory, "rotation", _rotation_of(inventory), 0.68)
	inventory_tween.parallel().tween_property(inventory, "scale", _scale_of(inventory), 0.68)
	inventory_tween.parallel().tween_property(inventory, "modulate:a", 1.0, 0.28)

	var methods := $"../Methods" as HBoxContainer
	var methods_tween := create_tween()
	methods_tween.tween_interval(0.5)
	methods_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	methods_tween.tween_property(methods, "position", _position_of(methods), 0.58)
	methods_tween.parallel().tween_property(methods, "scale", _scale_of(methods), 0.58)
	methods_tween.parallel().tween_property(methods, "rotation", _rotation_of(methods), 0.58)
	methods_tween.parallel().tween_property(methods, "modulate:a", 1.0, 0.3)
	var method_index := 0
	for child in methods.get_children():
		if child.visible and child.has_method("reveal"):
			child.reveal(0.6 + method_index * 0.055)
			method_index += 1

	_reveal_simple($"../HintText", 0.72, Vector2.ZERO)
	_reveal_simple($"../ButtonList", 0.86, Vector2.ZERO)
	_reveal_simple($"../LevelName", 0.68, Vector2.ZERO)

	var target := $"../TargetItem" as Control
	var target_tween := create_tween()
	target_tween.tween_interval(0.76)
	target_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	target_tween.tween_property(target, "scale", _scale_of(target), 0.62)
	target_tween.parallel().tween_property(target, "rotation", _rotation_of(target), 0.62)
	target_tween.parallel().tween_property(target, "modulate", Color.WHITE, 0.28)

	await get_tree().create_timer(1.48).timeout
	_opening_finished = true
	_remove_input_blocker()
	_start_ambient()
	if _action_available:
		set_action_available(true, false)


func set_action_available(available: bool, immediate := false) -> void:
	_action_available = available
	var action := $"../TransformButton" as Button
	if is_instance_valid(_action_tween):
		_action_tween.kill()

	var destination := _position_of(action) if available else _position_of(action) + Vector2(330.0, 0.0)
	if immediate or not _prepared:
		action.position = destination
		action.modulate.a = 1.0 if available else 0.0
		action.scale = _scale_of(action)
		return

	_action_tween = create_tween().set_parallel(true)
	_action_tween.set_trans(Tween.TRANS_BACK if available else Tween.TRANS_EXPO)
	_action_tween.set_ease(Tween.EASE_OUT if available else Tween.EASE_IN)
	_action_tween.tween_property(action, "position", destination, 0.46 if available else 0.28)
	_action_tween.tween_property(action, "modulate:a", 1.0 if available else 0.0, 0.22)
	_action_tween.tween_property(action, "scale", _scale_of(action), 0.4)


func show_hint(text: String, is_error: bool, immediate := false) -> void:
	var hint := $"../HintText" as Label
	if is_instance_valid(_hint_tween):
		_hint_tween.kill()
	var target_color := Color(0.62, 0.08, 0.035) if is_error else Color(0.12, 0.33, 0.18)

	if immediate:
		_set_hint_text(hint, text, target_color)
		# The director caches poses before GameRoot supplies the first hint. Since
		# this right-anchored label grows to the left, its X position changes when
		# the text becomes wider. Refresh the cached resting pose while retaining
		# the temporary opening offset instead of restoring the old "Welcome!"
		# position (which put the bubble's centre on the screen edge).
		if _prepared and not _opening_finished:
			_base_positions[hint] = hint.position - HINT_OPENING_OFFSET
		return

	_hint_tween = create_tween()
	_hint_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hint_tween.tween_property(hint, "scale", Vector2(0.96, 0.72), 0.1)
	_hint_tween.parallel().tween_property(hint, "self_modulate:a", 0.0, 0.08)
	_hint_tween.tween_callback(func() -> void:
		_set_hint_text(hint, text, Color(target_color.r, target_color.g, target_color.b, 0.0))
	)
	_hint_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_hint_tween.tween_property(hint, "scale", Vector2.ONE, 0.24)
	_hint_tween.parallel().tween_property(hint, "self_modulate:a", 1.0, 0.18)


func _set_hint_text(hint: Label, text: String, color: Color) -> void:
	# Keep the speech bubble's right edge fixed while its minimum size changes.
	# Relying only on anchors is fragile after a Tween has written `position`.
	var right_edge := hint.position.x + hint.size.x
	hint.text = text
	hint.reset_size()
	hint.position.x = right_edge - hint.size.x
	hint.pivot_offset = hint.size * 0.5
	hint.self_modulate = color


func show_upb_state(active: bool) -> void:
	var info := $"../UPBInfo" as Control
	if is_instance_valid(_upb_tween):
		_upb_tween.kill()
	if active:
		info.show()
	_upb_tween = create_tween().set_parallel(true)
	_upb_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_upb_tween.tween_property(info, "modulate:a", 1.0 if active else 0.0, 0.24)
	_upb_tween.tween_property(info, "scale", Vector2.ONE if active else Vector2(0.88, 0.88), 0.3)
	if not active:
		_upb_tween.chain().tween_callback(info.hide)


func play_win() -> void:
	var seal := $"../Seal" as TextureRect
	var mission := $"../Mission" as TextureRect
	var target := $"../TargetItem" as Control
	seal.visible = true
	seal.pivot_offset = seal.size * 0.5
	seal.position = _position_of(seal) + Vector2(84.0, -96.0)
	seal.scale = Vector2(2.8, 2.8)
	seal.rotation = _rotation_of(seal) - deg_to_rad(78.0)
	seal.self_modulate = Color(1.35, 0.72, 0.3, 0.0)

	var flash := ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(0.92, 0.48, 0.12, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 80
	_root.add_child(flash)

	var seal_tween := create_tween()
	seal_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	seal_tween.tween_property(seal, "position", _position_of(seal), 0.5)
	seal_tween.parallel().tween_property(seal, "scale", Vector2(0.82, 1.18), 0.5)
	seal_tween.parallel().tween_property(seal, "rotation", _rotation_of(seal) + deg_to_rad(7.0), 0.5)
	seal_tween.parallel().tween_property(seal, "self_modulate:a", 1.0, 0.3)
	seal_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	seal_tween.tween_property(seal, "scale", Vector2.ONE, 0.48)
	seal_tween.parallel().tween_property(seal, "rotation", _rotation_of(seal), 0.42)

	var impact_tween := create_tween()
	impact_tween.tween_interval(0.48)
	impact_tween.tween_callback(func() -> void:
		$"../WinParticle".restart()
		$"../WinParticle".emitting = true
	)
	impact_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(flash, "color:a", 0.18, 0.07)
	impact_tween.tween_property(flash, "color:a", 0.0, 0.34)
	impact_tween.tween_callback(flash.queue_free)

	var mission_tween := create_tween()
	mission_tween.tween_interval(0.48)
	mission_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	mission_tween.tween_property(mission, "scale", _scale_of(mission) * Vector2(1.025, 0.96), 0.16)
	mission_tween.tween_property(mission, "scale", _scale_of(mission), 0.46)

	var target_tween := create_tween()
	target_tween.tween_interval(0.52)
	target_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	target_tween.tween_property(target, "scale", _scale_of(target) * 1.35, 0.3)
	target_tween.tween_property(target, "scale", _scale_of(target), 0.42)

	_highlight_next_button()


func _cache_pose(control: Control) -> void:
	_base_positions[control] = control.position
	_base_scales[control] = control.scale
	_base_rotations[control] = control.rotation


func _position_of(control: Control) -> Vector2:
	return _base_positions.get(control, control.position)


func _scale_of(control: Control) -> Vector2:
	return _base_scales.get(control, control.scale)


func _rotation_of(control: Control) -> float:
	return _base_rotations.get(control, control.rotation)


func _reveal_simple(control: Control, delay: float, offset: Vector2) -> void:
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "position", _position_of(control) + offset, 0.42)
	tween.parallel().tween_property(control, "modulate:a", 1.0, 0.24)


func _start_ambient() -> void:
	_stop_ambient()
	var halo := $"../TextureRect2" as TextureRect
	var spin := create_tween().set_loops()
	spin.set_trans(Tween.TRANS_LINEAR)
	spin.tween_property(halo, "rotation", _rotation_of(halo) + TAU, 26.0).from(_rotation_of(halo))
	_ambient_tweens.append(spin)

	var pulse := create_tween().set_loops()
	pulse.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(halo, "self_modulate", Color(1.12, 0.76, 0.48, 0.76), 2.4)
	pulse.tween_property(halo, "self_modulate", Color(0.72, 0.45, 0.82, 0.5), 2.4)
	_ambient_tweens.append(pulse)

	var target := $"../TargetItem" as Control
	var target_float := create_tween().set_loops()
	target_float.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	target_float.tween_property(target, "position", _position_of(target) + Vector2(0.0, -4.0), 1.8)
	target_float.tween_property(target, "position", _position_of(target) + Vector2(0.0, 3.0), 1.8)
	_ambient_tweens.append(target_float)


func _stop_ambient() -> void:
	for tween in _ambient_tweens:
		if is_instance_valid(tween):
			tween.kill()
	_ambient_tweens.clear()


func _create_input_blocker() -> void:
	_input_blocker = ColorRect.new()
	_input_blocker.name = "OpeningInputBlocker"
	_input_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_input_blocker.color = Color.TRANSPARENT
	_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_input_blocker.z_index = 100
	_root.add_child(_input_blocker)


func _remove_input_blocker() -> void:
	if is_instance_valid(_input_blocker):
		_input_blocker.queue_free()
	_input_blocker = null


func _setup_button_motion(button: Button, direction: float) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pivot_offset = button.size * 0.5
	button.resized.connect(func() -> void: button.pivot_offset = button.size * 0.5)
	button.mouse_entered.connect(func() -> void:
		var tween := create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.045, 1.045), 0.18)
		tween.tween_property(button, "rotation", deg_to_rad(direction * 0.7), 0.18)
		tween.tween_property(button, "self_modulate", Color(1.22, 0.78, 0.42), 0.16)
	)
	button.mouse_exited.connect(func() -> void:
		var tween := create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2.ONE, 0.28)
		tween.tween_property(button, "rotation", 0.0, 0.28)
		tween.tween_property(button, "self_modulate", Color.WHITE, 0.2)
	)
	button.button_down.connect(func() -> void:
		create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(button, "scale", Vector2(0.96, 0.92), 0.08)
	)


func _setup_action_button_motion() -> void:
	var button := $"../TransformButton" as Button
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pivot_offset = button.size * 0.5
	button.resized.connect(func() -> void: button.pivot_offset = button.size * 0.5)
	button.mouse_entered.connect(func() -> void:
		if button.disabled:
			return
		var tween := create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.09, 1.09), 0.18)
		tween.tween_property(button, "rotation", deg_to_rad(-1.2), 0.18)
		tween.tween_property(button, "self_modulate", Color(1.25, 0.66, 0.3), 0.16)
	)
	button.mouse_exited.connect(func() -> void:
		var tween := create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2.ONE, 0.26)
		tween.tween_property(button, "rotation", 0.0, 0.26)
		tween.tween_property(button, "self_modulate", Color.WHITE, 0.2)
	)
	button.button_down.connect(func() -> void:
		create_tween().set_trans(Tween.TRANS_QUAD).tween_property(button, "scale", Vector2(0.93, 0.88), 0.08)
	)


func _highlight_next_button() -> void:
	var button := $"../ButtonList/NextButton" as Button
	var tween := create_tween().set_loops(3)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(button, "self_modulate", Color(1.35, 0.72, 0.28), 0.32)
	tween.parallel().tween_property(button, "scale", Vector2(1.06, 1.06), 0.32)
	tween.tween_property(button, "self_modulate", Color.WHITE, 0.42)
	tween.parallel().tween_property(button, "scale", Vector2.ONE, 0.42)
