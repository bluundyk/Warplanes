extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

var speed = 200
var is_collected = false

func _ready():
	animated_sprite.play("idle")
	body_entered.connect(_on_body_entered)
	
	scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

func _physics_process(delta):
	if not is_collected:
		position.x -= speed * delta
		
		if position.x < -100:
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and not is_collected:
		collect(body)

func collect(player):
	is_collected = true
	speed = 0
	
	$CollisionShape2D.set_deferred("disabled", true)
	animated_sprite.play("take")
	
	if player.has_method("add_coin"):
		player.add_coin(1)
	
	await animated_sprite.animation_finished
	queue_free()
