extends Control

export var target_size := Vector2(40, 40)

func _ready():
	var original_texture = $imagen_perfil.texture
	recortar_imagen(original_texture)


func recortar_imagen(original_texture):
	# Obtener las dimensiones de la textura original
	var original_width = original_texture.get_width()
	var original_height = original_texture.get_height()

	# Calcular las dimensiones del recorte (mismo ancho y alto)
	var crop_size = min(original_width, original_height)

	# Calcular las coordenadas de inicio del recorte
	var crop_x = (original_width - crop_size) / 2
	var crop_y = (original_height - crop_size) / 2

	# Crear una nueva imagen con las dimensiones del recorte
	var cropped_image = Image.new()
	cropped_image.create(crop_size, crop_size, false, original_texture.get_data().get_format())

	# Obtener los datos de la imagen original
	var original_image = original_texture.get_data()

	# Copiar la región recortada de la imagen original a la nueva imagen
	cropped_image.blit_rect(original_image, Rect2(crop_x, crop_y, crop_size, crop_size), Vector2.ZERO)

	# Crear una nueva textura a partir de la imagen recortada
	var cropped_texture = ImageTexture.new()
	cropped_texture.create_from_image(cropped_image)

	# Asignar la nueva textura al nodo "imagen_perfil"
	$imagen_perfil.texture = cropped_texture


func set_nickname_email(nickname, email):
	$nickname.text = nickname
	$email.text = email


