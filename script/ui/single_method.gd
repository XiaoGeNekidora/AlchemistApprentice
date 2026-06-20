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

# ===== 生命周期 =====
func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
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
	if not is_active:
		_animate_to_color(hover_color)

func _on_mouse_exited() -> void:
	if not is_active:
		_animate_to_color(normal_color)

# ===== 输入事件 =====
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_active:
			_activate()

# ===== 激活逻辑 =====
func _activate() -> void:
	# 1. 激活自己
	is_active = true
	_update_appearance()
	
	# 2. 通知全局 GameRoot
	root.mode_change.emit(mode)

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
	_animate_to_color(target_color)

# ===== 颜色动画 =====
func _animate_to_color(target: Color) -> void:
	# 如果已经在动画，直接更新目标值，避免冲突
	if _tween and _tween.is_valid():
		# 可以停止当前动画，从当前颜色开始过渡到新目标
		_tween.kill()
	
	# 创建新的 Tween
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "modulate", target, tween_duration)
