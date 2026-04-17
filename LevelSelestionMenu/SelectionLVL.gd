extends Node2D

func _on_level_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/game.tscn")
	
func _on_level2_pressed() -> void:
	get_tree().change_scene_to_file("res://GameTranquility/game.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://UpgradeSelectionMenu/UpgradeSelection.tscn")
