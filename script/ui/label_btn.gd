extends Label

signal clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	self.mouse_entered.connect(enter)
	self.mouse_exited.connect(exit)
	self.gui_input.connect(click)

func click(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			clicked.emit()
	
func enter():
	#print("E")
	#tween.tween_property(self,^"scale:x",-1,0.5)
	var tween=create_tween()
	tween.tween_property(self, ^":label_settings:shadow_size", 10, 0.1)
	
	#tween.start()


func exit():
	#print("Ex")
	var tween=create_tween()
	tween.tween_property(self, ^":label_settings:shadow_size", 0, 0.1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
