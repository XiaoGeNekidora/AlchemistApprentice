extends Control
class_name GameRoot

signal signal_transform
## Emit this to change mode.
signal mode_change(mode: OperationMode)
var buttonInPos:Vector2

## 相邻两个按钮的距离
const BTN_DIS: int=50

enum OperationMode{
	TRANSFORM,
	PACKAGE,
	UNPACKAGE,
	ENTANGLE,
	DISENTANGLE,
	DARK_INFUSE,
	PURIFY
}

var mode := OperationMode.TRANSFORM;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup where to go
	ItemDisplay.inv=%HandContainer
	ItemDisplay.mki=%ItemHere
	ItemDisplay.mkp=%PotionHere
	ItemDisplay.up=$UpInv
	ItemDisplay.callback=on_potion_update
	
	# Set up available modes
	$Methods.set_modes(Globals.current_level.allowed_methods)
	mode_change.emit(OperationMode.TRANSFORM)
	mode_change.connect(on_mode_change)
	
	# Set up mission text
	$Mission/RichTextLabel.bbcode=Globals.current_level.desc
	
	# Set up button position outside screen
	buttonInPos = $TransformButton.position
	$TransformButton.position=buttonInPos+Vector2(500,0)
	
	# Set up level description
	$TargetItem.set_item(Globals.current_level.win)
	$TargetItem.clickable=false
	$LevelName.text="Level %s %s\nTarget:"%[Globals.current_level.level_no,Globals.current_level.name]
	%Tooltip.bind($TargetItem)

func on_mode_change(new_mode: OperationMode):
	print(new_mode,"<-",mode)
	
	if new_mode==mode:
		return
	
	if new_mode==OperationMode.TRANSFORM:
		$TransformButton.text="Transform!"
		$HintText.text="Let's see if we can transform something..."
	elif new_mode==OperationMode.PACKAGE:
		$TransformButton.text="Package!"
		$HintText.text="Let's see if we can package something..."
	elif new_mode==OperationMode.UNPACKAGE:
		$TransformButton.text="Break!"
		$HintText.text="Let's see if we can unpackage something..."
	elif new_mode==OperationMode.ENTANGLE:
		$TransformButton.text="Entangle!"
		$HintText.text="Let's see if we can entangle something..."
	elif new_mode==OperationMode.DISENTANGLE:
		$TransformButton.text="Disentangle!"
		$HintText.text="Place two potions with the same output to disentangle..."
	elif new_mode==OperationMode.DARK_INFUSE:
		$TransformButton.text="Dark Infuse!"
		$HintText.text="Place a potion A->B to get its dark variant (-B)->(-A)..."
	mode = new_mode
	
	put_down(Globals.active_potion_actor)
	put_down(Globals.active_material_actor)
	Globals.active_material=null
	Globals.active_potion=null
	Globals.active_material_actor=null
	Globals.active_potion_actor=null
	on_potion_update()
	
## perform "can transform"?
func on_potion_update():

	var p: Item=Globals.active_potion
	var m: Item=Globals.active_material
	
	if mode==OperationMode.TRANSFORM:
		transform_update(m,p)
	elif mode==OperationMode.PACKAGE:
		package_update(m,p)
	elif mode==OperationMode.UNPACKAGE:
		unpackage_update(m)
	elif mode==OperationMode.ENTANGLE:
		entangle_update(m,p)
	elif mode==OperationMode.DISENTANGLE:
		disentangle_update(m,p)
	elif mode==OperationMode.DARK_INFUSE:
		dark_infuse_update(m,p)
	

func transform_update(m: Item, p: Item):
	var err_msg=null
	if m==null:
		err_msg="Please add a base material"
	elif p==null:
		err_msg="Add a catalyst"
	elif p.type!=Item.ItemType.TRANSFORM:
		err_msg="That does not look like a catalyst"
	elif not p.left.equals(m):
		err_msg="The catalyst does not seem to apply to that thing..."
	
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled=err_msg!=null
	
	if not $TransformButton.disabled:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text="LGTM. Yield: "+p.right.type_str().capitalize()+" :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text=err_msg

func unpackage_update(m: Item):
	var err_msg=null
	if m==null:
		err_msg="Please add a package"
	elif m.type!=Item.ItemType.AND:
		err_msg="That is not a package"
		
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled=err_msg!=null
	
	if not $TransformButton.disabled:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text="Can unpackage! Into: "+m.left.type_str().capitalize()+" and "+m.right.type_str().capitalize()+" :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text=err_msg

func package_update(m: Item, p: Item):
	var err_msg=null
	if m==null:
		err_msg="Please add a base material"
	elif p==null:
		err_msg="Add another item to package"
	
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled=err_msg!=null
	
	if not $TransformButton.disabled:
		var result := Item.a(m, p)
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text="Can package! Yield: "+result.type_str().capitalize()+" :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text=err_msg


func entangle_update(m: Item, p: Item):
	# Entangle: input is a unified potion (A|B)->C, outputs are A->(A|B) and B->(A|B)
	var err_msg = null
	if m == null:
		err_msg = "Please add a potion to copy (A|B)->C in the material slot"
	elif m.type != Item.ItemType.TRANSFORM:
		err_msg = "That does not look like a potion"
	elif m.left.type != Item.ItemType.OR:
		err_msg = "The potion's input must be an entanglement (A|B)."
	
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled = err_msg != null
	
	if not $TransformButton.disabled:
		var output_a := Item.t(m.left.left, m.left)
		var output_b := Item.t(m.left.right, m.left)
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text = "Can entangle! Yield: " + output_a.type_str() + " and " + output_b.type_str() + " :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text = err_msg

func disentangle_update(m: Item, p: Item):
	# Validate: both inputs must be TRANSFORM potions, and their outputs must match
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
	
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled = err_msg != null
	
	if not $TransformButton.disabled:
		var result := Item.t(Item.o(m.left, p.left), m.right)
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text = "Can disentangle! Yield: " + result.type_str() + " :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text = err_msg

func dark_infuse_update(m: Item, p: Item):
	# Dark Infuse: input is a potion A->B, output is the dark variant (-B)->(-A)
	var err_msg = null
	if m == null:
		err_msg = "Please add a potion A->B in the material slot"
	elif m.type != Item.ItemType.TRANSFORM:
		err_msg = "That does not look like a potion"
	
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	$TransformButton.disabled = err_msg != null
	
	if not $TransformButton.disabled:
		# Smart negate: double negation cancels out (¬¬A = A)
		var neg_right = m.right.left if m.right.type == Item.ItemType.NOT else Item.n(m.right)
		var neg_left = m.left.left if m.left.type == Item.ItemType.NOT else Item.n(m.left)
		var result := Item.t(neg_right, neg_left)
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
		$HintText.text = "Can dark infuse! Yield: " + result.type_str() + " :>"
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
		$HintText.text = err_msg
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var won := false

func _on_transform_button_pressed() -> void:
	if mode==OperationMode.TRANSFORM:
		transform()
	elif mode==OperationMode.PACKAGE:
		package()
	elif mode==OperationMode.UNPACKAGE:
		unpackage()
	elif mode==OperationMode.ENTANGLE:
		entangle()
	elif mode==OperationMode.DISENTANGLE:
		disentangle()
	elif mode==OperationMode.DARK_INFUSE:
		dark_infuse()

func transform() -> void:
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
			
	put_down(pa)
	put_down(ma)

func unpackage() -> void:
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
		
	put_down(pa)
	put_down(ma)

func package() -> void:
	var p=Globals.active_potion
	var m=Globals.active_material
	var pa=Globals.active_potion_actor
	var ma=Globals.active_material_actor
	
	if m==null:
		return
	elif p==null:
		return
	
	# Close Button
	Globals.active_material=null
	Globals.active_potion=null
	Globals.active_material_actor=null
	Globals.active_potion_actor=null
	on_potion_update()
	
	# Create the package (AND type)
	var packaged := Item.a(m, p)
	
	# Start packaging animation
	$InParticle.emitting=true
	var tw=get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma,"scale",Vector2(0,0),0.5)
	tw.parallel().tween_property(pa,"scale",Vector2(0,0),0.5)
	tw.tween_callback(func():
		ma.set_item(packaged)
		$OutParticle.emitting=true
		pa.queue_free()
	)
	tw.tween_property(ma,"scale",Vector2(4,4),0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(packaged):
		# Game Won
		win_game()
			
	put_down(ma)

func entangle() -> void:
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
	add_child(pa)
	%Tooltip.bind(pa)
	pa.size = Vector2(24, 24)
	
	var pb = id.instantiate()
	pb.set_item(output_b)
	pb.scale = Vector2.ZERO
	pb.global_position = ma.global_position + Vector2(20, 0)
	add_child(pb)
	%Tooltip.bind(pb)
	pb.size = Vector2(24, 24)
	
	# Start entangle animation: original stays, two new items spawn from it
	$InParticle.emitting = true
	var tw = get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(pa, "scale", Vector2(4, 4), 0.5)
	tw.parallel().tween_property(pb, "scale", Vector2(4, 4), 0.5)
	tw.tween_callback(func():
		$OutParticle.emitting = true
	)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(output_a) or Globals.current_level.win.equals(output_b):
		# Game Won
		win_game()
	
	# Put down the two new outputs and the original input
	put_down(pa)
	put_down(pb)
	put_down(ma)
	
	# Clear globals and refresh UI
	Globals.active_material = null
	Globals.active_material_actor = null
	on_potion_update()

func disentangle() -> void:
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
	on_potion_update()
	
	# Create the unified potion: (A|B)->C where A=m.left, B=p.left, C=m.right
	var result := Item.t(Item.o(m.left, p.left), m.right, (m.name + " Disentangler").strip_edges())
	
	# Start disentangle animation
	$InParticle.emitting = true
	var tw = get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2(0, 0), 0.5)
	tw.parallel().tween_property(pa, "scale", Vector2(0, 0), 0.5)
	tw.tween_callback(func():
		ma.set_item(result)
		$OutParticle.emitting = true
		pa.queue_free()
	)
	tw.tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(result):
		# Game Won
		win_game()
	
	put_down(ma)

func dark_infuse() -> void:
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
	$InParticle.emitting = true
	$InParticle.modulate=Color.DARK_RED
	var tw = get_tree().create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(ma, "scale", Vector2(0, 0), 0.5)
	tw.tween_callback(func():
		$InParticle.modulate=Color.WHITE
		ma.set_item(result)
		$OutParticle.emitting = true
	)
	tw.tween_property(ma, "scale", Vector2(4, 4), 0.5)
	tw.tween_interval(1)
	await tw.finished
	
	if Globals.current_level.win.equals(result):
		# Game Won
		win_game()
	
	put_down(ma)

func put_down(item: ItemDisplay):
	if item==null:
		return
	item.slot = ItemDisplay.SLOT_BELOW
	item.reparent(%HandContainer)
	item.size=Vector2(24,24)
	
func win_game():
	if not won:
		won=true
		$Seal.visible=true
		var tw=get_tree().create_tween().set_parallel()
		tw.tween_property($Seal,"position",$Seal.position,0.2).from($Seal.position+Vector2(30,-30))
		tw.tween_property($Seal,"self_modulate",Color.WHITE,0.2).from(Color(Color.WHITE,0))
		$WinParticle.emitting=true

var id=preload("res://partial/item_display.tscn")

	
func _on_retry_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")
