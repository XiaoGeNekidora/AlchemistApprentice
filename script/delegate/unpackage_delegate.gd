extends OperationDelegate
class_name UnpackageDelegate

func get_operation_name() -> String:
	return "Unpackage"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Break!"

func hint_text() -> String:
	return "Let's see if we can unpackage something..."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m: Item, p: Item) -> Array:
	var err_msg = null
	if m == null:
		err_msg = "Please add a package"
	elif m.type != Item.ItemType.AND:
		err_msg = "That is not a package"
	
	if err_msg != null:
		return [1, err_msg]
	else:
		return [0, "Can unpackage! Into: " + m.left.type_str().capitalize() + " and " + m.right.type_str().capitalize() + " :>"]

func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	elif m.type != Item.ItemType.AND:
		return
	
	# Close Button
	Globals.active_material = null
	Globals.active_material_actor = null
	root.on_potion_update()
	
	# TODO close input for all itemdisplay
	
	# Start transform
	var pa = id.instantiate()
	pa.set_item(m.right)
	pa.scale = Vector2.ZERO
	pa.global_position = ma.global_position
	root.add_child(pa)
	tooltip.bind(pa)
	pa.size = Vector2(24, 24)
	
	in_particle.emitting = true
	var tw = root.get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2(0, 0), 0.5)
	tw.tween_callback(func():
		ma.set_item(m.left)
		out_particle.emitting = true
	)
	
	tw.tween_property(pa, "scale", Vector2(4, 4), 0.5)
	tw.parallel().tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(m.left) or Globals.current_level.win.equals(m.right):
		# Game Won
		root.win_game()
		
	root.put_down(pa)
	root.put_down(ma)
