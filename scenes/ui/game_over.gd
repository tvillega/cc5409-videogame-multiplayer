extends CanvasLayer

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
