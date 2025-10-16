extends Control

var first=true

func _ready() -> void:
	EventBus.select.emit(Globals.last_visited_chapter)
	EventBus.select.connect(func(t):Globals.last_visited_chapter=t)


func _on_label_clicked() -> void:
	get_tree().change_scene_to_file("res://title.tscn")
