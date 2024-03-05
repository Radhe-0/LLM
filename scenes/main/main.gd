extends Control

###########################################
var websocket_url = "ws://localhost:8765"
var _client = WebSocketClient.new()
func _ready():
	OS.set_window_size(Vector2(1024, 600))
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
	solicitud_al_servidor("obtener_contactos", {"email":  Global.email})
	solicitud_al_servidor("obtener_estados", {"email": Global.email})

func solicitud_al_servidor(accion: String, data: Dictionary):
	var solicitud = {"accion": accion, "data": data}
	var json_solicitud = JSON.print(solicitud)  # Convertir el diccionario a JSON
	_client.get_peer(1).put_var(json_solicitud)  # Envía los datos codificados como JSON

###########################################


func colocar_contactos(contactos): # agregar animacion y foto de cada contacto
	var nodos_contacto = []
	# Empezar animacion de carga
	for contacto in contactos:
		var contacto_ls = load("res://scenes/contacto_ls/contacto_ls.tscn").instance()
		contacto_ls.set_nickname_email(contacto[1], contacto[0])
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

#####################################################################

func _handler():
	var datos_recibidos = _client.get_peer(1).get_packet().get_string_from_utf8()
	var respuesta = JSON.parse(datos_recibidos).result # diccionario
	
	if respuesta["tipo"] == "obtener_contactos":
		colocar_contactos(respuesta["data"])
	
	elif respuesta["tipo"] == "obtener_nickname":
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
