extends Control

var url = "http://127.0.0.1:5000"

###########################################
var websocket_url = "ws://localhost:8765"
var _client = WebSocketClient.new()

func _ready():
	OS.set_window_size(Vector2(1024, 600))
	obtener_contactos()
	obtener_foto()
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_handler")
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _process(_delta):
	_client.poll()

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(_proto = ""):
	solicitud_al_servidor("obtener_nickname", {"email": Global.email})
	solicitud_al_servidor("obtener_estados", {"email": Global.email})


func solicitud_al_servidor(accion: String, data: Dictionary): # al servidor websocket
	var solicitud = {"accion": accion, "data": data}
	var json_solicitud = JSON.print(solicitud)  # Convertir el diccionario a JSON
	_client.get_peer(1).put_var(json_solicitud)  # Envía los datos codificados como JSON

###########################################


func escoger_foto(email, path):
	var image_data = Image.new()
	image_data.load(path)
	var image_bytes = image_data.save_png_to_buffer()
	var imagenb64 = Marshalls.raw_to_base64(image_bytes)
	actualizar_foto( imagenb64)


func colocar_contactos(contactos): # agregar animacion y foto de cada contacto
	var nodos_contacto = []
	# Empezar animacion de carga
	for contacto in contactos:
		var contacto_ls = load("res://scenes/contacto_ls/contacto_ls.tscn").instance()
		contacto_ls.set_nickname_email(contacto[1], contacto[0])
		contacto_ls.set_foto(contacto[2], contacto[0])
		nodos_contacto.append(contacto_ls)
		
	
	for nodo in nodos_contacto:
		$contactos_scroll/VBoxContainer.add_child(nodo)
	# terminar animacion de carga

func colocar_estados(estados):
	var nodos_estado = []
	# Empezar animacion de carga
	for estado in estados:
		var email = estado["email"]
		var fecha_hora = estado["fecha_hora"]
		var nickname = estado["nickname"]
		var texto_estado = estado["texto_estado"]
		var estado_ls = load("res://scenes/estado_ls/estado.tscn").instance()
		estado_ls.colocar_datos(email, fecha_hora, nickname, texto_estado)
		nodos_estado.append(estado_ls)
	
	for nodo in nodos_estado:
		$estados_scroll/VBoxContainer.add_child(nodo)
		nodo.adaptar_panel()
	# terminar animacion de carga

func colocar_foto_usuario(imagenb64):
	var imagen_data = Marshalls.base64_to_raw(imagenb64)
	var imagen = Image.new()
	var resultado = imagen.load_png_from_buffer(imagen_data)
	if resultado != OK:
		print("Error al cargar la imagen: ", resultado)
		return
	var textura = ImageTexture.new()
	textura.create_from_image(imagen)
	Global.foto_perfil = textura
	#var imagen_recortada = Global.recortar_imagen(textura)
	$cambiar_foto/foto_perfil.texture = textura

func obtener_contactos():
	var email = Global.email
	var http_node = HTTPRequest.new()
	http_node.connect("request_completed", self, "_on_request_completed")
	add_child(http_node)
	http_node.request(url+'/contactos?correo_electronico='+email)


func obtener_foto():
	var email = Global.email
	var http_node = HTTPRequest.new()
	http_node.connect("request_completed", self, "_on_request_completed")
	add_child(http_node)
	http_node.request(url+'/obtener_foto?email='+email)


func actualizar_foto(imagenb64):
	var email = Global.email
	var http_node = HTTPRequest.new()
	http_node.connect("request_completed", self, "_on_request_completed")
	add_child(http_node)
	var data_to_send = {"email": email, "imagenb64": imagenb64}
	var query = JSON.print(data_to_send)
	var headers = ["Content-Type: application/json"]
	http_node.request(url+'/actualizar_foto', headers, false, HTTPClient.METHOD_POST, query)


#####################################################################

func _handler():
	var datos_recibidos = _client.get_peer(1).get_packet().get_string_from_utf8()
	var respuesta = JSON.parse(datos_recibidos).result # diccionario
	
	if respuesta["tipo"] == "obtener_nickname":
		$nickname_edit/nickname.text = respuesta["data"]
		$copiar_email/email.text = Global.email
		
	elif respuesta["tipo"] == "obtener_estados":
		colocar_estados(respuesta["data"])
	

	

########################################################################

func _on_cancelar_boton_pressed():
	$nuevo_estado.visible = true
	$escribir_estado.visible = false
	$estados_scroll.set_position(Vector2(406, 80))
	$estados_scroll.set_size(Vector2(598, 501))


func _on_nuevo_estado_boton_pressed():
	$nuevo_estado.visible = false
	$escribir_estado.visible = true
	$estados_scroll.set_position(Vector2(406, 157))
	$estados_scroll.set_size(Vector2(598, 424))


func _on_icono_foto_pressed():
	$FileDialog.popup()


func _on_FileDialog_confirmed():
	print("asd")


func _on_FileDialog_file_selected(path):
	escoger_foto(Global.email, path) 


func _on_foto_perfil_mouse_entered():
	$cambiar_foto/icono_foto.visible = true

func _on_foto_perfil_mouse_exited():
	$cambiar_foto/icono_foto.visible = false


func _on_icono_ag_contacto_pressed():
	$agregar_contacto.visible = true

func _on_Button_pressed():
	var email_contacto = $agregar_contacto/LineEdit.text
	$agregar_contacto.visible = false
	solicitud_al_servidor('agregar_contacto', {"email_contacto": email_contacto, "email": Global.email})


func _on_request_completed(_result, response_code, _headers, body): # handler http
	if response_code != 200:
		print("Error. Response code: " + str(response_code))
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		var respuesta = json.result
		
		if respuesta["tipo"] == "obtener_contactos":
			colocar_contactos(respuesta["data"])
		
		elif respuesta["tipo"] == "obtener_foto":
			colocar_foto_usuario(respuesta['data']['imagenb64'])
			
		elif respuesta["tipo"] == "actualizar_foto":
			colocar_foto_usuario(respuesta['data']['imagenb64'])
