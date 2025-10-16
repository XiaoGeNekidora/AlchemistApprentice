extends Control

func _ready() -> void:
	EventBus.select.connect(on_select)

func on_select(name: String):
	if name!=self.name:
		var tw=get_tree().create_tween()
		tw.tween_property(self,"modulate",Color(1,1,1,0),0.5)
		#tw.tween_callback(func(): self.visible=false)
	else:
		var tw=get_tree().create_tween()
		#tw.tween_callback(func(): self.visible=true)
		tw.tween_property(self,"modulate",Color(1,1,1,1),0.5)

func _process(delta: float) -> void:
	self.visible= self.modulate.a!=0
