extends TextureRect

var item_prefab=preload("res://partial/item_display.tscn")

var first=true

var initial_position:Vector2
var _motion_tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position=self.position
	pivot_offset = size * 0.5
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func gen_item(list:Array[Item]):
	if list.is_empty():
		_kill_motion()
		_motion_tween=get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
		_motion_tween.tween_property(self,"position",initial_position+Vector2(10,0),0.1)
		_motion_tween.tween_property(self,"position",initial_position+Vector2(-10,0),0.1)
		_motion_tween.tween_property(self,"position",initial_position+Vector2(0,0),0.1)
		return

	_play_dispense()
	
	for item in list:
		var new_item:ItemDisplay=item_prefab.instantiate()
		new_item.set_item(item)
		new_item.scale = Vector2(0.25, 0.25)
		new_item.self_modulate.a = 0.0
		$"..".signal_transform.connect(new_item.on_transform)
		%Tooltip.bind(new_item)
		
		#var tw=get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		#tw.tween_property(%PathFollow2D,"progress_ratio",1,)
		%HandContainer.add_child(new_item)
		new_item.global_position=self.global_position
		new_item.rotation=randf_range(0,2*PI)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			var root := get_tree().current_scene as GameRoot
			if root != null and root.operation_in_progress:
				return
			if first:
				gen_item(Globals.current_level.on_initial())
				first=false
			else:
				gen_item(Globals.current_level.on_restock())


func _on_mouse_entered() -> void:
	_kill_motion()
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2(1.045, 1.045), 0.18)
	_motion_tween.tween_property(self, "rotation", deg_to_rad(-1.4), 0.18)
	_motion_tween.tween_property(self, "self_modulate", Color(1.13, 0.9, 0.66), 0.16)


func _on_mouse_exited() -> void:
	_kill_motion()
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	_motion_tween.tween_property(self, "rotation", 0.0, 0.3)
	_motion_tween.tween_property(self, "self_modulate", Color.WHITE, 0.2)


func _play_dispense() -> void:
	_kill_motion()
	_motion_tween = create_tween()
	_motion_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2(1.13, 0.82), 0.09)
	_motion_tween.parallel().tween_property(self, "rotation", deg_to_rad(3.0), 0.09)
	_motion_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "scale", Vector2.ONE, 0.36)
	_motion_tween.parallel().tween_property(self, "rotation", 0.0, 0.36)


func _kill_motion() -> void:
	if is_instance_valid(_motion_tween):
		_motion_tween.kill()
			
