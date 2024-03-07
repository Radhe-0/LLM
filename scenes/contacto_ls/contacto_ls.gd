extends Control

export var target_size := Vector2(40, 40)

func _ready():
	self.add_to_group('nodos-contacto')
	var original_texture = $imagen_perfil.texture
	var imagen_recortada = Global.recortar_imagen(original_texture)
	$imagen_perfil.texture = imagen_recortada


func set_foto(texture):
	$imagen_perfil.texture = texture


func get_email():
	return $email.text


func get_nickname():
	return $nickname.text


func set_nickname_email(nickname, email):
	$nickname.text = nickname
	$email.text = email
	
	Global.nodos_contacto[email] = self


