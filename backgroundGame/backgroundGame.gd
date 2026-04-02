extends Node2D

@onready var texture_rect1 = $TextureRect1
@onready var texture_rect2 = $TextureRect2

var images = []
var screen_width = 1152
var speed = 200.0

func _ready():
	load_images_from_folder("res://Large 1024x1024/Starfields/")
	
	if images.size() == 0:
		print("Нет изображений!")
		return
	
	texture_rect1.texture = images[0]
	texture_rect2.texture = images[1 % images.size()]
	
	texture_rect1.position = Vector2(0, 0)
	texture_rect2.position = Vector2(screen_width, 0)

# -------------------------

func _process(delta):
	# Двигаем оба влево
	texture_rect1.position.x -= speed * delta
	texture_rect2.position.x -= speed * delta
	
	# Если первый ушёл — переносим его вправо от второго
	if texture_rect1.position.x <= -screen_width:
		texture_rect1.position.x = texture_rect2.position.x + screen_width
		texture_rect1.texture = get_random_image()
	
	# Если второй ушёл — переносим его вправо от первого
	if texture_rect2.position.x <= -screen_width:
		texture_rect2.position.x = texture_rect1.position.x + screen_width
		texture_rect2.texture = get_random_image()

# -------------------------

func load_images_from_folder(path):
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".jpg")):
				var texture = load(path + "/" + file_name)
				if texture:
					images.append(texture)
			file_name = dir.get_next()
		
		dir.list_dir_end()

# -------------------------

func get_random_image():
	return images[randi() % images.size()]
