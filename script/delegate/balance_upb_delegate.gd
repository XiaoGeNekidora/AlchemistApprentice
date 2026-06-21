extends OperationDelegate
class_name BalanceUpbDelegate

func can_use_mold() -> bool:
	return false
	
func get_operation_name() -> String:
	return "Balance UPB"

func arg_count() -> int:
	return 0

func transform_button_name() -> String:
	return "Balance UPB!!"

func hint_text() -> String:
	return "Get the potion premise from the UPB stack."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	if root.upb_stack.is_empty():
		return [1, "UPB is not running! Start UPB with a mold first."]
	return [0, "Will get the potion premise: %s" % root.upb_stack.back().introduced.type_str()]
	
func craft():
	if root.upb_stack.is_empty():
		return
	
	var result_item: Item = root.upb_stack.back().introduced
	
	# Spawn a new item display for the result
	var pa: ItemDisplay = id.instantiate()
	pa.set_item(result_item)
	pa.scale = Vector2.ZERO
	pa.global_position = item_here.global_position
	root.add_child(pa)
	tooltip.bind(pa)
	pa.size = Vector2(24, 24)
	
	# Animate: item scales up from the marker position
	out_particle.emitting = true
	var tw = root.get_tree().create_tween()
	tw.tween_property(pa, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	# Put down the result into inventory
	put_down(pa)
	
	# Check win condition
	if Globals.current_level.win.equals(result_item):
		win_game()
	