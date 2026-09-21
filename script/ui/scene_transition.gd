extends CanvasLayer

## A scene change presented as an alchemical seal closing and opening.
## Kept in an autoload so it survives the scene it is covering.

signal scene_revealing

var _veil: ColorRect
var _material: ShaderMaterial
var _busy := false
var _revealing := false


func _ready() -> void:
	layer = 1000
	process_mode = Node.PROCESS_MODE_ALWAYS

	_veil = ColorRect.new()
	_veil.name = "AlchemyVeil"
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.visible = false
	add_child(_veil)

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 viewport_size = vec2(1152.0, 648.0);

void fragment() {
	vec2 p = UV - vec2(0.5);
	p.x *= viewport_size.x / max(viewport_size.y, 1.0);
	float radius = mix(-0.12, 1.28, progress);
	float distance_to_center = length(p);
	float cover = 1.0 - smoothstep(radius - 0.025, radius + 0.025, distance_to_center);

	// The moving edge is a deliberately imperfect transmutation circle.
	float edge = 1.0 - smoothstep(0.006, 0.022, abs(distance_to_center - radius));
	float outer_edge = 1.0 - smoothstep(0.004, 0.012, abs(distance_to_center - radius - 0.055));
	float angle = atan(p.y, p.x);
	float broken_arc = step(0.12, sin(angle * 9.0 + progress * 12.0));
	float arc_band = (1.0 - smoothstep(0.004, 0.013, abs(distance_to_center - radius + 0.075))) * broken_arc;
	float spokes = (1.0 - smoothstep(0.0, 0.018, abs(sin(angle * 6.0 + progress * 2.0))))
		* (1.0 - smoothstep(0.045, 0.07, abs(distance_to_center - radius + 0.105)));

	float gold_amount = clamp(edge + outer_edge * 0.72 + arc_band * 0.8 + spokes * 0.52, 0.0, 1.0);
	vec3 ink = vec3(0.018, 0.008, 0.032);
	vec3 violet = vec3(0.105, 0.035, 0.15);
	vec3 gold = vec3(0.95, 0.61, 0.13);
	vec3 base = mix(ink, violet, clamp(distance_to_center * 0.35, 0.0, 1.0));
	vec3 color = mix(base, gold, gold_amount);
	float alpha = max(cover, max(edge, max(outer_edge, max(arc_band, spokes))) * 0.96);
	COLOR = vec4(color, alpha);
}
"""

	_material = ShaderMaterial.new()
	_material.shader = shader
	_veil.material = _material
	_update_viewport_size()
	get_viewport().size_changed.connect(_update_viewport_size)


func is_busy() -> bool:
	return _busy


func is_revealing() -> bool:
	return _revealing


## Waits for the point at which the destination scene may begin its entrance.
##
## A state check is used instead of awaiting `scene_revealing` directly: the
## destination scene can enter the tree one frame after that one-shot signal
## was emitted, depending on Godot's deferred scene-change ordering.
func wait_for_reveal() -> void:
	if not _busy:
		await get_tree().process_frame
		return

	while _busy and not _revealing:
		await get_tree().process_frame


func change_scene(path: String) -> void:
	if _busy:
		return

	_busy = true
	_revealing = false
	_veil.visible = true
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_material.set_shader_parameter("progress", 0.0)

	var closing := create_tween()
	closing.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	closing.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	closing.tween_method(_set_progress, 0.0, 1.0, 0.72)
	await closing.finished

	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Unable to change scene to %s (error %s)" % [path, error])
		_open_veil_immediately()
		return

	# Give the new scene one frame to enter the tree before revealing it.
	await get_tree().process_frame
	_revealing = true
	scene_revealing.emit()

	var opening := create_tween()
	opening.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	opening.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	opening.tween_method(_set_progress, 1.0, 0.0, 0.78)
	await opening.finished
	_open_veil_immediately()


func _set_progress(value: float) -> void:
	_material.set_shader_parameter("progress", value)


func _update_viewport_size() -> void:
	if is_instance_valid(_material):
		_material.set_shader_parameter("viewport_size", Vector2(get_viewport().get_visible_rect().size))


func _open_veil_immediately() -> void:
	_material.set_shader_parameter("progress", 0.0)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.visible = false
	_revealing = false
	_busy = false
