class_name EntangleDelegate
extends OperationDelegate

func get_operation_name() -> String:
	return "Entangle"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Entangle!!"

func hint_text() -> String:
	return ""

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	var err_msg = null
	if m == null:
		err_msg = "Please add a potion to copy (A|B)->C in the material slot"
	elif m.type != Item.ItemType.TRANSFORM:
		err_msg = "That does not look like a potion"
	elif m.left.type != Item.ItemType.OR:
		err_msg = "The potion's input must be an entanglement (A|B)."
	
	if err_msg != null:
		return [1, err_msg]
	else:
		var output_a := Item.t(m.left.left, m.left)
		var output_b := Item.t(m.left.right, m.left)
		return [0, "Can entangle! Yield: " + output_a.type_str() + " and " + output_b.type_str() + " :>"]
	
func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	elif m.type != Item.ItemType.TRANSFORM:
		return
	elif m.left.type != Item.ItemType.OR:
		return
	
	# Create the two half-potions: A->(A|B) and B->(A|B)
	var output_a := Item.t(m.left.left, m.left,(m.name + " Entangler A").strip_edges())
	var output_b := Item.t(m.left.right, m.left,(m.name + " Entangler B").strip_edges())
	
	# Spawn two new item displays for the outputs (original input is NOT consumed)
	var pa = id.instantiate()
	pa.set_item(output_a)
	pa.scale = Vector2.ZERO
	pa.global_position = ma.global_position
	root.add_child(pa)
	tooltip.bind(pa)
	pa.size = Vector2(24, 24)
	
	var pb = id.instantiate()
	pb.set_item(output_b)
	pb.scale = Vector2.ZERO
	pb.global_position = ma.global_position + Vector2(20, 0)
	root.add_child(pb)
	tooltip.bind(pb)
	pb.size = Vector2(24, 24)
	
	# Start entangle animation: original stays, two new items spawn from it
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
	
	if Globals.current_level.win.equals(output_a) or Globals.current_level.win.equals(output_b):
		# Game Won
		root.win_game()
	
	# Put down the two new outputs and the original input
	root.put_down(pa)
	root.put_down(pb)
	root.put_down(ma)
	
	# Clear globals and refresh UI
	Globals.active_material = null
	Globals.active_material_actor = null
	root.on_potion_update() 