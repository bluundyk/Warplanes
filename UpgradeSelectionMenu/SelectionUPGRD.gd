extends Node2D

@onready var total_coins_label = $TotalCoins

const TOTAL_COINS_SAVE_PATH = "user://total_coins.save"

func _ready():
	update_total_coins()

func update_total_coins():
	var total_coins = 0

	if FileAccess.file_exists(TOTAL_COINS_SAVE_PATH):
		var file = FileAccess.open(TOTAL_COINS_SAVE_PATH, FileAccess.READ)
		if file:
			total_coins = int(file.get_as_text())

	if total_coins_label:
		total_coins_label.text = str(total_coins)

func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://LevelSelestionMenu/LevelSelection.tscn")

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://MenuFolder/menu.tscn")
