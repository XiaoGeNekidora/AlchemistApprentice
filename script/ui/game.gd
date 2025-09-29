extends Control
class_name GameRoot

signal signal_transform

@onready var buttonInPos = $TransformButton.position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ItemDisplay.inv=%HandContainer
	ItemDisplay.mki=%ItemHere
	ItemDisplay.mkp=%PotionHere
	ItemDisplay.up=self
	ItemDisplay.callback=on_potion_update
	
	$Mission/RichTextLabel.bbcode=Globals.current_level.desc


## perform "can transform"?
func on_potion_update():
	var p=Globals.active_potion
	var m=Globals.active_material
	
	var err_msg=null
	if m==null:
		err_msg="Please add a base material"
	elif p==null:
		err_msg="Add a catalyst"
	elif p.type!=Item.ItemType.TRANSFORM:
		err_msg="That does not look like a catalyst"
	elif p.left!=m.type_str():
		err_msg="The catalyst does not seem to apply to that thing..."
	
	var tw=get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	$TransformButton.disabled=err_msg!=null
	
	if err_msg==null:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		
		$RichTextLabel.text="Yield: "+p.right+" :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		
		$RichTextLabel.text=err_msg
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_transform_button_pressed() -> void:
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
	elif p.left!=m.type_str():
		return
	
	# Close Button
	Globals.active_material=null
	Globals.active_potion=null
	Globals.active_material_actor=null
	Globals.active_potion_actor=null
	on_potion_update()
	
	# TODO close input for all itemdisplay
	
	# Start transform
	var tw=get_tree().create_tween()
	tw.tween_property(ma,"scale",Vector2(0,0),0.5)
	tw.tween_callback(func():
		ma.set_item(Item.from_str(p.right)))
	tw.tween_property(ma,"scale",Vector2(4,4),0.5)
	
	await tw.finished
	
	if Globals.current_level.win.type_str()==p.right:
		print("Game won")
		# TODO
	
	pa.slot=ItemDisplay.SLOT_BELOW
	ma.slot=ItemDisplay.SLOT_BELOW
	pa.reparent(%HandContainer)
	ma.reparent(%HandContainer)
	
	
	
