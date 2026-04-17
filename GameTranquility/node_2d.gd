extends Node

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_delay: float = 1.0
@export var max_enemies: int = 10  # Максимальное количество врагов

var current_enemies: int = 0  # Текущее количество врагов
var player: Node2D  # Ссылка на игрока

@onready var background = $BackgroundGame
@onready var game_area = get_viewport().get_visible_rect()

func _ready():
	# Находим игрока
	player = get_node("../BackgroundGame/Plane")  # Путь к игроку
	
	if enemy_scene == null:
		push_error("Enemy scene not assigned!")
		return
	
	var timer = Timer.new()
	timer.wait_time = spawn_delay
	timer.one_shot = true
	timer.timeout.connect(_start_spawning)
	add_child(timer)
	timer.start()

func _start_spawning():
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_enemy)
	add_child(spawn_timer)
	spawn_timer.start()

func _spawn_enemy():
	# Проверяем, не достигнут ли лимит врагов
	if current_enemies >= max_enemies:
		return
	
	if enemy_scene == null:
		return
	
	# Создаем врага
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	# Устанавливаем размер врага (если нужно)
	if enemy.has_method("set_size"):
		enemy.set_size(Vector2(64, 64))  # Задай свой размер
	
	# Передаем ссылку на игрока врагу
	if enemy.has_method("set_player"):
		enemy.set_player(player)
	
	# Позиция спавна справа за экраном
	var viewport_rect = get_viewport().get_visible_rect()
	var spawn_x = viewport_rect.end.x + 50
	var spawn_y = randf_range(50, viewport_rect.end.y - 50)
	
	enemy.position = Vector2(spawn_x, spawn_y)
	
	# Увеличиваем счетчик врагов
	current_enemies += 1
	
	# Подписываемся на сигнал смерти врага
	enemy.tree_exited.connect(_on_enemy_destroyed)

func _on_enemy_destroyed():
	# Уменьшаем счетчик, когда враг уничтожен
	current_enemies -= 1
