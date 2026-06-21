extends Control
class_name GameRoot

signal signal_transform
## Emit this to change mode.
signal mode_change(mode: OperationMode)
var buttonInPos:Vector2

## Item display prefab
var id=preload("res://partial/item_display.tscn")

## 相邻两个按钮的距离
const BTN_DIS: int=50

enum OperationMode{
	TRANSFORM,
	PACKAGE,
	UNPACKAGE,
	ENTANGLE,
	DISENTANGLE,
	DARK_INFUSE,
	PURIFY,
	TAUTOLOGIZE,
	MOLD,
	START_UPB,
	BALANCE_UPB,
	END_UPB
}

var operation_delegates:Array[OperationDelegate]=[
	TransformDelegate.new(),
	PackageDelegate.new(),
	UnpackageDelegate.new(),
	EntangleDelegate.new(),
	DisentangleDelegate.new(),
	DarkInfuseDelegate.new(),
	null,
	TautologizeDelegate.new(),
	MoldDelegate.new(),
	StartUpbDelegate.new(),
	BalanceUpbDelegate.new(),
	EndUpbDelegate.new()
]

var mode := OperationMode.TRANSFORM;

var upb_stack:Array[UPBLayer] = []
var upb_result_preview:Item = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup where to go
	ItemDisplay.inv=%HandContainer
	ItemDisplay.mki=%ItemHere
	ItemDisplay.mkp=%PotionHere
	ItemDisplay.up=$UpInv
	ItemDisplay.callback=on_potion_update
	
	# Setup delegates
	OperationDelegate.root=self
	OperationDelegate.id=id
	OperationDelegate.in_particle=$InParticle
	OperationDelegate.out_particle=$OutParticle
	OperationDelegate.item_here=$ItemHere
	OperationDelegate.tooltip=%Tooltip
	
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
	
	$TransformButton.text=operation_delegates[new_mode].transform_button_name()
	$HintText.text=operation_delegates[new_mode].hint_text()
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
	
	var result = operation_delegates[mode].update(m, p)
	
	var tw:=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
	
	if (p!=null and p.is_mold) or (m!=null and m.is_mold):
		if not operation_delegates[mode].can_use_mold():
			# Force override mold
			result=[1, "Hey! You cannot use mold in this machine!"]
	
	$TransformButton.disabled=result[0]!=0
	
	if not $TransformButton.disabled:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
	
	$HintText.text=result[1]
	
	if not upb_stack.is_empty():
		var layer:=get_inventory()
		var lost = layer.get_diff(upb_stack.back())
		var potion_chain := build_potion_chain(upb_stack.back().introduced,lost,Item.u("?") if upb_result_preview==null else upb_result_preview)
		print(lost)
		
		$UPBInfo.bbcode="""[font size=24][pulse freq=1.0 ease=-2.0]UPB In Action (Layer %d)[][]
[code]%s[]
"""%[len(upb_stack),potion_chain.type_str().capitalize()]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_upb_stack()

func update_upb_stack():
	if upb_stack.is_empty():
		$UPBInfo.hide()
		return
	$UPBInfo.show()
	
func start_upb(introduced: Item):
	var layer := get_inventory()
	layer.introduced=introduced
	upb_stack.append(layer)
	print("Starting UPB with %s!"%[introduced.type_str()])
	
func build_potion_chain(start: Item, middle: Array, end: Item) -> Item:
	var new_item:Item
	if middle.is_empty():
		new_item=Item.t(start,end)
	else:
		new_item=Item.t(middle.back(),end)
		for i in range(len(middle)-2,0,-1):
			new_item=Item.t(middle[i],new_item)
		new_item=Item.t(start,new_item)
	return new_item

func end_upb(main_yield: Item) -> Item:
	var last:UPBLayer=upb_stack.back()
	var layer:=get_inventory()
	var lost = layer.get_diff(last)
	print(lost)
	
	var new_item := build_potion_chain(last.introduced, lost, main_yield)
	
	if lost.is_empty():
		new_item=Item.t(last.introduced,main_yield)
	else:
		new_item=Item.t(lost.back(),main_yield)
		for i in range(len(lost)-2,0,-1):
			new_item=Item.t(lost[i],new_item)
		new_item=Item.t(last.introduced,new_item)
	
	for i in %HandContainer.get_children():
		i.queue_free()
	
	for i in last.items:
		var display:ItemDisplay = id.instantiate()
		display.set_item(i)
		%HandContainer.add_child(display)
		%Tooltip.bind(display)
	
	upb_stack.pop_back()
	
	return new_item
	

#	var new_layer := get_inventory()
#	print(new_layer.get_diff(upb_stack.back()))
	
func get_inventory() -> UPBLayer:
	var layer := UPBLayer.new()
	
	for child in %HandContainer.get_children():
		if child is ItemDisplay:
			layer.items.append(child.item)
	
	return layer
			
var won := false

func _on_transform_button_pressed() -> void:
	await operation_delegates[mode].craft()
	
	on_potion_update()

## Item should be ItemDisplay but somehow it might crash game
func put_down(item):
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


func _on_retry_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")


func _on_next_button_pressed() -> void:
	var layer:=get_inventory()
	var lost = layer.get_diff(upb_stack.back())
	print(lost)
