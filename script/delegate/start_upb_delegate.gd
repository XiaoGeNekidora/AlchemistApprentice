extends OperationDelegate
class_name StartUpbDelegate

func can_use_mold() -> bool:
	return true
	
func get_operation_name() -> String:
	return "Start UPB"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "Start UPB!!"

func hint_text() -> String:
	return "Start Universal Potion Brewer with a mold. The mold will be consumed."

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	if m == null:
		return [1, "Please add a mold to start UPB"]
	if not m.is_mold:
		return [1, "Only a mold can be used to start UPB"]
	return [0, "Will start UPB recording with the mold. The mold will be consumed."]
	
func craft():
	var m = Globals.active_material
	var ma = Globals.active_material_actor
	
	if m == null:
		return
	if not m.is_mold:
		return
	
	# Generate the real item from the mold (clone without is_mold)
	var result := m.clone()
	result.is_mold = false
	
	# Spawn a new item display for the result
	var pa = id.instantiate()
	pa.set_item(result)
	pa.scale = Vector2.ZERO
	pa.global_position = ma.global_position
	root.add_child(pa)
	tooltip.bind(pa)
	pa.size = Vector2(24, 24)
	
	# Clear globals and close button
	Globals.active_material = null
	Globals.active_material_actor = null
	root.on_potion_update()
	
	# Call start_upb with the generated item at the beginning of craft
	root.start_upb(result)
	
	# Animate: mold shrinks while result scales up from the mold position
	in_particle.emitting = true
	var tw = root.get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2.ZERO, 0.5)
	tw.parallel().tween_property(pa, "scale", Vector2(4, 4), 0.5)
	tw.tween_callback(func():
		out_particle.emitting = true
	)
	tw.tween_interval(1)
	await tw.finished
	
	# Put down the result, consume the mold actor
	root.put_down(pa)
	ma.queue_free()
	
	# Refresh UI
	root.on_potion_update()