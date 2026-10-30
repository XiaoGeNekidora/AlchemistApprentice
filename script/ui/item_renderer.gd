extends Control
class_name ItemRenderer

## One canvas item, regardless of how many ingredients the Item contains.
## Layout is rebuilt only when the item or the available drawing area changes.
const UNKNOWN_TEXTURE: Texture2D = preload("res://texture/unknown.png")
const POTION_IDS := ["red", "blue", "white", "pink", "red2", "blue2", "greenb", "redb"]
const MIN_COMPOSITE_SIZE := 6.0
const MAX_RENDER_DEPTH := 12
const FRAME_COLOR := Color(0.12, 0.085, 0.16, 0.96)

enum RenderMode { ITEM, STRUCTURE }

static var _texture_cache: Dictionary[String, Texture2D] = {}

var item: Item
var _draw_commands: Array[Dictionary] = []

## Actual items remain sprites; the tooltip explicitly opts into a diagram.
@export var render_mode: RenderMode = RenderMode.ITEM:
	set(value):
		render_mode = value
		_rebuild_drawing()


func set_item(value: Item) -> void:
	item = value
	_rebuild_drawing()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_rebuild_drawing()


func _rebuild_drawing() -> void:
	_draw_commands.clear()
	var side := minf(size.x, size.y)
	if side > 0.0:
		var bounds := Rect2((size - Vector2.ONE * side) * 0.5, Vector2.ONE * side)
		_append_item(item, bounds, Color.WHITE, 0)
	queue_redraw()


func _append_item(value: Item, rect: Rect2, tint: Color, depth: int) -> void:
	if value == null:
		_append_texture(UNKNOWN_TEXTURE, rect, tint)
		return
	if value.is_mold:
		tint.a *= 0.5
	if depth >= MAX_RENDER_DEPTH:
		_append_texture(UNKNOWN_TEXTURE, rect, tint)
		if render_mode == RenderMode.STRUCTURE:
			_append_more(rect, tint)
		return
	if value.type == Item.ItemType.NOT:
		# Item effects are draw colors, not node modulation: entrance/hover tweens
		# must not erase corruption or the opacity of a nested mold.
		_append_item(value.left, rect, tint * Color.BLACK, depth + 1)
		return

	var texture := _texture_for(value)
	if value.left == null or value.right == null:
		_append_texture(texture, rect, tint)
		return
	if rect.size.x < MIN_COMPOSITE_SIZE:
		if render_mode == RenderMode.STRUCTURE:
			_append_texture(texture, _part(rect, 0.05, 0.0, 0.9, 0.85), tint)
			_append_more(rect, tint)
		else:
			_append_texture(texture, rect, tint)
		return

	if render_mode == RenderMode.ITEM:
		# Keep the original object as the base silhouette. Its two ingredients
		# sit at its upper-right and lower-right; nested compounds do the same.
		# No frames, backgrounds, connectors or ellipsis badges on actual items.
		_append_texture(texture, rect, tint)
		_append_item(value.left, _part(rect, 0.5, 0.0, 0.5, 0.5), tint, depth + 1)
		_append_item(value.right, _part(rect, 0.5, 0.5, 0.5, 0.5), tint, depth + 1)
		return

	# A small type header and two equal ingredient wells. Every nested compound
	# uses exactly the same layout, so left/right never swap at deeper levels.
	var accent := _accent_for(value.type)
	accent.a *= tint.a
	var background := FRAME_COLOR
	background.a *= tint.a
	_draw_commands.append({"kind": "rect", "rect": rect, "color": background, "filled": true})
	_draw_commands.append({"kind": "rect", "rect": rect, "color": accent,
		"filled": false, "width": rect.size.x * 0.014})
	_append_texture(texture, _part(rect, 0.28, 0.015, 0.44, 0.44), tint)
	_append_relation(value.type, rect, accent)
	_append_item(value.left, _part(rect, 0.025, 0.55, 0.4, 0.4), tint, depth + 1)
	_append_item(value.right, _part(rect, 0.575, 0.55, 0.4, 0.4), tint, depth + 1)


func _append_relation(type: Item.ItemType, rect: Rect2, color: Color) -> void:
	# The branches associate both ingredients with their parent type icon.
	_append_line(rect, Vector2(0.5, 0.46), Vector2(0.5, 0.5), color)
	_append_line(rect, Vector2(0.225, 0.5), Vector2(0.775, 0.5), color)
	_append_line(rect, Vector2(0.225, 0.5), Vector2(0.225, 0.54), color)
	_append_line(rect, Vector2(0.775, 0.5), Vector2(0.775, 0.54), color)
	match type:
		Item.ItemType.TRANSFORM:
			_append_line(rect, Vector2(0.445, 0.75), Vector2(0.555, 0.75), color)
			_append_line(rect, Vector2(0.515, 0.71), Vector2(0.555, 0.75), color)
			_append_line(rect, Vector2(0.515, 0.79), Vector2(0.555, 0.75), color)
		Item.ItemType.AND:
			_append_line(rect, Vector2(0.45, 0.75), Vector2(0.55, 0.75), color)
			_append_line(rect, Vector2(0.5, 0.7), Vector2(0.5, 0.8), color)
		Item.ItemType.OR:
			_append_line(rect, Vector2(0.45, 0.715), Vector2(0.5, 0.79), color)
			_append_line(rect, Vector2(0.55, 0.715), Vector2(0.5, 0.79), color)


func _append_more(rect: Rect2, tint: Color) -> void:
	var color := Color(0.94, 0.85, 0.68, tint.a)
	for x in [0.35, 0.5, 0.65]:
		_draw_commands.append({"kind": "circle", "position": rect.position + rect.size * Vector2(x, 0.93),
			"radius": rect.size.x * 0.04, "color": color})


func _append_texture(texture: Texture2D, rect: Rect2, tint: Color) -> void:
	_draw_commands.append({"kind": "texture", "texture": texture, "rect": rect, "color": tint})


func _append_line(rect: Rect2, start: Vector2, end: Vector2, color: Color) -> void:
	_draw_commands.append({"kind": "line", "start": rect.position + start * rect.size,
		"end": rect.position + end * rect.size, "color": color, "width": rect.size.x * 0.018})


static func _part(rect: Rect2, x: float, y: float, width: float, height: float) -> Rect2:
	return Rect2(rect.position + rect.size * Vector2(x, y), rect.size * Vector2(width, height))


static func _accent_for(type: Item.ItemType) -> Color:
	match type:
		Item.ItemType.TRANSFORM:
			return Color(0.96, 0.71, 0.35)
		Item.ItemType.AND:
			return Color(0.48, 0.83, 0.68)
		Item.ItemType.OR:
			return Color(0.78, 0.6, 0.98)
	return Color(0.8, 0.76, 0.68)


static func _texture_for(value: Item) -> Texture2D:
	var path := ""
	match value.type:
		Item.ItemType.UNIT:
			path = "res://texture/item/%s.png" % value.name
		Item.ItemType.TRANSFORM:
			path = "res://texture/potion_%s.png" % POTION_IDS[value.hash() % POTION_IDS.size()]
		Item.ItemType.AND:
			path = "res://texture/mixture.png"
		Item.ItemType.OR:
			path = "res://texture/entanglement.png"
	if not _texture_cache.has(path):
		var texture: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
		_texture_cache[path] = texture if texture != null else UNKNOWN_TEXTURE
	return _texture_cache[path]


func _draw() -> void:
	for command in _draw_commands:
		match command.kind:
			"texture":
				draw_texture_rect(command.texture, command.rect, false, command.color)
			"rect":
				draw_rect(command.rect, command.color, command.filled, command.get("width", -1.0))
			"line":
				draw_line(command.start, command.end, command.color, command.width, true)
			"circle":
				draw_circle(command.position, command.radius, command.color)
