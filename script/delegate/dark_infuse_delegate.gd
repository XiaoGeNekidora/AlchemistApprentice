extends OperationDelegate
class_name DarkInfuseDelegate

func get_operation_name() -> String:
	return "Dark Infuse"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Infuse!!"

func hint_text() -> String:
	return "???"

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	# Dark Infuse: input is a potion A->B, output is the dark variant (-B)->(-A)
	var err_msg = null
	if m == null:
		err_msg = "Please add a potion A->B in the material slot"
	elif m.type != Item.ItemType.TRANSFORM:
		err_msg = "That does not look like a potion"

	if err_msg!=null:
		return [1, err_msg]
	else:
		var neg_right = m.right.left if m.right.type == Item.ItemType.NOT else Item.n(m.right)
		var neg_left = m.left.left if m.left.type == Item.ItemType.NOT else Item.n(m.left)
		var result := Item.t(neg_right, neg_left)
		return [0, "Can dark infuse! Yield: " + result.type_str() + " :>"]
	
func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	elif m.type != Item.ItemType.TRANSFORM:
		return
	
	# Close Button
	Globals.active_material = null
	Globals.active_material_actor = null
	on_potion_update()
	
	# Create the dark potion: (-B)->(-A), with double-negation cancellation
	var neg_right = m.right.left if m.right.type == Item.ItemType.NOT else Item.n(m.right)
	var neg_left = m.left.left if m.left.type == Item.ItemType.NOT else Item.n(m.left)
	var result := Item.t(neg_right, neg_left, m.name.reverse())
	
	# Start dark infuse animation
	in_particle.emitting = true
	in_particle.modulate=Color.DARK_RED
	var tw = get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2(0, 0), 0.5)
	tw.tween_callback(func():
		in_particle.modulate=Color.WHITE
		ma.set_item(result)
		in_particle.emitting = true
	)
	tw.tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(result):
		# Game Won
		win_game()
	
	put_down(ma)
