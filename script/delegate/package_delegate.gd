extends OperationDelegate
class_name PackageDelegate

func can_use_mold() -> bool:
	return true
	
func get_operation_name() -> String:
	return "Package"

func arg_count() -> int:
	return 2

func transform_button_name() -> String:
	return "Package!"

func hint_text() -> String:
	return "Let's see if we can package something..."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m: Item, p: Item) -> Array:
	var err_msg = null
	if m == null:
		err_msg = "Please add a base material"
	elif p == null:
		err_msg = "Add another item to package"
	
	if err_msg != null:
		return [1, err_msg]
	else:
		var result := Item.a(m, p)
		return [0, "Can package! Yield: " + result.type_str().capitalize() + " :>"]

func craft():
	var p = Globals.active_potion
	var m = Globals.active_material
	var pa = Globals.active_potion_actor
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	elif p == null:
		return
	
	# Close Button
	Globals.active_material = null
	Globals.active_potion = null
	Globals.active_material_actor = null
	Globals.active_potion_actor = null
	root.on_potion_update()
	
	# Create the package (AND type)
	var packaged := Item.a(m, p)
	
	# Start packaging animation
	in_particle.emitting = true
	var tw = root.get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2(0, 0), 0.5)
	tw.parallel().tween_property(pa, "scale", Vector2(0, 0), 0.5)
	tw.tween_callback(func():
		ma.set_item(packaged)
		out_particle.emitting = true
		pa.queue_free()
	)
	tw.tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(packaged):
		# Game Won
		root.win_game()
			
	root.put_down(ma)
