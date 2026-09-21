extends RichTextLabel
class_name TooltipWidget

var _motion_tween: Tween

func bind(x:ItemDisplay):
	x.mouse_in.connect(mouse_in)
	x.mouse_out.connect(mouse_out)

func mouse_in(i: Item):
	_kill_motion()
	build_tooltip(i)
	self.visible=true
	pivot_offset = size * 0.5
	modulate.a = 0.0
	scale = Vector2(0.86, 0.86)
	rotation = deg_to_rad(-1.4)
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(self, "modulate:a", 1.0, 0.14)
	_motion_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	_motion_tween.tween_property(self, "rotation", 0.0, 0.2)

func c(s:String, c: String) -> String:
	return "[color=%s]%s[/color]"%[c,s]
	
func build_tooltip(item: Item):
	var ttp=""
	
	if item.is_mold:
		ttp+="[color=gray]Mold[/color] "
	
	if item.type==Item.ItemType.UNIT:
		ttp+="[font size=24]"+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]"+Globals.desc.get(item.name,"MISSING DESCRIPTION")+"[/i]\n"
	elif item.type==Item.ItemType.TRANSFORM:
		ttp+="[font size=24]"+c("Catalyst","pink")+" "+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]Transforms "+c(item.left.type_str().capitalize(),"green")+" into "+c(item.right.type_str().capitalize(),"cyan")+"[/i]\n"
	elif item.type==Item.ItemType.AND:
		ttp+="[font size=24]"+c("Mixture","pink")+" "+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]A mixture of "+c(item.left.type_str().capitalize(),"green")+" and "+c(item.right.type_str().capitalize(),"cyan")+". Use the unpackager to separate them.[/i]\n"
	elif item.type==Item.ItemType.OR:
		ttp+="[font size=24]"+c("Entanglement","purple")+" "+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]An entanglement of "+c(item.left.type_str().capitalize(),"green")+" and "+c(item.right.type_str().capitalize(),"blue")+". Use the disentangler to craft potions that can transform it.[/i]\n"
	elif item.type==Item.ItemType.NOT:
		ttp+="[font size=24]"+c("Corrupted","47110b")+" "+c(item.left.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]The inversion of "+c(item.left.type_str().capitalize(),"green")+". DO NOT TOUCH.[/i]\n"
	
	ttp+="[color=gray][font size=12]"+item.type_str().capitalize()+"[/font][/color]"
	self.text=ttp

func mouse_out(_i: Item):
	_kill_motion()
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_motion_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	_motion_tween.tween_property(self, "scale", Vector2(0.94, 0.9), 0.1)
	_motion_tween.chain().tween_callback(hide)

func _process(_delta: float) -> void:
	var mp=get_global_mouse_position()
	if mp.x>get_viewport_rect().size.x/2:
		self.position=mp-Vector2(25,25)-self.get_rect().size
	else:
		self.position=get_global_mouse_position()+Vector2(25,25)


func _kill_motion() -> void:
	if is_instance_valid(_motion_tween):
		_motion_tween.kill()
