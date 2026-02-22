extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

const FLIGHT_SPEED = 300.0
const VERTICAL_SPEED = 400.0

func _ready():
	animated_sprite.play("flying")
	animation_player.play("collision_flying")


func _physics_process(delta):
	var vertical_direction = Input.get_axis("move_up", "move_down")
	var gorizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.y = vertical_direction * VERTICAL_SPEED
	velocity.x = gorizontal_direction * FLIGHT_SPEED
	
	var screen_size = get_viewport().get_visible_rect().size
	position.y = clamp(position.y, 45, screen_size.y - 45)
	position.x = clamp(position.x, 55, screen_size.x - 1050)
	
	move_and_slide()
