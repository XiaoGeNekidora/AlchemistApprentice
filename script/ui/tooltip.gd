extends RichTextLabel

func bind(x:ItemDisplay):
	x.mouse_in.connect(mouse_in)
	x.mouse_out.connect(mouse_out)

func mouse_in(i: Item):
	build_tooltip(i)
	self.visible=true

func c(s:String, c: String) -> String:
	return "[color=%s]%s[/color]"%[c,s]
	
func build_tooltip(item: Item):
	var ttp=""
	if item.type==Item.ItemType.UNIT:
		ttp+="[font size=24]"+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]"+Globals.desc.get(item.name,"MISSING DESCRIPTION")+"[/i]\n"
	elif item.type==Item.ItemType.TRANSFORM:
		ttp+="[font size=24]"+c("Catalyst","pink")+" "+c(item.name.capitalize(),"red")+"[/font]\n"
		ttp+="[i]Transforms "+c(item.left.type_str().capitalize(),"green")+" into "+c(item.right.type_str().capitalize(),"cyan")+"[/i]\n"
	elif item.type==Item.ItemType.AND:
		ttp+="[font size=24]"+c("Mixture","purple")+" of "+c(item.left.type_str().capitalize(),"green")+" and "+c(item.right.type_str().capitalize(),"blue")+"[/font]\n"
		ttp+="[i]A mixture of two substances. Maybe there is a way to separate them?[/i]\n"
	elif item.type==Item.ItemType.OR:
		ttp+="[font size=24]"+c("Entanglement","purple")+" of "+c(item.left.type_str().capitalize(),"green")+" and "+c(item.right.type_str().capitalize(),"blue")+"[/font]\n"
		ttp+="[i]An entanglement mixture of two substances. Maybe there is a way to separate them?[/i]\n"
	self.text=ttp

func mouse_out(i: Item):
	self.visible=false

func _process(delta: float) -> void:
	var mp=get_global_mouse_position()
	if mp.x>get_viewport_rect().size.x/2:
		self.position=mp-Vector2(25,25)-self.get_rect().size
	else:
		self.position=get_global_mouse_position()+Vector2(25,25)
