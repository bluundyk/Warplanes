extends Node2D

@export var gadget_scene: PackedScene
@export var spawn_delay: float = 5.0

func _ready():
	print("GadgetSpawner ready!")
	spawn_gadget()

func spawn_gadget():
	if gadget_scene:
		var random_type = randi() % 3
		print("Spawning gadget with type: ", random_type, " (0=MEDKIT, 1=SHIELD, 2=SLOW_TIME)")
		
		var gadget = gadget_scene.instantiate()
		add_child(gadget)
		
		if gadget.has_method("set_gadget_type"):
			gadget.set_gadget_type(random_type)
		else:
			print("ERROR: set_gadget_type method not found!")
		
		var viewport = get_viewport().get_visible_rect()
		gadget.position = Vector2(
			viewport.size.x + 50,
			randf_range(100, viewport.size.y - 100)
		)
		
		await get_tree().create_timer(15.0).timeout
		if is_instance_valid(gadget):
			gadget.queue_free()
	
	await get_tree().create_timer(spawn_delay).timeout
	spawn_gadget()
