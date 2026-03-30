extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("explosion")
	await animated_sprite.animation_finished
	queue_free()
