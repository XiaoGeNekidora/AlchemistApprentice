extends RichTextLabel
class_name TooltipWidget

var _motion_tween: Tween
var _text_style := StyleBoxEmpty.new()

@onready var _preview: ItemRenderer = $Preview


func _ready() -> void:
	add_theme_stylebox_override("normal", _text_style)

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
	# A single non-interactive canvas gives small/collapsed hand icons a readable
	# inspection view. It uses the same recursive layout, not child item actors.
	var content := item
	var depth := 0
	while content != null and content.type == Item.ItemType.NOT and depth < ItemRenderer.MAX_RENDER_DEPTH:
		content = content.left
		depth += 1
	var show_preview := content != null and content.left != null and content.right != null
	_preview.visible = show_preview
	_preview.set_item(item if show_preview else null)
	_text_style.content_margin_top = _preview.size.y + 12.0 if show_preview else 0.0
	_preview.position.x = (size.x - _preview.size.x) * 0.5

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
	# fit_content updates the minimum height, but a freely positioned Control
	# does not shrink itself when switching back to a shorter/unit tooltip.
	_fit_content_height.call_deferred()


func _fit_content_height() -> void:
	# Keep the wrapping width; reset_size() would also collapse it to one pixel.
	size.y = get_combined_minimum_size().y

func mouse_out(_i: Item):
	_kill_motion()
	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_motion_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	_motion_tween.tween_property(self, "scale", Vector2(0.94, 0.9), 0.1)
	_motion_tween.chain().tween_callback(hide)

func _process(_delta: float) -> void:
	var mp=get_global_mouse_position()
	var viewport := get_viewport_rect()
	if mp.x>viewport.size.x/2:
		position=mp-Vector2(25,25)-size
	else:
		position=mp+Vector2(25,25)
	# The compound inspection view is taller than a text-only tooltip. Keep its
	# background and artwork inside the viewport, including at the bottom edge.
	position.x = clampf(position.x, 16.0, maxf(16.0, viewport.size.x - size.x - 16.0))
	position.y = clampf(position.y, 16.0, maxf(16.0, viewport.size.y - size.y - 16.0))


func _kill_motion() -> void:
	if is_instance_valid(_motion_tween):
		_motion_tween.kill()
