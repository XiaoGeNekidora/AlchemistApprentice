extends OperationDelegate
class_name MoldDelegate

func can_use_mold() -> bool:
	return true
	
func get_operation_name() -> String:
	return "Mold"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Mold!!"

func hint_text() -> String:
	return "Make a mold of an item or its components."

## Create a copy of the item with is_mold = true, or null if item is null
func make_mold(item: Item) -> Item:
	if item == null:
		return null
	var copy := Item.new(item.type, item.name, item.left, item.right, item.tag)
	copy.is_mold = true
	return copy

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m: Item, p: Item) -> Array:
	var err_msg = null
	if m == null:
		err_msg = "Please add an item to mold"
	elif m.is_mold:
		if m.type == Item.ItemType.UNIT:
			err_msg = "Cannot mold the components of a unit!"
		else:
			return [0, "Will make component molds! THIS WILL CONSUME THE MOLD!"]
	else:
		return [0, "Will mold this item. It does not consume the item."]
	
	if err_msg != null:
		return [1, err_msg]
	return [1, "Unknown error"]

func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	
	if not m.is_mold:
		# Mold operation: create a mold copy, original is NOT consumed
		var result := make_mold(m)
		
		# Spawn a new item display for the mold result
		var pa = id.instantiate()
		pa.set_item(result)
		pa.scale = Vector2.ZERO
		pa.global_position = ma.global_position
		root.add_child(pa)
		tooltip.bind(pa)
		pa.size = Vector2(24, 24)
		
		# Start mold animation: new mold copy scales up from the original
		in_particle.emitting = true
		var tw = root.get_tree().create_tween()
		tw.tween_interval(0.5)
		tw.tween_property(pa, "scale", Vector2(4, 4), 0.5)
		tw.tween_callback(func():
			out_particle.emitting = true
		)
		tw.tween_interval(1)
		await tw.finished
		
		if Globals.current_level.win.equals(result):
			win_game()
		
		# Put down the new result and the original input (not consumed)
		root.put_down(pa)
		root.put_down(ma)
		
		# Clear globals and refresh UI at the end
		Globals.active_material = null
		Globals.active_material_actor = null
		root.on_potion_update()
	else:
		# Unmold operation: split mold into left and right components, original IS consumed
		if m.type == Item.ItemType.UNIT:
			return
		
		var left_mold := make_mold(m.left)
		var right_mold := make_mold(m.right)
		
		# Determine which components exist (NOT type only has left)
		var has_left := left_mold != null
		var has_right := right_mold != null
		
		if has_left and has_right:
			# Both components: spawn two new actors (original ma is consumed)
			var pa = id.instantiate()
			pa.set_item(left_mold)
			pa.scale = Vector2.ZERO
			pa.global_position = ma.global_position
			root.add_child(pa)
			tooltip.bind(pa)
			pa.size = Vector2(24, 24)
			
			var pb = id.instantiate()
			pb.set_item(right_mold)
			pb.scale = Vector2.ZERO
			pb.global_position = ma.global_position + Vector2(20, 0)
			root.add_child(pb)
			tooltip.bind(pb)
			pb.size = Vector2(24, 24)
			
			# Start unmold animation: both components scale up from the consumed mold
			in_particle.emitting = true
			var tw = root.get_tree().create_tween()
			tw.tween_interval(0.5)
			tw.tween_property(pa, "scale", Vector2(4, 4), 0.5)
			tw.parallel().tween_property(pb, "scale", Vector2(4, 4), 0.5)
			tw.tween_callback(func():
				out_particle.emitting = true
			)
			tw.tween_interval(1)
			await tw.finished
			
			if Globals.current_level.win.equals(left_mold) or Globals.current_level.win.equals(right_mold):
				win_game()
			
			# Put down the two new outputs; original mold actor is consumed (freed)
			root.put_down(pa)
			root.put_down(pb)
			ma.queue_free()
			
			# Clear globals and refresh UI at the end
			Globals.active_material = null
			Globals.active_material_actor = null
			root.on_potion_update()
		elif has_left:
			# Only left component (e.g., NOT mold): spawn one new actor
			var pa = id.instantiate()
			pa.set_item(left_mold)
			pa.scale = Vector2.ZERO
			pa.global_position = ma.global_position
			root.add_child(pa)
			tooltip.bind(pa)
			pa.size = Vector2(24, 24)
			
			# Start unmold animation for single component
			in_particle.emitting = true
			var tw = root.get_tree().create_tween()
			tw.tween_interval(0.5)
			tw.tween_property(pa, "scale", Vector2(4, 4), 0.5)
			tw.tween_callback(func():
				out_particle.emitting = true
			)
			tw.tween_interval(1)
			await tw.finished
			
			if Globals.current_level.win.equals(left_mold):
				win_game()
			
			root.put_down(pa)
			ma.queue_free()
			
			# Clear globals and refresh UI at the end
			Globals.active_material = null
			Globals.active_material_actor = null
			root.on_potion_update()
