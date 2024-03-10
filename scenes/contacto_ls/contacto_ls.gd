extends Control

export var target_size := Vector2(40, 40)

func _ready():
	self.add_to_group('nodos-contacto')
	print("colocado en grupo")
	var original_texture = $imagen_perfil.texture
	var imagen_recortada = Global.recortar_imagen(original_texture)
	$imagen_perfil.texture = imagen_recortada


func set_foto(imagenb64:String, email:String) -> void:
	var imagen_data = Marshalls.base64_to_raw(imagenb64)
	var imagen = Image.new()
	var resultado = imagen.load_png_from_buffer(imagen_data)
	var textura = ImageTexture.new()
	textura.create_from_image(imagen)
	#var imagen_recortada = Global.recortar_imagen(textura)
	$imagen_perfil.texture = textura


func get_email():
	return $email.text


func get_nickname():
	return $nickname.text


func set_nickname_email(nickname, email):
	$nickname.text = nickname
	$email.text = email
	
	Global.nodos_contacto[email] = self


