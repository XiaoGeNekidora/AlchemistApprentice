extends Control

var _leaving := false


func _ready() -> void:
	var rail := $TextureRect as TextureRect
	var rail_position := rail.position
	rail.pivot_offset = Vector2(0.0, rail.size.y * 0.5)
	rail.position = rail_position + Vector2(-150.0, 0.0)
	rail.rotation = deg_to_rad(-4.0)
	rail.modulate.a = 0.0
	_set_navigation_enabled(false)

	EventBus.select.connect(_remember_chapter)
	await SceneTransition.wait_for_reveal()

	var rail_tween := create_tween()
	rail_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rail_tween.tween_property(rail, "position", rail_position + Vector2(8.0, 0.0), 0.58)
	rail_tween.parallel().tween_property(rail, "rotation", deg_to_rad(0.7), 0.58)
	rail_tween.parallel().tween_property(rail, "modulate:a", 1.0, 0.3)
	rail_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rail_tween.tween_property(rail, "position", rail_position, 0.2)
	rail_tween.parallel().tween_property(rail, "rotation", 0.0, 0.2)

	# Emitting here makes panel scripts the single owners of chapter animation.
	EventBus.select.emit(Globals.last_visited_chapter)
	await get_tree().create_timer(0.56).timeout
	_set_navigation_enabled(true)


func _remember_chapter(chapter: String) -> void:
	Globals.last_visited_chapter = chapter


func _set_navigation_enabled(enabled: bool) -> void:
	for child in $TextureRect/VBoxContainer.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	$TextureRect/Label.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _on_label_clicked() -> void:
	if _leaving:
		return
	_leaving = true
	_set_navigation_enabled(false)
	SceneTransition.change_scene("res://title.tscn")
