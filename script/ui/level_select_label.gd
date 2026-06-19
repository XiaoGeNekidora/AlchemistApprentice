extends Label

var col = Color.WHITE

func _ready() -> void:
	# Set initial state instantly based on last visited chapter (no animation on first load)
	if Globals.last_visited_chapter != self.name:
		col = Color.WHITE
		self.modulate = Color.WHITE
	else:
		col = Color.PURPLE
		self.modulate = Color.PURPLE
	EventBus.select.connect(on_select)

func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.AQUAMARINE, 0.5)


func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", col, 0.5)

func on_select(who: String):
	if who != self.name:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.5)
		col = Color.WHITE
	else:
		col = Color.PURPLE
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", col, 0.5)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index==MOUSE_BUTTON_LEFT:
			EventBus.select.emit(self.name)
			
			for i in %panel.get_children():
				if i.name!=self.name:
					var tw=get_tree().create_tween()
					tw.tween_property(i,"modulate",Color(1,1,1,0),0.5)
					tw.tween_callback(func(): i.visible=false)
				else:
					var tw=get_tree().create_tween()
					tw.tween_callback(func(): i.visible=true)
					tw.tween_property(i,"modulate",Color(1,1,1,1),0.5)
	
