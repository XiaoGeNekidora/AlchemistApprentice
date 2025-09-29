extends TextureRect

var item_prefab=preload("res://partial/item_display.tscn")

var first=true

var initial_position:Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position=self.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func gen_item(list:Array[Item]):
	if list.is_empty():
		var tw=get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
		tw.tween_property(self,"position",initial_position+Vector2(10,0),0.1)
		tw.tween_property(self,"position",initial_position+Vector2(-10,0),0.1)
		tw.tween_property(self,"position",initial_position+Vector2(0,0),0.1)
	
	for item in list:
		var new_item:ItemDisplay=item_prefab.instantiate()
		new_item.set_item(item)
		$"..".signal_transform.connect(new_item.on_transform)
		
		#var tw=get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		#tw.tween_property(%PathFollow2D,"progress_ratio",1,)
		%HandContainer.add_child(new_item)
		new_item.global_position=self.global_position
		new_item.rotation=randf_range(0,2*PI)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			if first:
				gen_item(Globals.current_level.on_initial())
				first=false
			else:
				gen_item(Globals.current_level.on_restock())
			
