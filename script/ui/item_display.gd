extends TextureRect
class_name ItemDisplay

enum{
	SLOT_BELOW,
	SLOT_UP,
	SLOT_POTION
}

var item: Item

var slot: int = SLOT_BELOW

var clickable = true
var _visual_tween: Tween
var _hover_visual_active := false

## Shared by all item displays while an operation result animation is running.
## This prevents hover/click tweens from writing scale/rotation at the same time
## as an operation delegate's tween.
static var operation_interaction_locked := false

static var up: Control
static var inv: Control
static var mki: Marker2D
static var mkp: Marker2D
static var callback: Callable

signal mouse_in(i:Item)
signal mouse_out(i:Item)


func _ready() -> void:
	add_to_group("item_displays")

func _on_mouse_entered() -> void:
	if operation_interaction_locked:
		return
	mouse_in.emit(self.item)
	if clickable:
		_hover_visual_active = true
		_animate_hover(true)
	

func _on_mouse_exited() -> void:
	$Tooltip.visible=false
	if operation_interaction_locked:
		return
	mouse_out.emit(self.item)
	if clickable:
		_animate_hover(false)

func on_transform():
	pass

func set_item(item: Item):
	self.item=item
	self.modulate=Color.WHITE
	if item.type==Item.ItemType.UNIT:
		self.texture=load("res://texture/item/"+item.name+".png")
	elif item.type==Item.ItemType.TRANSFORM:
		var id=["red","blue","white","pink","red2","blue2","greenb","redb"][item.hash()%8]
		self.texture=load("res://texture/potion_%s.png"%id)
	elif item.type==Item.ItemType.AND:
		self.texture=load("res://texture/mixture.png")
	elif item.type==Item.ItemType.OR:
		self.texture=load("res://texture/entanglement.png")
	elif item.type==Item.ItemType.NOT:
		set_item(item.left) 
		self.item=item #Set it back to the NOT item, but the texture is based on the left item
		self.modulate=Color.BLACK
	
	if item.is_mold:
		self.modulate.a=0.5
		
	if self.texture==null:
		self.texture=load("res://texture/unknown.png")

func _on_gui_input(event: InputEvent) -> void:
	if operation_interaction_locked or not clickable:
		return
	
	var root:GameRoot=get_tree().current_scene
	var mode:GameRoot.OperationMode=root.mode
	var delegate:OperationDelegate = root.operation_delegates[mode]
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			if slot==SLOT_BELOW:
				
				var mk:Marker2D
				if delegate.arg_count()>=1 and Globals.active_material==null:
					Globals.active_material=self.item
					Globals.active_material_actor=self
					self.slot=SLOT_UP
					mk=mki
				elif delegate.arg_count()>=2 and Globals.active_potion==null:
					Globals.active_potion=self.item
					Globals.active_potion_actor=self
					self.slot=SLOT_POTION
					mk=mkp
				else:
					_play_rejection()
					return
				
				
				self.reparent(up)
				
				self.size=Vector2(24,24)
				
				clickable=false
				_hover_visual_active = false
				_kill_visual_tween()
				var tw=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
				tw.set_parallel(true)
				tw.tween_property(self,"position",mk.position-self.size/2,0.5)
				tw.tween_property(self,"rotation",mk.rotation,0.5)
				tw.tween_property(self,"scale",Vector2(4,4),0.5)
				tw.tween_property(self, "self_modulate", Color.WHITE, 0.24)
				tw.chain().tween_callback(func(): clickable=true)
				
				# Notify Master
				callback.call()
			else:
				_hover_visual_active = false
				_kill_visual_tween()
				
				if slot==SLOT_UP:
					Globals.active_material=null
					Globals.active_material_actor=null
				else:
					Globals.active_potion=null
					Globals.active_potion_actor=null
					
				slot=SLOT_BELOW
				self.reparent(inv)
				self.size=Vector2(24,24)
				
				callback.call()

func _process(_delta):
	$Tooltip.rotation=-self.rotation


func _animate_hover(hovered: bool) -> void:
	if operation_interaction_locked:
		return
	_hover_visual_active = true
	_kill_visual_tween()
	var rest_scale := Vector2(3.0, 3.0) if slot == SLOT_BELOW else Vector2(4.0, 4.0)
	var target_scale := rest_scale * (1.09 if hovered else 1.0)
	var rest_rotation := _rest_rotation()
	var hover_direction := -1.0 if item.hash() % 2 == 0 else 1.0
	var target_rotation := rest_rotation + deg_to_rad(hover_direction * 2.2) if hovered else rest_rotation
	_visual_tween = create_tween().set_parallel(true)
	_visual_tween.set_trans(Tween.TRANS_BACK if hovered else Tween.TRANS_ELASTIC)
	_visual_tween.set_ease(Tween.EASE_OUT)
	_visual_tween.tween_property(self, "scale", target_scale, 0.18 if hovered else 0.28)
	_visual_tween.tween_property(self, "rotation", target_rotation, 0.18 if hovered else 0.28)
	_visual_tween.tween_property(self, "self_modulate", Color(0.912, 0.803, 1.056, 1.0) if hovered else Color.WHITE, 0.16)
	if not hovered:
		_visual_tween.finished.connect(func() -> void:
			_hover_visual_active = false
		)


func _play_rejection() -> void:
	if operation_interaction_locked:
		return
	_hover_visual_active = false
	_kill_visual_tween()
	var origin := position
	_visual_tween = create_tween()
	_visual_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_visual_tween.tween_property(self, "position", origin + Vector2(-7.0, 0.0), 0.045)
	_visual_tween.tween_property(self, "position", origin + Vector2(7.0, 0.0), 0.07)
	_visual_tween.tween_property(self, "position", origin + Vector2(-4.0, 0.0), 0.06)
	_visual_tween.tween_property(self, "position", origin, 0.06)


func _kill_visual_tween() -> void:
	if is_instance_valid(_visual_tween):
		_visual_tween.kill()


func cancel_hover_for_operation() -> void:
	$Tooltip.visible = false
	# Only reset an ItemDisplay whose hover animation actually owns its visual
	# transform. TargetItem and items currently moving in the hand use the same
	# scene, but their scale belongs to their own presentation/layout animation.
	if not _hover_visual_active:
		return
	_hover_visual_active = false
	_kill_visual_tween()
	self_modulate = Color.WHITE
	scale = Vector2(3.0, 3.0) if slot == SLOT_BELOW else Vector2(4.0, 4.0)
	rotation = _rest_rotation()


func _rest_rotation() -> float:
	if slot == SLOT_UP and is_instance_valid(mki):
		return mki.rotation
	if slot == SLOT_POTION and is_instance_valid(mkp):
		return mkp.rotation
	return 0.0
