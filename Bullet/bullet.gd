extends Area2D

@export var speed: float = 700.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

var shooter_type: String = "player":
	set(value):
		shooter_type = value
		if has_node("AnimatedSprite2D"):
			if shooter_type == "player":
				$AnimatedSprite2D.play("fly")
			else:
				$AnimatedSprite2D.play("flyForEnemy")
				add_to_group("enemy_bullet")

const EXPLOSION_SCENE = preload("res://Effects/explosion.tscn")

func _ready():
	body_entered.connect(_on_body_entered)
	
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if shooter_type == "player" and body.is_in_group("enemy"):
		hit_target(body)
		
	elif shooter_type == "enemy" and body.is_in_group("player"):
		hit_target(body)
		
	elif body.name == "StaticBody2D" or body.is_in_group("walls"): 
		hit_target(null)

func hit_target(target):
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
	
	create_explosion()
	queue_free()

func create_explosion():
	if EXPLOSION_SCENE:
		var explosion = EXPLOSION_SCENE.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		print("Пуля " + shooter_type + " взорвалась.")
