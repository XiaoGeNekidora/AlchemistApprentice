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

func _on_mouse_entered() -> void:
	build_tooltip()
	$Tooltip.visible=true

func c(s:String, c: String) -> String:
	return "[color=%s]%s[/color]"%[c,s]
func build_tooltip():
	var ttp=""
	if item.type==Item.ItemType.UNIT:
		ttp+="[font size=9]"+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]"+Globals.desc.get(item.name,"MISSING DESCRIPTION")+"[/i]\n"
	elif item.type==Item.ItemType.TRANSFORM:
		ttp+="[font size=9]"+c("Catalyst","purple")+" "+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]Transforms "+c(item.left.type_str().capitalize(),"green")+" into "+c(item.right.type_str().capitalize(),"blue")+"[/i]\n"
	elif item.type==Item.ItemType.AND:
		ttp+="[font size=9]"+c("Mixture","purple")+" of "+c(item.left.type_str().capitalize(),"green")+" and "+c(item.right.type_str().capitalize(),"blue")+"[/font]\n"
		ttp+="[i]A mixture of two substances. Maybe there is a way to separate them?[/i]\n"
	elif item.type==Item.ItemType.OR:
		ttp+="[font size=9]"+c("Entanglement","purple")+" of "+c(item.left.type_str().capitalize(),"green")+" and "+c(item.right.type_str().capitalize(),"blue")+"[/font]\n"
		ttp+="[i]An entanglement mixture of two substances. Maybe there is a way to separate them?[/i]\n"
		
		
	$Tooltip.text=ttp

func _on_mouse_exited() -> void:
	$Tooltip.visible=false

func on_transform():
	pass

func set_item(item: Item):
	self.item=item
	if item.type==Item.ItemType.UNIT:
		self.texture=load("res://texture/item/"+item.name+".png")
	elif item.type==Item.ItemType.TRANSFORM:
		self.texture=load("res://texture/potion_red.png")
		
	if self.texture==null:
		self.texture=load("res://texture/unknown.png")
func _on_gui_input(event: InputEvent) -> void:
	if not clickable:
		return
		
	if event is InputEventMouseButton:
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			if slot==SLOT_BELOW:
				
				var mk:Marker2D
				if Globals.active_material==null:
					Globals.active_material=self.item
					Globals.active_material_actor=self
					self.slot=SLOT_UP
					mk=mki
				elif Globals.active_potion==null:
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
