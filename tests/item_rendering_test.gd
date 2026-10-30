extends Node

## Run: Godot --headless --path . res://tests/item_rendering_test.tscn
## Optional GPU gallery: omit --headless and append -- --gallery=/tmp/items.png
var _failures := 0
var _checks := 0
@onready var root: Window = get_tree().root


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1152, 648)
	var renderer := ItemRenderer.new()
	root.add_child(renderer)
	renderer.size = Vector2(24, 24)
	_expect(renderer.render_mode == ItemRenderer.RenderMode.ITEM, "default renderer draws physical items")
	_test_item_presentation(renderer)
	renderer.render_mode = ItemRenderer.RenderMode.STRUCTURE
	renderer.set_item(Item.u("gold"))
	_expect(_textures(renderer).size() == 1, "a unit draws exactly one sprite")
	_expect(_textures(renderer)[0].texture.resource_path.ends_with("/item/gold.png"), "unit texture is unchanged")
	_expect(renderer.get_child_count() == 0, "renderer has no ingredient nodes")

	for type in [Item.ItemType.TRANSFORM, Item.ItemType.AND, Item.ItemType.OR]:
		renderer.set_item(Item.new(type, "", Item.u("iron"), Item.u("gold")))
		var textures := _textures(renderer)
		_expect(textures.size() == 3, "binary type %d draws its header and both ingredients" % type)
		_expect(textures[1].rect.position.x < textures[2].rect.position.x, "ingredient order is left-to-right")
		_expect(textures[1].texture.resource_path.ends_with("/iron.png"), "left ingredient retains its texture")
		_expect(textures[2].texture.resource_path.ends_with("/gold.png"), "right ingredient retains its texture")
		_expect(_commands(renderer, "line").size() >= 6, "binary relationship is represented by geometry, not just color")

	var nested := _nested_item()
	renderer.set_item(nested)
	var small_count := _textures(renderer).size()
	_expect(small_count > 3, "nested ingredients are drawn recursively")
	_expect(_commands(renderer, "circle").size() > 0, "tiny compound ingredients show an explicit ellipsis")
	renderer.size = Vector2(180, 180)
	_expect(_textures(renderer).size() > small_count, "resizing the inspection view expands more detail")
	_expect(_commands(renderer, "circle").is_empty(), "inspection view resolves this entire example")
	_expect(renderer.get_child_count() == 0, "recursive layout still creates no child nodes")
	for command in _textures(renderer):
		_expect(Rect2(Vector2.ZERO, renderer.size).encloses(command.rect), "recursive drawing stays inside its bounds")

	renderer.set_item(Item.a(Item.u("gold").set_mold(), Item.n2("iron")))
	var effects := _textures(renderer)
	_expect(is_equal_approx(effects[0].color.a, 1.0), "a nested mold does not fade its parent")
	_expect(is_equal_approx(effects[1].color.a, 0.5), "nested mold keeps its own opacity")
	_expect(effects[2].color == Color.BLACK, "nested corruption keeps its black silhouette")
	_expect(renderer.modulate == Color.WHITE, "item effects do not modify animation modulation")
	renderer.set_item(Item.n(Item.a2("gold", "iron")).set_mold())
	_expect(_textures(renderer).size() == 3, "a corrupted compound still draws both ingredients")
	for command in _textures(renderer):
		_expect(command.color == Color(0, 0, 0, 0.5), "outer corruption and mold propagate to all ingredients")
	renderer.modulate = Color.WHITE
	_expect(_textures(renderer)[0].color == Color(0, 0, 0, 0.5), "entrance animation cannot erase item effects")

	renderer.set_item(Item.u("missing_render_test_texture"))
	_expect(_textures(renderer)[0].texture == ItemRenderer.UNKNOWN_TEXTURE, "missing textures fall back safely")
	renderer.set_item(null)
	_expect(_textures(renderer).size() == 1, "clearing an item removes its previous compound drawing")
	var deep := Item.u("gold")
	for i in range(40):
		deep = Item.n(deep)
	renderer.set_item(deep)
	_expect(_commands(renderer, "circle").size() == 3, "very deep wrappers terminate with an explicit fallback")

	var display := load("res://partial/item_display.tscn").instantiate() as ItemDisplay
	root.add_child(display)
	display.set_item(nested)
	var child_count := display.get_child_count()
	display.set_item(Item.u("stone"))
	display.set_item(nested)
	_expect(display.get_class() == "Control", "interactive item uses custom canvas drawing")
	_expect(display.get_child_count() == child_count, "changing items does not create ingredient actors")
	_expect(display.item == nested, "gameplay keeps the original Item reference")
	_expect(display.render_mode == ItemRenderer.RenderMode.ITEM, "interactive items use the right-side sprite layout")
	_expect(_commands(display, "rect").is_empty(), "interactive items do not draw diagram frames")
	display.slot = ItemDisplay.SLOT_UP
	display._animate_hover(true)
	await get_tree().create_timer(0.22).timeout
	_expect(display.scale.x > 4.0, "hover animation still works on the custom-drawn item")
	display.cancel_hover_for_operation()
	_expect(display.scale == Vector2(4, 4), "operation lock cancels hover without changing artwork")

	var tooltip := load("res://partial/item_tooltip.tscn").instantiate() as TooltipWidget
	root.add_child(tooltip)
	tooltip.show()
	tooltip.build_tooltip(nested)
	await get_tree().process_frame
	await get_tree().process_frame
	var compound_height := tooltip.size.y
	_expect(is_equal_approx(tooltip.size.x, 274.0), "inspection preserves the tooltip wrapping width")
	_expect(compound_height < root.size.y, "the example inspection fits vertically in the viewport")
	_expect(tooltip.get_node("Preview").visible, "compound tooltip has a larger visual inspection view")
	_expect(tooltip.get_node("Preview").render_mode == ItemRenderer.RenderMode.STRUCTURE, "only tooltip preview uses the diagram layout")
	_expect(tooltip.get_theme_stylebox("normal").get_content_margin(SIDE_TOP) >= 192.0, "text reserves space for artwork")
	_expect(tooltip.text.contains(nested.type_str().capitalize()), "tooltip retains the complete expression")
	tooltip.build_tooltip(Item.u("gold"))
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(not tooltip.get_node("Preview").visible, "unit tooltips remain compact")
	_expect(is_equal_approx(tooltip.size.x, 274.0), "compact tooltip retains its wrapping width")
	_expect(compound_height > tooltip.size.y + 150.0, "preview contributes to tooltip height instead of overlapping text")
	tooltip.build_tooltip(Item.n(nested))
	_expect(tooltip.get_node("Preview").visible, "wrapped compounds also have an inspection view")

	# Ingredient previews and hover motion must fit between hand items.
	var hand := Control.new()
	hand.set_script(load("res://script/ui/hand_container.gd"))
	root.add_child(hand)
	var hand_items: Array[ItemDisplay] = []
	for i in range(hand.COLUMNS + 1):
		var hand_item := load("res://partial/item_display.tscn").instantiate() as ItemDisplay
		hand_item.set_item(nested)
		hand.add_child(hand_item)
		hand_items.append(hand_item)
	hand._animate_layout()
	await get_tree().create_timer(0.7).timeout
	_expect(is_equal_approx(hand_items[1].position.x - hand_items[0].position.x, hand.CELL_SPACING), "hand columns use the spacing constant")
	_expect(is_equal_approx(hand_items[hand.COLUMNS].position.y - hand_items[0].position.y, hand.CELL_SPACING), "hand rows use the spacing constant and wrap at the column limit")
	var hover_width := 24.0 * 3.0 * 1.09 * (cos(deg_to_rad(2.2)) + sin(deg_to_rad(2.2)))
	_expect(hand.CELL_SPACING > hover_width, "spacing accommodates enlarged and rotated hover previews")
	_expect(hand_items[0].clickable, "layout animation restores clicking")
	hand.free()
	display.free()
	renderer.free()
	tooltip.free()

	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--gallery=") and _failures == 0:
			await _save_gallery(arg.trim_prefix("--gallery="))
	print("Item rendering: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(0 if _failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


func _test_item_presentation(renderer: ItemRenderer) -> void:
	for type in [Item.ItemType.TRANSFORM, Item.ItemType.AND, Item.ItemType.OR]:
		renderer.set_item(Item.new(type, "", Item.u("iron"), Item.u("gold")))
		var textures := _textures(renderer)
		_expect(textures.size() == 3, "item type %d retains its own sprite and both ingredients" % type)
		_expect(textures[0].rect == Rect2(0, 0, 24, 24), "original object remains the full-size base silhouette")
		_expect(textures[1].rect == Rect2(12, 0, 12, 12), "first ingredient sits at the upper-right")
		_expect(textures[2].rect == Rect2(12, 12, 12, 12), "second ingredient sits at the lower-right")
		_expect(_commands(renderer, "rect").is_empty(), "physical items have no frames or background panels")
		_expect(_commands(renderer, "line").is_empty(), "physical items have no relation connectors")
	renderer.set_item(_nested_item())
	_expect(_textures(renderer).size() > 3, "right-side ingredients recurse without creating nodes")
	_expect(renderer.get_child_count() == 0, "right-side recursion creates no child actors")
	renderer.size = Vector2(4, 4)
	_expect(_textures(renderer).size() == 1, "tiny physical compounds simplify to their own sprite")
	_expect(_commands(renderer, "circle").is_empty(), "tiny physical compounds do not display UI ellipsis badges")
	renderer.size = Vector2(24, 24)
	renderer.render_mode = ItemRenderer.RenderMode.STRUCTURE
	_expect(not _commands(renderer, "rect").is_empty(), "changing presentation rebuilds drawing without changing the item")
	renderer.render_mode = ItemRenderer.RenderMode.ITEM
	_expect(_commands(renderer, "rect").is_empty(), "returning to physical presentation removes all diagram frames")


func _commands(renderer: ItemRenderer, kind: String) -> Array[Dictionary]:
	var commands: Array[Dictionary] = []
	for command in renderer._draw_commands:
		if command.kind == kind:
			commands.append(command)
	return commands


func _textures(renderer: ItemRenderer) -> Array[Dictionary]:
	return _commands(renderer, "texture")


func _nested_item() -> Item:
	return Item.t(Item.a2("iron", "gold"), Item.o(Item.u("stone"), Item.t2("gold", "diamond")))


func _save_gallery(path: String) -> void:
	var canvas := Control.new()
	root.add_child(canvas)
	var background := ColorRect.new()
	background.color = Color(0.17, 0.12, 0.2)
	background.size = Vector2(root.size)
	canvas.add_child(background)
	var samples := [Item.u("gold"), Item.t2("stone", "gold"), Item.a2("iron", "gold"),
		Item.o2("stone", "diamond"), _nested_item(), Item.a(Item.n2("gold"), Item.u("iron").set_mold())]
	var names := ["UNIT", "TRANSFORM: input > output", "AND: both", "OR: either", "Nested compound", "Corrupted + mold"]
	for i in samples.size():
		var x := 24.0 + i * 186.0
		var label := Label.new()
		label.position = Vector2(x, 25)
		label.text = names[i]
		label.add_theme_font_size_override("font_size", 12)
		canvas.add_child(label)
		for row in range(2):
			var artwork := ItemRenderer.new()
			artwork.position = Vector2(x, 65.0 if row == 0 else 205.0)
			artwork.size = Vector2(24, 24) if row == 0 else Vector2(168, 168)
			artwork.scale = Vector2(3, 3) if row == 0 else Vector2.ONE
			artwork.render_mode = ItemRenderer.RenderMode.ITEM if row == 0 else ItemRenderer.RenderMode.STRUCTURE
			canvas.add_child(artwork)
			artwork.set_item(samples[i])
	var legend := Label.new()
	legend.position = Vector2(24, 410)
	legend.text = "Top: physical items, with ingredients at the upper-right and lower-right. No frames or connectors.\nBottom: tooltip inspection keeps the structural diagram and expands more levels."
	legend.add_theme_font_size_override("font_size", 16)
	canvas.add_child(legend)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	_expect(screenshot != null and not screenshot.is_empty(), "GPU rendering produces an image")
	if screenshot != null and not screenshot.is_empty():
		_expect(_color_count(screenshot, Rect2i(250, 69, 24, 24)) > 3, "GPU draws the upper-right transform input sprite")
		_expect(_color_count(screenshot, Rect2i(250, 105, 24, 24)) > 3, "GPU draws the lower-right transform output sprite")
		_expect(screenshot.save_png(path) == OK, "gallery screenshot is saved")
		print("Gallery: ", path)
	canvas.free()


func _color_count(image: Image, rect: Rect2i) -> int:
	var colors := {}
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			colors[image.get_pixel(x, y).to_html()] = true
	return colors.size()
