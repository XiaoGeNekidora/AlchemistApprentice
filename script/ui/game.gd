extends Control
class_name GameRoot

signal signal_transform

var buttonInPos:Vector2

## 相邻两个按钮的距离
const BTN_DIS=50

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
	$BreakButton.position=buttonInPos+Vector2(500,BTN_DIS)
	
	$TargetItem.set_item(Globals.current_level.win)
	$TargetItem.clickable=false
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
	
	var tw=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled=err_msg!=null
	$BreakButton.disabled= m==null or m.type!=Item.ItemType.AND
	
	if not $BreakButton.disabled and err_msg!=null:
		err_msg+="... or break it"
		
	if not $TransformButton.disabled:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text="LGTM. Yield: "+p.right.type_str().capitalize()+" :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text=err_msg
	
	if not $BreakButton.disabled:
		tw.tween_property($BreakButton,"position",buttonInPos+Vector2(0,BTN_DIS),0.5)
	else:
		tw.tween_property($BreakButton,"position",buttonInPos+Vector2(300,BTN_DIS),0.5)
		
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
		win_game()
			
	pa.slot=ItemDisplay.SLOT_BELOW
	ma.slot=ItemDisplay.SLOT_BELOW
	pa.reparent(%HandContainer)
	ma.reparent(%HandContainer)
	pa.size=Vector2(24,24)
	ma.size=Vector2(24,24)
	
func win_game():
	if not won:
		won=true
		$Seal.visible=true
		var tw=get_tree().create_tween().set_parallel()
		tw.tween_property($Seal,"position",$Seal.position,0.2).from($Seal.position+Vector2(30,-30))
		tw.tween_property($Seal,"self_modulate",Color.WHITE,0.2).from(Color(Color.WHITE,0))
		$WinParticle.emitting=true

var id=preload("res://partial/item_display.tscn")

func _on_break_button_pressed() -> void:
	var m=Globals.active_material
	var ma=Globals.active_material_actor
	var pa=null
	
	if m==null:
		return
	elif m.type!=Item.ItemType.AND:
		return
	
	# Close Button
	Globals.active_material=null
	Globals.active_material_actor=null
	on_potion_update()
	
	# TODO close input for all itemdisplay
	
	# Start transform
	
	pa=id.instantiate()
	pa.set_item(m.right)
	pa.scale=Vector2.ZERO
	pa.global_position=ma.global_position
	add_child(pa)
	%Tooltip.bind(pa)
	pa.size=Vector2(24,24)
	
	$InParticle.emitting=true
	var tw=get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma,"scale",Vector2(0,0),0.5)
	tw.tween_callback(func():
		ma.set_item(m.left)
		$OutParticle.emitting=true
	)
	
	tw.tween_property(pa,"scale",Vector2(4,4),0.5)
	tw.parallel().tween_property(ma,"scale",Vector2(4,4),0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(m.left) or Globals.current_level.win.equals(m.right):
		# Game Won
		win_game()
			
	pa.slot=ItemDisplay.SLOT_BELOW
	ma.slot=ItemDisplay.SLOT_BELOW
	pa.reparent(%HandContainer)
	ma.reparent(%HandContainer)
	pa.size=Vector2(24,24)
	ma.size=Vector2(24,24)
	
func _on_retry_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")
