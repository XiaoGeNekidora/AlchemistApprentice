extends Control
class_name GameRoot

signal signal_transform
## Emit this to change mode.
signal mode_change(mode: OperationMode)

@onready var animations: GameAnimationDirector = $AnimationDirector

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
var _upb_was_active := false

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
	mode_change.connect(on_mode_change)
	
	# Set up mission text
	$Mission/RichTextLabel.bbcode=Globals.current_level.desc
	
	# Set up level description
	$TargetItem.set_item(Globals.current_level.win)
	$TargetItem.clickable=false
	$LevelName.text="Level %s %s\nTarget:"%[Globals.current_level.level_no,Globals.current_level.name]
	%Tooltip.bind($TargetItem)

	# Presentation is staged only after all gameplay data is ready. The animation
	# controller never decides rules; it only receives the resulting UI state.
	animations.prepare_opening()
	$TransformButton.text = operation_delegates[mode].transform_button_name()
	on_potion_update(true)
	await SceneTransition.wait_for_reveal()
	await animations.play_opening()

func on_mode_change(new_mode: OperationMode):
	print(new_mode,"<-",mode)
	
	if new_mode==mode:
		return
	
	$TransformButton.text=operation_delegates[new_mode].transform_button_name()
	mode = new_mode
	
	put_down(Globals.active_potion_actor)
	put_down(Globals.active_material_actor)
	Globals.active_material=null
	Globals.active_potion=null
	Globals.active_material_actor=null
	Globals.active_potion_actor=null
	on_potion_update()
	
## perform "can transform"?
func on_potion_update(immediate := false):

	var p: Item=Globals.active_potion
	var m: Item=Globals.active_material
	
	var result = operation_delegates[mode].update(m, p)
	
	if (p!=null and p.is_mold) or (m!=null and m.is_mold):
		if not operation_delegates[mode].can_use_mold():
			# Force override mold
			result=[1, "Hey! You cannot use mold in this machine!"]
	
	$TransformButton.disabled=result[0]!=0
	animations.set_action_available(not $TransformButton.disabled, immediate)
	animations.show_hint(result[1], result[0] != 0, immediate)
	
	if not upb_stack.is_empty():
		var layer:=get_inventory()
		var lost = layer.get_diff(upb_stack.back())
		var potion_chain := build_potion_chain(upb_stack.back().introduced,lost,Item.u("?") if upb_result_preview==null else upb_result_preview)
		print(lost)
		
		$UPBInfo.bbcode="""[font size=24][pulse freq=1.0 ease=-2.0]UPB In Action (Layer %d)[][]
[code]%s[]
"""%[len(upb_stack),potion_chain.type_str().capitalize()]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_upb_stack()

func update_upb_stack():
	var active := not upb_stack.is_empty()
	if active == _upb_was_active:
		return
	_upb_was_active = active
	animations.show_upb_state(active)
	
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
		for i in range(len(middle)-2,-1,-1):
			new_item=Item.t(middle[i],new_item)
		new_item=Item.t(start,new_item)
	return new_item

func end_upb(main_yield: Item) -> Item:
	var last:UPBLayer=upb_stack.back()
	var layer:=get_inventory()
	var lost = layer.get_diff(last)
	print(lost)
	
	var new_item := build_potion_chain(last.introduced, lost, main_yield)
	
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
		animations.play_win()


func _on_retry_btn_pressed() -> void:
	SceneTransition.change_scene("res://game.tscn")


func _on_back_btn_pressed() -> void:
	SceneTransition.change_scene("res://level_select.tscn")


func _on_next_button_pressed() -> void:
	var level_ids := Globals.all_levels.keys()
	var current_index := -1
	var current_script: Script = Globals.current_level.get_script()
	for index in level_ids.size():
		if Globals.all_levels[level_ids[index]] == current_script:
			current_index = index
			break

	if current_index < 0 or current_index + 1 >= level_ids.size():
		SceneTransition.change_scene("res://level_select.tscn")
		return

	Globals.current_level = Globals.all_levels[level_ids[current_index + 1]].new()
	SceneTransition.change_scene("res://game.tscn")
