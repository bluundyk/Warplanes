extends Node2D

@onready var hp_bar = $hpBar
@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var coin_count_label = $UI/Control/CoinsContainer/CoinCount
@onready var shield_bar = $UI/Control/ShieldBar
@onready var shield_icon = $UI/Control/ShieldContainer/ShieldIcon
@onready var shield_timer_label = $UI/Control/ShieldContainer/ShieldTimerLabel
@onready var slow_time_icon = $UI/Control/SlowTimeContainer/SlowTimeIcon
@onready var slow_time_timer_label = $UI/Control/SlowTimeContainer/SlowTimeTimerLabel

var score: float = 0
var high_score: int = 0
var current_coins: int = 0
var total_coins: int = 0
var is_game_over: bool = false

const TOTAL_COINS_SAVE_PATH = "user://total_coins.save"
const HIGH_SCORE_SAVE_PATH = "user://high_score.save"

func _ready():
	if hp_bar:
		hp_bar.max_value = 100
		hp_bar.min_value = 0
		hp_bar.value = 100

	if shield_bar:
		shield_bar.max_value = 100
		shield_bar.min_value = 0
		shield_bar.value = 100
		shield_bar.hide()

	if shield_icon:
		shield_icon.hide()

	if shield_timer_label:
		shield_timer_label.hide()

	if slow_time_icon:
		slow_time_icon.hide()

	if slow_time_timer_label:
		slow_time_timer_label.hide()

	load_high_score()
	load_total_coins()
	update_score_display()
	update_coins_display()

	var plane = $Plane
	if plane:
		plane.coins_changed.connect(_on_plane_coins_changed)
		plane.health_changed.connect(_on_plane_health_changed)
		plane.shield_activated.connect(_on_plane_shield_activated)
		plane.shield_depleted.connect(_on_plane_shield_depleted)
		plane.shield_health_changed.connect(_on_plane_shield_health_changed)
		plane.shield_time_changed.connect(_on_plane_shield_time_changed)
		plane.slow_time_activated.connect(_on_plane_slow_time_activated)
		plane.slow_time_ended.connect(_on_plane_slow_time_ended)
		plane.slow_time_changed.connect(_on_plane_slow_time_changed)

	print("Game started! High score: ", high_score, " | Total coins: ", total_coins)

func _process(delta):
	if is_game_over:
		return

	var plane = $Plane
	if plane and plane.has_method("get_health"):
		var health = plane.get_health()
		if hp_bar and hp_bar.value != health:
			hp_bar.value = health

	if plane and plane.has_method("is_alive") and plane.is_alive():
		score += delta * 10
		update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(int(score))

	if int(score) > high_score:
		high_score = int(score)
		save_high_score()
		print("NEW HIGH SCORE! ", high_score)

	if high_score_label:
		high_score_label.text = "Best: " + str(high_score)

func update_coins_display():
	if coin_count_label:
		coin_count_label.text = str(current_coins)

func _on_plane_coins_changed(coins: int):
	current_coins = coins
	update_coins_display()

func _on_plane_health_changed(current_health: int, max_health: int):
	if hp_bar:
		hp_bar.value = current_health

func _on_plane_shield_activated():
	if shield_bar:
		shield_bar.show()
		shield_bar.value = 100
	if shield_icon:
		shield_icon.show()
	if shield_timer_label:
		shield_timer_label.show()
		shield_timer_label.text = "0.0"
		shield_timer_label.modulate = Color.GREEN

func _on_plane_shield_depleted():
	if shield_bar:
		shield_bar.hide()
	if shield_icon:
		shield_icon.hide()
	if shield_timer_label:
		shield_timer_label.hide()

func _on_plane_shield_health_changed(current_health: int, max_health: int):
	if shield_bar:
		var percent = float(current_health) / float(max_health) * 100.0
		shield_bar.value = percent

func _on_plane_shield_time_changed(time_left: float, initial_duration: float):
	if shield_timer_label:
		shield_timer_label.text = str(round(time_left * 10.0) / 10.0) + "s"
		
		if time_left <= 2.0:
			shield_timer_label.modulate = Color.RED
		elif time_left <= 5.0:
			shield_timer_label.modulate = Color.YELLOW
		else:
			shield_timer_label.modulate = Color.GREEN

func _on_plane_slow_time_activated():
	if slow_time_icon:
		slow_time_icon.show()
	if slow_time_timer_label:
		slow_time_timer_label.show()
		slow_time_timer_label.text = "0.0"
		slow_time_timer_label.modulate = Color.CYAN

func _on_plane_slow_time_ended():
	if slow_time_icon:
		slow_time_icon.hide()
	if slow_time_timer_label:
		slow_time_timer_label.hide()

func _on_plane_slow_time_changed(time_left: float):
	if slow_time_timer_label:
		slow_time_timer_label.text = str(round(time_left * 10.0) / 10.0) + "s"
		
		if time_left <= 2.0:
			slow_time_timer_label.modulate = Color.RED
		elif time_left <= 5.0:
			slow_time_timer_label.modulate = Color.YELLOW
		else:
			slow_time_timer_label.modulate = Color.CYAN

func add_coin(amount: int = 1):
	current_coins += amount
	total_coins += amount
	update_coins_display()
	save_total_coins()
	print("Coin collected! This run: ", current_coins, " | Total: ", total_coins)

func save_high_score():
	var file = FileAccess.open(HIGH_SCORE_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(str(high_score))
		file.close()

func load_high_score():
	if FileAccess.file_exists(HIGH_SCORE_SAVE_PATH):
		var file = FileAccess.open(HIGH_SCORE_SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			high_score = int(content)
			file.close()
	else:
		high_score = 0

func save_total_coins():
	var file = FileAccess.open(TOTAL_COINS_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(str(total_coins))
		file.close()

func load_total_coins():
	if FileAccess.file_exists(TOTAL_COINS_SAVE_PATH):
		var file = FileAccess.open(TOTAL_COINS_SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			total_coins = int(content)
			file.close()
	else:
		total_coins = 0

func game_over():
	is_game_over = true
	print("Game Over! Score: ", int(score), " | Coins this run: ", current_coins, " | Total coins: ", total_coins)

	var game_over_layer = $GameOver
	if game_over_layer and game_over_layer.has_method("show_game_over"):
		game_over_layer.show_game_over(int(score), high_score, current_coins, total_coins)
	else:
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
