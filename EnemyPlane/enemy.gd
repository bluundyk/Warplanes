extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 30
@export var shoot_delay_min: float = 2.5
@export var shoot_delay_max: float = 5.0

var health: int
var player: Node2D = null
var is_dead: bool = false
var can_shoot: bool = true
var bullet_scene = preload("res://Bullet/bullet.tscn")
var explosion_scene = preload("res://Effects/explosion.tscn")

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	health = max_health
	add_to_group("enemy")
	print("Enemy ready! Health: ", health)

func _physics_process(delta):
	if is_dead:
		return
	
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
	if is_dead:
		return
	
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
	if is_instance_valid(self) and not is_dead:
		can_shoot = true

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	print("Enemy took damage! Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func _on_collision_area_entered(body):
	if is_dead:
		return
	
	if body.is_in_group("player"):
		print("Enemy collided with player!")
		
		if body.has_method("take_damage"):
			body.take_damage(20)
			print("Enemy ram damage: 20")
		
		die()

func die():
	if is_dead:
		return
	
	is_dead = true
	
	print("Enemy destroyed!")
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var area = $Area2D
	if area:
		area.monitoring = false
		area.monitorable = false
	
	velocity = Vector2.ZERO
	can_shoot = false
	
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
	
	if animated_sprite:
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	
	queue_free()
