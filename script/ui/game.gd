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
	TAUTOLOGIZE
}

var operation_delegates:Array[OperationDelegate]=[
	TransformDelegate.new(),
	PackageDelegate.new(),
	UnpackageDelegate.new(),
	EntangleDelegate.new(),
	DisentangleDelegate.new(),
	DarkInfuseDelegate.new(),
	null,
	TautologizeDelegate.new()
]

var mode := OperationMode.TRANSFORM;

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
	$TransformButton.disabled=result[0]!=0
	
	if not $TransformButton.disabled:
		tw.tween_property($TransformButton,"position",buttonInPos,0.5)
	else:
		tw.tween_property($TransformButton,"position",buttonInPos+Vector2(300,0),0.5)
	
	$HintText.text=result[1]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var won := false

func _on_transform_button_pressed() -> void:
	operation_delegates[mode].craft()

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
