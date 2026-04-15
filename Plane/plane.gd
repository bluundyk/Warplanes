extends CharacterBody2D

signal health_changed(current_health, max_health)
signal coins_changed(current_coins)
signal shield_activated
signal shield_depleted
signal shield_health_changed(current_health, max_health)
signal shield_time_changed(time_left, initial_duration)
signal slow_time_activated
signal slow_time_ended
signal slow_time_changed(time_left)

@onready var animated_sprite = $AnimatedSprite2D
@onready var shield_sprite = $ShieldSprite

const FLIGHT_SPEED = 300.0
const VERTICAL_SPEED = 400.0
const SHOOT_DELAY = 0.5

var current_damage: int = 10
var player_health: int = 100
var max_health: int = 100
var can_shoot = true
var is_dead: bool = false

# Переменные для щита
var shield_active: bool = false
var shield_health: int = 50
var max_shield_health: int = 50
var shield_time_left: float = 0.0
var initial_shield_duration: float = 0.0

# Переменные для замедления
var slow_time_active: bool = false
var slow_time_left: float = 0.0
var initial_slow_time: float = 0.0
var slow_time_multiplier: float = 0.5

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

	if shield_sprite:
		shield_sprite.hide()

	print("Player ready! Health: ", player_health, " | Total coins: ", total_coins)

func _physics_process(delta):
	if is_dead:
		return

	# Обновление таймера щита
	if shield_active:
		shield_time_left -= delta
		if shield_time_left <= 0:
			_deactivate_shield()
		else:
			shield_time_changed.emit(shield_time_left, initial_shield_duration)

	# Обновление таймера замедления для UI (только если активно)
	if slow_time_active:
		slow_time_changed.emit(slow_time_left)

	# Движение
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

func heal(amount: int):
	if is_dead:
		return

	player_health += amount
	player_health = min(player_health, max_health)
	health_changed.emit(player_health, max_health)

	for i in range(3):
		modulate = Color.GREEN
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout

	print("Player healed! Health: ", player_health, "/", max_health)

func activate_shield(duration: float):
	if shield_active or is_dead:
		return

	shield_active = true
	shield_health = max_shield_health
	shield_time_left = duration
	initial_shield_duration = duration

	if shield_sprite:
		shield_sprite.show()

	shield_activated.emit()
	shield_health_changed.emit(shield_health, max_shield_health)
	shield_time_changed.emit(shield_time_left, initial_shield_duration)
	print("Shield activated for ", duration, " seconds! Health: ", shield_health)

func _deactivate_shield():
	if not shield_active:
		return
	shield_active = false
	if shield_sprite:
		shield_sprite.hide()
	shield_depleted.emit()
	print("Shield depleted")

func activate_slow_time(duration: float):
	if slow_time_active or is_dead:
		return

	slow_time_active = true
	slow_time_left = duration
	initial_slow_time = duration
	slow_time_activated.emit()
	slow_time_changed.emit(slow_time_left)
	
	# Замедляем всю игру
	Engine.time_scale = slow_time_multiplier
	
	print("Slow time activated for ", duration, " seconds! Time scale: ", Engine.time_scale)

	# Создаём таймер, который игнорирует time_scale
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.process_mode = Timer.TIMER_PROCESS_IDLE
	add_child(timer)
	
	# Обновляем таймер UI каждые 0.1 секунды
	var update_timer = Timer.new()
	update_timer.wait_time = 0.1
	update_timer.process_mode = Timer.TIMER_PROCESS_IDLE
	add_child(update_timer)
	update_timer.timeout.connect(_update_slow_time_ui)
	update_timer.start()
	
	timer.start()
	await timer.timeout
	
	update_timer.stop()
	update_timer.queue_free()
	timer.queue_free()

	if not is_instance_valid(self) or is_dead:
		Engine.time_scale = 1.0
		return

	if slow_time_active:
		slow_time_active = false
		slow_time_ended.emit()
		Engine.time_scale = 1.0
		print("Slow time ended! Time scale: ", Engine.time_scale)

func _update_slow_time_ui():
	if slow_time_active and slow_time_left > 0:
		slow_time_left -= 0.1
		if slow_time_left <= 0:
			slow_time_left = 0
		slow_time_changed.emit(slow_time_left)

func take_damage(amount: int):
	if is_dead:
		return

	if shield_active:
		shield_health -= amount
		shield_health_changed.emit(shield_health, max_shield_health)

		if shield_sprite:
			shield_sprite.modulate = Color.RED
			await get_tree().create_timer(0.1).timeout
			shield_sprite.modulate = Color.WHITE

		if shield_health <= 0:
			_deactivate_shield()
		return

	player_health -= amount
	player_health = max(0, player_health)
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
