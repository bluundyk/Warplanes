extends Control

@onready var coins_run_label = $Panel/CoinsContainer/CoinsRunLabel
@onready var total_coins_label = $Panel/TotalCoinsContainer/TotalCoinsLabel

var current_coins: int = 0
var total_coins: int = 0

func _ready():
	visible = true
	z_index = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	modulate = Color.TRANSPARENT
	var appear_tween = create_tween()
	appear_tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func show_game_over(coins: int, total: int):
	current_coins = coins
	total_coins = total
	
	if coins_run_label:
		coins_run_label.text = str(current_coins)
	if total_coins_label:
		total_coins_label.text = str(total_coins)

func _on_restart_button_pressed() -> void:
	await fade_out()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	await fade_out()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuFolder/menu.tscn")
	
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	queue_free()
