extends Control


func _on_start_clicked() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")


func _on_credits_clicked() -> void:
	pass # Replace with function body.


func _on_exit_clicked() -> void:
	get_tree().quit()
