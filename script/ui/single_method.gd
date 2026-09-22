extends TextureRect

# ===== 导出变量 =====
@export var mode := GameRoot.OperationMode.TRANSFORM         # 模式标识
@export var normal_color := Color(1, 1, 1, 1)
@export var hover_color := Color(0.6, 0.6, 0.6, 1)    # 悬停变深
@export var active_color := Color(0.5, 0.2, 0.8, 1)   # 激活紫色
@export var tween_duration := 0.15     # 颜色过渡时间（秒）

@onready var root:GameRoot = get_tree().current_scene
var is_active := false :
	set(value):
		if is_active == value:
			return
		is_active = value
		_update_appearance()

# 用于动画的 Tween 对象
var _tween: Tween = null
var _reveal_tween: Tween = null
var _ready_for_motion := true

# ===== 生命周期 =====
func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(_update_pivot)
	call_deferred("_update_pivot")
	root.mode_change.connect(func(new_mode):
		if new_mode!=mode:
			is_active = false
			_update_appearance()
	)
	
	# 启动时如果 mode 是 TRANSFORM，则默认选中
	if mode == GameRoot.OperationMode.TRANSFORM:
		is_active = true
	
	_update_appearance()

# ===== 鼠标悬停事件 =====
func _on_mouse_entered() -> void:
	if not _ready_for_motion:
		return
	if not is_active:
		_animate_visual(hover_color, Vector2(1.13, 1.13), _hover_rotation())
	else:
		_animate_visual(active_color, Vector2(1.08, 1.08), _hover_rotation() * 0.4)

func _on_mouse_exited() -> void:
	if not _ready_for_motion:
		return
	_animate_visual(active_color if is_active else normal_color, Vector2.ONE, 0.0)

# ===== 输入事件 =====
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if root.operation_in_progress:
			return
		if not is_active:
			_activate()

# ===== 激活逻辑 =====
func _activate() -> void:
	# 1. 激活自己
	is_active = true
	if is_instance_valid(_tween):
		_tween.kill()
	self_modulate = active_color

	# 2. 通知全局 GameRoot
	root.mode_change.emit(mode)
	var punch := create_tween()
	punch.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	punch.tween_property(self, "scale", Vector2(0.86, 1.14), 0.08)
	punch.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	punch.tween_property(self, "scale", Vector2.ONE, 0.3)

# ===== 刷新外观（计算目标颜色并触发动画） =====
func _update_appearance() -> void:
	var target_color: Color
	if is_active:
		target_color = active_color
	else:
		var mouse_pos := get_global_mouse_position()
		var rect := get_global_rect()
		if rect.has_point(mouse_pos):
			target_color = hover_color
		else:
			target_color = normal_color
	_animate_visual(target_color, Vector2.ONE, 0.0)

# ===== 颜色动画 =====
func _animate_to_color(target: Color) -> void:
	_animate_visual(target, scale, rotation)


func _animate_visual(target: Color, target_scale: Vector2, target_rotation: float) -> void:
	# 如果已经在动画，直接更新目标值，避免冲突
	if _tween and _tween.is_valid():
		# 可以停止当前动画，从当前颜色开始过渡到新目标
		_tween.kill()
	
	# 创建新的 Tween
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "self_modulate", target, tween_duration)
	_tween.tween_property(self, "scale", target_scale, tween_duration)
	_tween.tween_property(self, "rotation", target_rotation, tween_duration)


func prepare_for_reveal() -> void:
	_ready_for_motion = false
	if is_instance_valid(_tween):
		_tween.kill()
	if is_instance_valid(_reveal_tween):
		_reveal_tween.kill()
	modulate.a = 0.0
	scale = Vector2(0.12, 0.12)
	rotation = -_hover_rotation() * 4.0


func reveal(delay: float) -> void:
	if is_instance_valid(_reveal_tween):
		_reveal_tween.kill()
	_reveal_tween = create_tween()
	_reveal_tween.tween_interval(delay)
	_reveal_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reveal_tween.tween_property(self, "scale", Vector2(1.18, 0.86), 0.28)
	_reveal_tween.parallel().tween_property(self, "rotation", _hover_rotation() * 0.6, 0.28)
	_reveal_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.18)
	_reveal_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_reveal_tween.tween_property(self, "scale", Vector2.ONE, 0.26)
	_reveal_tween.parallel().tween_property(self, "rotation", 0.0, 0.26)
	_reveal_tween.tween_callback(func() -> void: _ready_for_motion = true)


func _update_pivot() -> void:
	pivot_offset = size * 0.5


func _hover_rotation() -> float:
	var direction := -1.0 if int(mode) % 2 == 0 else 1.0
	return deg_to_rad(direction * 2.2)
