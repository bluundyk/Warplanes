extends Node2D

@export var coin_scene: PackedScene
@export var spawn_delay: float = 2.5
@export var spawn_range_y_min: float = 80
@export var spawn_range_y_max: float = 600

func _ready():
	if coin_scene == null:
		print("ERROR: Coin scene not assigned in CoinSpawner!")
		return
	
	print("CoinSpawner ready! Spawning coins every ", spawn_delay, " seconds")
	spawn_coin()

func spawn_coin():
	var coin = coin_scene.instantiate()
	add_child(coin)
	
	var viewport = get_viewport().get_visible_rect()
	
	coin.position = Vector2(
		viewport.size.x + 50,
		randf_range(spawn_range_y_min, min(spawn_range_y_max, viewport.size.y - 50))
	)
	
	print("Coin spawned at: ", coin.position)
	
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(coin):
		coin.queue_free()
		print("Coin auto-deleted (not collected)")
	
	await get_tree().create_timer(spawn_delay).timeout
	spawn_coin()
