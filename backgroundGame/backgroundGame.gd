extends Node2D
@onready var texture_rect1 = $TextureRect1
@onready var texture_rect2 = $TextureRect2
var images = []
var current_image_index = 0
var screen_width = 1152
var current_tween = null
func _ready():
	print("=== НАЧАЛО ИНИЦИАЛИЗАЦИИ ФОНА ===")
	print("Путь к папке с изображениями: res://путь/к/папке/с/изображениями")
	load_images_from_folder("res://Large 1024x1024/Starfields/")
	print("Загружено изображений: ", images.size())
	print("texture_rect1 существует: ", texture_rect1 != null)
	print("texture_rect2 существует: ", texture_rect2 != null)
	if images.size() > 0:
		texture_rect1.texture = images[0]
		print("texture_rect1.texture установлен: ", texture_rect1.texture != null)
		if images.size() > 1:
			texture_rect2.texture = images[1]
			texture_rect2.position.x = screen_width
		else:
			texture_rect2.texture = images[0]
			texture_rect2.position.x = screen_width
		print("texture_rect2.texture установлен: ", texture_rect2.texture != null)
	else:
		print("НЕТ ИЗОБРАЖЕНИЙ! Проверьте путь.")
	start_scrolling()
	print("=== ИНИЦИАЛИЗАЦИЯ ФОНА ЗАВЕРШЕНА ===")
func load_images_from_folder(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				var texture = load(path + "/" + file_name)
				images.append(texture)
			file_name = dir.get_next()
	if images.size() == 0:
		print("Изображения не найдены в папке: ", path)
func start_scrolling():
	print("=== start_scrolling() ВЫЗВАН ===")
	if current_tween and current_tween.is_running():
		print("Убиваем старый tween")
		current_tween.kill()
	current_tween = create_tween()
	print("Запускаем анимацию: texture_rect1 -> ", -screen_width, ", texture_rect2 -> 0")
	current_tween.tween_property(texture_rect1, "position:x", -screen_width, 5.0)
	current_tween.parallel().tween_property(texture_rect2, "position:x", 0, 5.0)
	print("Подключаем сигнал finished")
	current_tween.finished.connect(_on_scroll_finished)
func _on_scroll_finished():
	print("=== _on_scroll_finished() ВЫЗВАН ===")
	print("texture_rect1.position.x = ", texture_rect1.position.x)
	print("texture_rect2.position.x = ", texture_rect2.position.x)
	var new_texture = get_random_image()
	if new_texture:
		texture_rect1.texture = new_texture
		print("Новая текстура установлена")
	else:
		print("НЕТ НОВОЙ ТЕКСТУРЫ!")
	texture_rect1.position.x = screen_width
	print("texture_rect1.position.x установлен в ", screen_width)
	print("Вызываем swap_sprites()")
	swap_sprites()
	print("Вызываем start_scrolling() снова")
	start_scrolling()
func get_random_image():
	var random_index = randi() % images.size()
	return images[random_index]
func swap_sprites():
	print("=== swap_sprites() ВЫЗВАН ===")
	print("До: texture_rect1 = ", texture_rect1.name, ", texture_rect2 = ", texture_rect2.name)
	var temp = texture_rect1
	texture_rect1 = texture_rect2
	texture_rect2 = temp
	print("После: texture_rect1 = ", texture_rect1.name, ", texture_rect2 = ", texture_rect2.name)
