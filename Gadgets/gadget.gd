extends Area2D

enum GadgetType { MEDKIT, SHIELD, SLOW_TIME }

@export var gadget_type: GadgetType = GadgetType.MEDKIT
@export var speed: float = 200

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var is_collected = false

func _ready():
	print("Gadget _ready() - Type: ", gadget_type)
	
	if not sprite.texture:
		update_texture()
	
	scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	body_entered.connect(_on_body_entered)

func set_gadget_type(type: int):
	gadget_type = type
	update_texture()
	print("Gadget type set to: ", type)

func update_texture():
	match gadget_type:
		GadgetType.MEDKIT:
			sprite.texture = load("res://Gadgets/medkit.png")
			sprite.scale = Vector2(0.15, 0.15)
			print("MEDKIT texture loaded")
		GadgetType.SHIELD:
			sprite.texture = load("res://Gadgets/shield.png")
			sprite.scale = Vector2(0.2, 0.2)
			print("SHIELD texture loaded")
		GadgetType.SLOW_TIME:
			sprite.texture = load("res://Gadgets/slow_time.png")
			sprite.scale = Vector2(0.12, 0.12)
			print("SLOW_TIME texture loaded")

func _physics_process(delta):
	if not is_collected:
		position.x -= speed * delta
		
		if position.x < -100:
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and not is_collected:
		print("Gadget collected! Type: ", gadget_type)
		is_collected = true
		collision.set_deferred("disabled", true)
		
		match gadget_type:
			GadgetType.MEDKIT:
				if body.has_method("heal"):
					body.heal(30)
					print("Player healed!")
			GadgetType.SHIELD:
				if body.has_method("activate_shield"):
					body.activate_shield(10.0)
					print("Shield activated!")
			GadgetType.SLOW_TIME:
				if body.has_method("activate_slow_time"):
					body.activate_slow_time(5.0)
					print("Slow time activated!")
		
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
		await tween.finished
		queue_free()
