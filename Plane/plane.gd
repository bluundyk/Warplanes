extends CharacterBody2D

signal health_changed(current_health, max_health)
signal coins_changed(current_coins)

@onready var animated_sprite = $AnimatedSprite2D

const FLIGHT_SPEED = 300.0
const VERTICAL_SPEED = 400.0
const SHOOT_DELAY = 0.5

var current_damage: int = 10
var player_health: int = 100
var max_health: int = 100
var can_shoot = true
var is_dead: bool = false

var current_coins: int = 0
var total_coins: int = 0

var bullet_scene = preload("res://Bullet/bullet.tscn")
var death_screen_scene = preload("res://deathScreen/death_screen.tscn")

const TOTAL_COINS_SAVE_PATH = "user://total_coins.save"

func _ready():
	animated_sprite.play("flying")
	add_to_group("player")
	load_total_coins()
	coins_changed.emit(current_coins)
	print("Player ready! Health: ", player_health, " | Total coins: ", total_coins)

func _physics_process(delta):
	if is_dead:
		return 
	
	var vertical_direction = Input.get_axis("move_up", "move_down")
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.y = vertical_direction * VERTICAL_SPEED
	velocity.x = horizontal_direction * FLIGHT_SPEED
	
	var screen_size = get_viewport().get_visible_rect().size
	position.y = clamp(position.y, 45, screen_size.y - 45)
	position.x = clamp(position.x, 55, screen_size.x - 1050)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shoot()

func shoot():
	if can_shoot and not is_dead:
		can_shoot = false
		
		animated_sprite.play("attack")
		
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = global_position + Vector2(50, 0)
		
		bullet.direction = Vector2.RIGHT
		bullet.shooter_type = "player"
		bullet.damage = current_damage
		bullet.speed = 800
		
		await get_tree().create_timer(SHOOT_DELAY).timeout
		
		if is_instance_valid(self) and not is_dead:
			animated_sprite.play("flying")
			can_shoot = true

func take_damage(amount: int):
	if is_dead:
		return
	
	player_health -= amount
	player_health = max(0, player_health)
	
	print("Player took ", amount, " damage! Health: ", player_health, "/", max_health)
	
	health_changed.emit(player_health, max_health)
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if player_health <= 0:
		die()

func get_health() -> int:
	return player_health

func is_alive() -> bool:
	return not is_dead

func add_coin(amount: int = 1):
	current_coins += amount
	total_coins += amount
	save_total_coins()
	coins_changed.emit(current_coins)
	print("Coin collected! This run: ", current_coins, " | Total: ", total_coins)

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

func die():
	if is_dead:
		return
	
	is_dead = true
	
	animated_sprite.play("death")
	
	print("GAME OVER!")
	
	velocity = Vector2.ZERO
	can_shoot = false
	
	await animated_sprite.animation_finished
	
	var explosion_scene = preload("res://Effects/explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
	
	show_death_screen()

func show_death_screen():
	var death_screen = death_screen_scene.instantiate()
	get_tree().root.add_child(death_screen)
	
	if death_screen.has_method("show_game_over"):
		death_screen.show_game_over(current_coins, total_coins)
