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

static var up: Control
static var inv: Control
static var mki: Marker2D
static var mkp: Marker2D
static var callback: Callable

signal mouse_in(i:Item)
signal mouse_out(i:Item)

func _on_mouse_entered() -> void:
	mouse_in.emit(self.item)
	

func _on_mouse_exited() -> void:
	mouse_out.emit(self.item)
	$Tooltip.visible=false

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
		
	if self.texture==null:
		self.texture=load("res://texture/unknown.png")

func _on_gui_input(event: InputEvent) -> void:
	if not clickable:
		return
	
	var root:GameRoot=get_tree().current_scene
	var mode:GameRoot.OperationMode=root.mode
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			if slot==SLOT_BELOW:
				
				var mk:Marker2D
				if Globals.active_material==null:
					Globals.active_material=self.item
					Globals.active_material_actor=self
					self.slot=SLOT_UP
					mk=mki
				elif mode!=GameRoot.OperationMode.UNPACKAGE and mode!=GameRoot.OperationMode.ENTANGLE and mode!=GameRoot.OperationMode.DARK_INFUSE and mode!=GameRoot.OperationMode.TAUTOLOGIZE and Globals.active_potion==null:
					Globals.active_potion=self.item
					Globals.active_potion_actor=self
					self.slot=SLOT_POTION
					mk=mkp
				else:
					#TODO animation
					return
				
				# Notify Master
				callback.call()
				
				self.reparent(up)
				
				self.size=Vector2(24,24)
				
				clickable=false
				var tw=get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel()
				tw.tween_property(self,"position",mk.position-self.size/2,0.5)
				tw.tween_property(self,"rotation",mk.rotation,0.5)
				tw.tween_property(self,"scale",Vector2(4,4),0.5)
				tw.tween_callback(func(): clickable=true)
				
			else:
				
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

func _process(delta):
	$Tooltip.rotation=-self.rotation
