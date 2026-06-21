extends OperationDelegate
class_name EndUpbDelegate

func can_use_mold() -> bool:
	return true
	
func get_operation_name() -> String:
	return "End UPB"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "End UPB!!"

func hint_text() -> String:
	return "Finish UPB recording with the final item to produce a potion."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	if root.upb_stack.is_empty():
		return [1, "UPB is not running! Start UPB with a mold first."]
	
	root.upb_result_preview=m
	if m == null:
		return [1, "Please add an item to finish UPB"]
	return [0, "Will finish UPB recording and produce a potion. The item will be consumed."]
	
func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	if root.upb_stack.is_empty():
		return
	
	# Clear globals and close button
	Globals.active_material = null
	Globals.active_material_actor = null
	root.on_potion_update()
	
	# Call end_upb to compute the potion and restore inventory to UPB start state
	var result = root.end_upb(m)
	
	# Transform animation: shrink input, swap to result potion, grow back
	in_particle.emitting = true
	var tw = root.get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2.ZERO, 0.5)
	tw.tween_callback(func():
		ma.set_item(result)
		out_particle.emitting = true
	)
	tw.tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(result):
		root.win_game()
	
	root.put_down(ma)