extends Control

var _intro_finished := false
var _leaving := false
var _logo_idle_tween: Tween


func _ready() -> void:
	_set_menu_input(false)
	for particle in _particles():
		particle.emitting = false

	await SceneTransition.wait_for_reveal()
	_play_opening_ritual()


func _play_opening_ritual() -> void:
	var background := $bg as TextureRect
	var wash := $TextureRect as TextureRect
	var logo := $logo as TextureRect
	var menu := _menu_items()

	background.pivot_offset = background.size * 0.5
	background.modulate.a = 0.0
	background.scale = Vector2(1.075, 1.075)
	background.rotation = deg_to_rad(-1.2)

	var wash_position := wash.position
	wash.modulate.a = 0.0
	wash.position = wash_position + Vector2(-260.0, 80.0)
	wash.scale.x = 0.25

	logo.pivot_offset = logo.size * 0.5
	logo.modulate = Color(1.28, 0.78, 0.32, 0.0)
	logo.scale = Vector2(1.32, 1.32)
	logo.rotation = deg_to_rad(-7.0)

	var background_tween := create_tween()
	background_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	background_tween.tween_property(background, "modulate:a", 1.0, 0.72)
	background_tween.parallel().tween_property(background, "scale", Vector2.ONE, 1.45)
	background_tween.parallel().tween_property(background, "rotation", 0.0, 1.35)

	var wash_tween := create_tween()
	wash_tween.tween_interval(0.12)
	wash_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	wash_tween.tween_property(wash, "position", wash_position, 0.82)
	wash_tween.parallel().tween_property(wash, "scale:x", 1.0, 0.82)
	wash_tween.parallel().tween_property(wash, "modulate:a", 1.0, 0.44)

	var logo_tween := create_tween()
	logo_tween.tween_interval(0.22)
	logo_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	logo_tween.tween_property(logo, "modulate:a", 1.0, 0.46)
	logo_tween.parallel().tween_property(logo, "scale", Vector2(0.93, 0.93), 0.78)
	logo_tween.parallel().tween_property(logo, "rotation", deg_to_rad(1.2), 0.78)
	logo_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	logo_tween.tween_property(logo, "scale", Vector2.ONE, 0.3)
	logo_tween.parallel().tween_property(logo, "rotation", 0.0, 0.3)
	logo_tween.parallel().tween_property(logo, "modulate", Color.WHITE, 0.3)

	for index in menu.size():
		var item := menu[index]
		item.pivot_offset = item.size * 0.5
		var destination := item.position
		var crooked_direction := -1.0 if index % 2 == 0 else 1.0
		item.position = destination + Vector2(-72.0 + index * 19.0, crooked_direction * 13.0)
		item.rotation = deg_to_rad(crooked_direction * (5.0 + index))
		item.scale = Vector2(0.78, 0.78)
		item.modulate.a = 0.0

		var item_tween := create_tween()
		item_tween.tween_interval(0.78 + index * 0.12)
		item_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		item_tween.tween_property(item, "position", destination, 0.5)
		item_tween.parallel().tween_property(item, "rotation", 0.0, 0.5)
		item_tween.parallel().tween_property(item, "scale", Vector2.ONE, 0.5)
		item_tween.parallel().tween_property(item, "modulate:a", 1.0, 0.3)

	await get_tree().create_timer(0.76).timeout
	for particle in _particles():
		particle.speed_scale = 1.65
		particle.emitting = true
		particle.restart()
		var particle_tween := create_tween()
		particle_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		particle_tween.tween_property(particle, "speed_scale", 1.0, 0.85)

	await get_tree().create_timer(0.62).timeout
	_intro_finished = true
	_set_menu_input(true)
	_start_logo_breathing()


func _start_logo_breathing() -> void:
	var logo := $logo as TextureRect
	var rest_position := logo.position
	_logo_idle_tween = create_tween().set_loops()
	_logo_idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_logo_idle_tween.tween_property(logo, "position", rest_position + Vector2(0.0, -5.0), 2.2)
	_logo_idle_tween.parallel().tween_property(logo, "rotation", deg_to_rad(0.45), 2.2)
	_logo_idle_tween.tween_property(logo, "position", rest_position + Vector2(0.0, 3.0), 2.2)
	_logo_idle_tween.parallel().tween_property(logo, "rotation", deg_to_rad(-0.35), 2.2)


func _menu_items() -> Array[Label]:
	return [$Start, $Credits, $Exit]


func _particles() -> Array[CPUParticles2D]:
	return [$CPUParticles2D, $CPUParticles2D2, $CPUParticles2D3]


func _set_menu_input(enabled: bool) -> void:
	for item in _menu_items():
		item.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _on_start_clicked() -> void:
	if not _intro_finished or _leaving:
		return
	_leaving = true
	_set_menu_input(false)
	if is_instance_valid(_logo_idle_tween):
		_logo_idle_tween.kill()
	SceneTransition.change_scene("res://level_select.tscn")


func _on_credits_clicked() -> void:
	if not _intro_finished or _leaving:
		return
	_leaving = true
	_set_menu_input(false)
	if is_instance_valid(_logo_idle_tween):
		_logo_idle_tween.kill()
	SceneTransition.change_scene("res://credits.tscn")


func _on_exit_clicked() -> void:
	if not _intro_finished or _leaving:
		return
	_leaving = true
	_set_menu_input(false)
	var exit_tween := create_tween()
	exit_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	exit_tween.tween_property(self, "modulate", Color(0.16, 0.04, 0.2, 0.0), 0.48)
	await exit_tween.finished
	get_tree().quit()
