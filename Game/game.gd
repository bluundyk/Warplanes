extends Node2D

@onready var hp_bar = $hpBar
@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var coin_count_label = $UI/Control/CoinsContainer/CoinCount

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
	
	load_high_score()
	load_total_coins()
	update_score_display()
	update_coins_display()
	
	var plane = $Plane
	if plane:
		plane.coins_changed.connect(_on_plane_coins_changed)
	
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
