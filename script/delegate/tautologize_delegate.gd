extends OperationDelegate
class_name TautologizeDelegate

func get_operation_name() -> String:
	return "Tautologize"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Tautologize!!"

func hint_text() -> String:
	return "Place any substance (or nothing) to create its self-implication..."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m: Item, p: Item) -> Array:
	# Tautologize always succeeds - input: any substance A (optional), output: A->A
	# No input: output is T->T where T = current_level.win
	var result: Item
	if m == null:
		var target = Globals.current_level.win
		result = Item.t(target, target)
		return [0, "No material? Will create this: " + result.type_str() + " :>"]
	else:
		result = Item.t(m, m)
		return [0, "Can tautologize! Yield: " + result.type_str() + " :>"]

func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	# Tautologize always succeeds - either with input or without
	
	# Determine result
	var result: Item
	if m == null:
		# No input: create T->T where T = current_level.win
		var target = Globals.current_level.win
		result = Item.t(target, target, "Tautology")
	else:
		# Input given: create A->A, original A is NOT consumed
		result = Item.t(m, m, "Tautology")
	
	# Close Button
	Globals.active_material = null
	Globals.active_material_actor = null
	root.on_potion_update()
	
	# Spawn a new item display for the result
	var pa = id.instantiate()
	pa.set_item(result)
	pa.scale = Vector2.ZERO
	if ma != null:
		pa.global_position = ma.global_position
	else:
		pa.global_position = item_here.global_position
	root.add_child(pa)
	tooltip.bind(pa)
	pa.size = Vector2(24, 24)
	
	# If there was an input, keep it (don't consume it)
	# The original ma just stays in the hand area
	
	# Start tautologize animation
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
		# Game Won
		root.win_game()
	
	# Put down the new result and the original input (if any)
	root.put_down(pa)
	if ma != null:
		root.put_down(ma)
