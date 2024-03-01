extends Control

###########################################
var contactos
var websocket_url = "ws://localhost:8765"
var _client = WebSocketClient.new()
func _ready():
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
	print("A1. Conectado con el servidor")
	print("A2. Solicitando lista_salas")
	solicitud_al_servidor("lista_salas", {"":"Se solicita la lista de contactos"})

func solicitud_al_servidor(accion: String, data: Dictionary):
	var solicitud = {"accion": accion, "data": data}
	var json_solicitud = JSON.print(solicitud)  # Convertir el diccionario a JSON
	_client.get_peer(1).put_var(json_solicitud)  # Envía los datos codificados como JSON

###########################################

func _handler():
	var datos_recibidos = _client.get_peer(1).get_packet().get_string_from_utf8()
	var respuesta = JSON.parse(datos_recibidos).result # diccionario
	
	if respuesta["tipo"] == "obtener_contactos":
		print("RESPUESTA RECIBIDA")
	elif respuesta["tipo"] == "obtener_estados":
		print("RESPUESTA RECIBIDA")
