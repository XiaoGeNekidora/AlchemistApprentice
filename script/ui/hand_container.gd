extends Control

const COLUMNS := 6
## Center-to-center spacing in pixels, shared by columns and rows. A resting
## item is 72px wide; leave room for its ingredient previews and hover motion.
const CELL_SPACING := 75.0

var _layout_queued := false


func _on_child_order_changed() -> void:
	if not is_inside_tree():
		return
	if _layout_queued:
		return
	_layout_queued = true
	call_deferred("_animate_layout")


func _animate_layout() -> void:
	_layout_queued = false
	var now=0
	for i in get_children():
		if not i is ItemDisplay:
			continue
		if i.has_meta("layout_tween"):
			var old_tween = i.get_meta("layout_tween") as Tween
			if is_instance_valid(old_tween):
				old_tween.kill()

		var tween=get_tree().create_tween()
		i.set_meta("layout_tween", tween)
		i.clickable=false
		tween.tween_interval(now * 0.025)
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(i,"position", Vector2(now % COLUMNS * CELL_SPACING, floori(float(now) / COLUMNS) * CELL_SPACING), 0.4)
		tween.tween_property(i,"scale",Vector2(3,3),0.4)
		tween.tween_property(i,"rotation",0,0.4)
		tween.tween_property(i,"self_modulate:a",1.0,0.24)
		tween.chain().tween_callback(_finish_item_layout.bind(i))
		now+=1


func _finish_item_layout(item: ItemDisplay) -> void:
	if is_instance_valid(item):
		item.clickable = true
