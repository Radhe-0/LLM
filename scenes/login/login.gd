extends Control

var url = "http://127.0.0.1:5000"

func _ready():
	$register.visible = false
	$login.visible = true

func comprobar_passwords():
	if $register/password.text == $register/conf_password.text:
		return true
	else:
		return false


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error. Response code: " + str(response_code))
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		var respuesta = json.result
		
		if respuesta["tipo"] == "registro":
			if respuesta["data"] == "correo ya existente":
				print("El correo ya existe")
			elif respuesta["data"] == "registro exitoso":
				print("Registro exitoso")
	
		elif respuesta["tipo"] == "login":
			if respuesta["data"] == "credenciales correctas":
				print("Cambiar escena")
			elif respuesta["data"] == "credenciales incorrectas":
				print("Credenciales incorrectas")


func _on_registrarse_pressed():
	$login.visible = false
	$register.visible = true


func _on_in_sesion_pressed():
	$login.visible = true
	$register.visible = false


func _on_registrar_pressed():
	var passwords_coinciden = comprobar_passwords()
	if passwords_coinciden:
		var email = $login/email.text
		var password = $login/password.text
		var use_ssl = false
		var data_to_send = {"email": email, "password": password}
		var query = JSON.print(data_to_send)
		var headers = ["Content-Type: application/json"]
		$HTTPRequest.request(url+'/registro', headers, false, HTTPClient.METHOD_POST, query)
	else:
		print("Las contraseñas no coinciden")


func _on_ingresar_button_pressed():
	var email = $login/email.text
	var password = $login/password.text
	var use_ssl = false
	var data_to_send = {"email": email, "password": password}
	var query = JSON.print(data_to_send)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url+'/login', headers, false, HTTPClient.METHOD_POST, query)

