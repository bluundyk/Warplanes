extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 30
@export var shoot_delay_min: float = 2.5
@export var shoot_delay_max: float = 5.0

var health: int
var player: Node2D = null
var can_shoot: bool = true
var bullet_scene = preload("res://Bullet/bullet.tscn")
var explosion_scene = preload("res://Effects/explosion.tscn")

func _ready():
	health = max_health
	add_to_group("enemy")
	print("Enemy ready! Health: ", health)

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	velocity = Vector2.LEFT * speed
	move_and_slide()
	
	if player != null and can_shoot:
		if player.position.x < position.x:
			shoot()
	
	if position.x < -200:
		queue_free()

func shoot():
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	if player != null:
		var direction_to_player = (player.position - position).normalized()
		bullet.direction = direction_to_player
	else:
		bullet.direction = Vector2.LEFT
	
	bullet.speed = 400
	bullet.damage = 10
	bullet.shooter_type = "enemy"
	
	var random_delay = randf_range(shoot_delay_min, shoot_delay_max)
	await get_tree().create_timer(random_delay).timeout
	if is_instance_valid(self):
		can_shoot = true

func take_damage(amount: int):
	health -= amount
	print("Enemy took damage! Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func _on_collision_area_entered(body):
	if body.is_in_group("player"):
		print("Enemy collided with player!")
		
		if body.has_method("take_damage"):
			body.take_damage(20)
			print("Enemy ram damage: 20")
		
		die()

func die():
	print("Enemy destroyed!")
	
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
	
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
