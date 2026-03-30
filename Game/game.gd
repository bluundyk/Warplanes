extends Node2D

@onready var hp_bar = $hpBar
@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel

var score: float = 0
var high_score: int = 0
var is_game_over: bool = false

func _ready():
	if hp_bar:
		hp_bar.max_value = 100
		hp_bar.min_value = 0
		hp_bar.value = 100
	
	load_high_score()
	update_score_display()
	
	print("Game started! Current high score: ", high_score)

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

func save_high_score():
	var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	if file:
		file.store_string(str(high_score))
		file.close()
		print("High score saved: ", high_score)
	else:
		print("ERROR: Could not save high score!")

func load_high_score():
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		if file:
			var content = file.get_as_text()
			high_score = int(content)
			file.close()
			print("High score loaded: ", high_score)
		else:
			print("ERROR: Could not load high score file")
	else:
		high_score = 0
		print("No saved high score, starting from 0")

func game_over():
	is_game_over = true
	print("Game Over! Final score: ", int(score))
	
	update_score_display()
