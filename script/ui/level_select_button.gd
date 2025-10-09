extends Button

@export var level: String

func _on_pressed() -> void:
	Globals.current_level=Globals.all_levels[level].new()
	get_tree().change_scene_to_file("res://game.tscn")
