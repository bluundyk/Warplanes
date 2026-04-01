extends Control

func _ready():
	visible = true
	z_index = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	modulate = Color.TRANSPARENT
	var appear_tween = create_tween()
	appear_tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
func _on_restart_button_pressed() -> void:
	await fade_out()
	queue_free()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	await fade_out()
	queue_free()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuFolder/menu.tscn")
	
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
