extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_child_order_changed() -> void:
	var now=0
	for i in get_children():
		var tween=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
		i.clickable=false
		tween.tween_property(i,"position", Vector2(now%8*55, now/8*55), 0.4)
		tween.tween_property(i,"scale",Vector2(3,3),0.4)
		tween.tween_property(i,"rotation",0,0.4)
		tween.finished.connect(func(): i.clickable=true)
		now+=1
