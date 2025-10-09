extends Control
class_name GameRoot

signal signal_transform

var buttonInPos:Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ItemDisplay.inv=%HandContainer
	ItemDisplay.mki=%ItemHere
	ItemDisplay.mkp=%PotionHere
	ItemDisplay.up=$UpInv
	ItemDisplay.callback=on_potion_update
	
	$Mission/RichTextLabel.bbcode=Globals.current_level.desc
	
	buttonInPos = $TransformButton.position
	$TransformButton.position=buttonInPos+Vector2(500,0)
	
	$TargetItem.set_item(Globals.current_level.win)
	$LevelName.text="Level %s %s\nTarget:"%[Globals.current_level.level_no,Globals.current_level.name]
	%Tooltip.bind($TargetItem)

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
	elif not p.left.equals(m):
		err_msg="The catalyst does not seem to apply to that thing..."
	
	var tw=get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	$TransformButton.disabled=err_msg!=null
	
	if err_msg==null:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		
		$HintText.text="LGTM. Yield: "+p.right.type_str().capitalize()+" :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		
		$HintText.text=err_msg
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


var won = false

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
	elif not p.left.equals(m):
		return
	
	# Close Button
	Globals.active_material=null
	Globals.active_potion=null
	Globals.active_material_actor=null
	Globals.active_potion_actor=null
	on_potion_update()
	
	# TODO close input for all itemdisplay
	
	# Start transform
	$InParticle.emitting=true
	var tw=get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma,"scale",Vector2(0,0),0.5)
	tw.tween_callback(func():
		ma.set_item(p.right)
		$OutParticle.emitting=true
	)
	tw.tween_property(ma,"scale",Vector2(4,4),0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(p.right):
		# Game Won
		if not won:
			won=true
			$Seal.visible=true
			tw=get_tree().create_tween().set_parallel()
			tw.tween_property($Seal,"position",$Seal.position,0.2).from($Seal.position+Vector2(30,-30))
			tw.tween_property($Seal,"self_modulate",Color.WHITE,0.2).from(Color(Color.WHITE,0))
			$WinParticle.emitting=true
			
	pa.slot=ItemDisplay.SLOT_BELOW
	ma.slot=ItemDisplay.SLOT_BELOW
	pa.reparent(%HandContainer)
	ma.reparent(%HandContainer)
	

func _on_retry_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
