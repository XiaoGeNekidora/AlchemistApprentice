extends Control

var _active := false
var _base_position: Vector2
var _base_bg_position: Vector2
var _base_line_width := 4.0
var _panel_tween: Tween
var _bg_tween: Tween
var _line_tween: Tween
var _animation_id := 0

@onready var _background := $bg as TextureRect
@onready var _line := $Line2D as Line2D


func _ready() -> void:
	_base_position = position
	_base_bg_position = _background.position
	_base_line_width = _line.width
	pivot_offset = Vector2(640.0, 324.0)
	_background.pivot_offset = _background.size * 0.5
	visible = false
	modulate.a = 0.0
	_set_button_input(false)
	EventBus.select.connect(on_select)


func on_select(chapter: String) -> void:
	_animation_id += 1
	var direction := _travel_direction(chapter)
	if chapter == name:
		if not _active:
			_show_panel(direction)
	else:
		if _active:
			_hide_panel(direction)


func _show_panel(direction: float) -> void:
	_active = true
	_kill_tweens()
	visible = true
	position = _base_position + Vector2(direction * 105.0, 22.0)
	rotation = deg_to_rad(direction * 2.1)
	scale = Vector2(0.955, 0.955)
	modulate = Color(0.72, 0.48, 0.9, 0.0)

	_background.position = _base_bg_position + Vector2(direction * 32.0, -10.0)
	_background.scale = Vector2(1.055, 1.055)
	_line.width = 0.0
	_line.modulate = Color(1.35, 0.74, 0.22, 0.0)

	for button in _level_buttons():
		button.prepare_for_reveal()

	_panel_tween = create_tween().set_parallel(true)
	_panel_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_panel_tween.tween_property(self, "position", _base_position, 0.58)
	_panel_tween.tween_property(self, "rotation", 0.0, 0.58)
	_panel_tween.tween_property(self, "scale", Vector2.ONE, 0.58)
	_panel_tween.tween_property(self, "modulate", Color.WHITE, 0.4)

	_bg_tween = create_tween().set_parallel(true)
	_bg_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_bg_tween.tween_property(_background, "position", _base_bg_position, 1.15)
	_bg_tween.tween_property(_background, "scale", Vector2.ONE, 1.4)

	_line_tween = create_tween().set_parallel(true)
	_line_tween.tween_interval(0.12)
	_line_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_line_tween.tween_property(_line, "width", _base_line_width * 1.85, 0.48)
	_line_tween.tween_property(_line, "modulate:a", 1.0, 0.32)
	_line_tween.chain().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_line_tween.tween_property(_line, "width", _base_line_width, 0.28)
	_line_tween.parallel().tween_property(_line, "modulate", Color.WHITE, 0.28)

	var buttons := _level_buttons()
	for index in buttons.size():
		buttons[index].reveal(0.18 + index * 0.085)
	_set_button_input(true)


func _hide_panel(direction: float) -> void:
	_active = false
	_kill_tweens()
	_set_button_input(false)
	for button in _level_buttons():
		button.conceal()

	var this_animation := _animation_id
	_panel_tween = create_tween().set_parallel(true)
	_panel_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	_panel_tween.tween_property(self, "position", _base_position + Vector2(-direction * 82.0, -16.0), 0.34)
	_panel_tween.tween_property(self, "rotation", deg_to_rad(-direction * 1.8), 0.34)
	_panel_tween.tween_property(self, "scale", Vector2(1.025, 1.025), 0.34)
	_panel_tween.tween_property(self, "modulate", Color(0.6, 0.32, 0.78, 0.0), 0.3)
	_panel_tween.chain().tween_callback(_finish_hiding.bind(this_animation))


func _finish_hiding(animation_id: int) -> void:
	if animation_id != _animation_id or _active:
		return
	visible = false
	position = _base_position
	rotation = 0.0
	scale = Vector2.ONE


func _travel_direction(target: String) -> float:
	var target_index := _chapter_index(target)
	var own_index := _chapter_index(name)
	if target_index == own_index:
		var previous_index := _chapter_index(Globals.last_visited_chapter)
		return 1.0 if target_index >= previous_index else -1.0
	return 1.0 if target_index > own_index else -1.0


func _chapter_index(chapter: String) -> int:
	var chapters := ["I", "II", "III", "IV", "V", "VI"]
	return chapters.find(chapter)


func _level_buttons() -> Array:
	var result := []
	for child in get_children():
		if child is Button:
			result.append(child)
	return result


func _set_button_input(enabled: bool) -> void:
	for button in _level_buttons():
		button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _kill_tweens() -> void:
	for tween in [_panel_tween, _bg_tween, _line_tween]:
		if is_instance_valid(tween):
			tween.kill()
