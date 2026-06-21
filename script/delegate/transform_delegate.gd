extends OperationDelegate
class_name TransformDelegate

func get_operation_name() -> String:
	return "Transform"

func arg_count() -> int:
	return 2

func transform_button_name() -> String:
	return "Transform!!"

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	var err_msg=null
	if m==null:
		err_msg="Please add a base material"
	elif p==null:
		err_msg="Add a catalyst"
	elif p.type!=Item.ItemType.TRANSFORM:
		err_msg="That does not look like a catalyst"
	elif not p.left.equals(m):
		err_msg="The catalyst does not seem to apply to that thing..."
	
	if err_msg!=null:
		return [1,err_msg]
	else:
		return [0,"LGTM. Yield: "+p.right.type_str().capitalize()+" :>"]
	
func craft():
	var p=Globals.active_potion
	var m=Globals.active_material
	var pa=Globals.active_potion_actor
	var ma=Globals.active_material_actor
	
	if m==null:
		return
	elif p==null:
		return
	elif p.type!=Item.ItemType.TRANSFORM:
		return
	elif not p.left.equals(m):
		return
	
	# Close Button
	Globals.active_material=null
	Globals.active_potion=null
	Globals.active_material_actor=null
	Globals.active_potion_actor=null
	root.on_potion_update()
	
	# TODO close input for all itemdisplay
	
	# Start transform
	in_particle.emitting=true
	var tw=root.get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma,"scale",Vector2(0,0),0.5)
	tw.tween_callback(func():
		ma.set_item(p.right)
		out_particle.emitting=true
	)
	tw.tween_property(ma,"scale",Vector2(4,4),0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(p.right):
		# Game Won
		root.win_game()
			
	root.put_down(pa)
	root.put_down(ma)