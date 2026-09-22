extends OperationDelegate
class_name BalanceUpbDelegate

func can_use_mold() -> bool:
	return true
	
func get_operation_name() -> String:
	return "Balance UPB"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Balance UPB!!"

func hint_text() -> String:
	return "Get the potion premise from the UPB stack."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	if root.upb_stack.is_empty():
		return [1, "UPB is not running! Start UPB with a mold first."]
	if m == null:
		return [1, "Please put a mold of a certain UPB input to get the potion premise"]
		
	var layer := 1
	for i in root.upb_stack:
		if i.introduced.clone().set_mold().type_str()==m.type_str():
			return [0, "Will get the potion premise: %s (Introduced in Layer %d)" % [i.introduced.type_str(), layer]]
		layer+=1
	
	return [1, "The mold does not match any UPB input. Only a mold of an UPB input can be used to clone it!"]

func craft():
	if root.upb_stack.is_empty():
		return
	
	var m := Globals.active_material
	var ma := Globals.active_material_actor
	
	var result_item: Item = m.clone()
	result_item.is_mold=false
	
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
	put_down(ma)
	put_down(pa)
	
	# Check win condition
	if Globals.current_level.win.equals(result_item):
		win_game()
	