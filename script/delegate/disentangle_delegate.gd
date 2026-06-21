extends OperationDelegate
class_name DisentangleDelegate

func get_operation_name() -> String:
	return "Disentangle"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Disentangle!!"

func hint_text() -> String:
	return "???"

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	var err_msg = null
	if m == null:
		err_msg = "Please add the first potion (A->C) in the material slot"
	elif m.type != Item.ItemType.TRANSFORM:
		err_msg = "The first item (material slot) does not look like a potion"
	elif p == null:
		err_msg = "Please add the second potion (B->C) in the catalyst slot"
	elif p.type != Item.ItemType.TRANSFORM:
		err_msg = "The second item (catalyst slot) does not look like a potion"
	elif not m.right.equals(p.right):
		err_msg = "The two potions must have the same output! Got: " + m.right.type_str() + " and " + p.right.type_str()

	if err_msg!=null:
		return [1, err_msg]
	else:
		var result := Item.t(Item.o(m.left, p.left), m.right)
		return [0, "Can disentangle! Yield: " + result.type_str() + " :>"]
	
func craft():
	var p = Globals.active_potion
	var m = Globals.active_material
	var pa = Globals.active_potion_actor
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	elif p == null:
		return
	elif m.type != Item.ItemType.TRANSFORM:
		return
	elif p.type != Item.ItemType.TRANSFORM:
		return
	elif not m.right.equals(p.right):
		return
	
	# Close Button
	Globals.active_material = null
	Globals.active_potion = null
	Globals.active_material_actor = null
	Globals.active_potion_actor = null
	root.on_potion_update()
	
	# Create the unified potion: (A|B)->C where A=m.left, B=p.left, C=m.right
	var result := Item.t(Item.o(m.left, p.left), m.right, (m.name + " Disentangler").strip_edges())
	
	# Start disentangle animation
	in_particle.emitting = true
	var tw = root.get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2(0, 0), 0.5)
	tw.parallel().tween_property(pa, "scale", Vector2(0, 0), 0.5)
	tw.tween_callback(func():
		ma.set_item(result)
		in_particle.emitting = true
		pa.queue_free()
	)
	tw.tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(result):
		# Game Won
		root.win_game()
	
	root.put_down(ma)