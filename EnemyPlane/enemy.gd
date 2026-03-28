extends CharacterBody2D

@export var speed: float = 150.0
@export var chase_speed: float = 250.0
@export var detection_radius: float = 300.0

var player: Node2D = null
var is_chasing: bool = false
var movement_direction: Vector2 = Vector2.LEFT

func _ready():
	# Для CharacterBody2D используем другое подключение
	setup_detection_area()

func setup_detection_area():
	var detection_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	collision_shape.shape = circle_shape
	detection_area.add_child(collision_shape)
	add_child(detection_area)
	
	# Подключаем сигналы области обнаружения
	detection_area.body_entered.connect(_on_detection_area_entered)
	detection_area.body_exited.connect(_on_detection_area_exited)
	
	# Для столкновений используем свойство CharacterBody2D
	# Нужно добавить Area2D для столкновений с игроком
	setup_collision_area()

func setup_collision_area():
	var collision_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	# Используем ту же форму, что и у основного коллайдера
	if get_node("CollisionShape2D"):
		var main_shape = $CollisionShape2D.shape
		collision_shape.shape = main_shape
	collision_area.add_child(collision_shape)
	add_child(collision_area)
	collision_area.body_entered.connect(_on_collision_area_entered)

func set_player(player_node: Node2D):
	player = player_node

func _physics_process(delta):
	if player == null:
		velocity = movement_direction * speed
	else:
		var distance_to_player = position.distance_to(player.position)
		
		if is_chasing or distance_to_player < detection_radius:
			is_chasing = true
			var direction = (player.position - position).normalized()
			velocity = direction * chase_speed
			rotation = direction.angle()
		else:
			velocity = movement_direction * speed
	
	move_and_slide()
	
	var viewport_rect = get_viewport().get_visible_rect()
	if position.x < viewport_rect.position.x - 200 or position.x > viewport_rect.end.x + 200:
		queue_free()

func _on_collision_area_entered(body):
	if body.name == "Plane":
		if body.has_method("take_damage"):
			body.take_damage(10)
		queue_free()

func _on_detection_area_entered(body):
	if body.name == "Plane":
		is_chasing = true

func _on_detection_area_exited(body):
	if body.name == "Plane":
		await get_tree().create_timer(1.0).timeout
		if player and position.distance_to(player.position) > detection_radius:
			is_chasing = false
