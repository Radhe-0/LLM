extends Node

var foto_perfil
var email
var nodos_contacto = {}


func es_bisiesto(year):
	var cond_1 = year % 4 == 0
	var cond_2 = year % 100 != 0
	var cond_3 = year % 400 == 0
	return cond_1 and (cond_2 or cond_3)


func calcular_diferencia_tiempo(fecha_actual, fecha_anterior):
	# Definir la cantidad de días por mes
	var dias_por_mes = [31, 28 + int(es_bisiesto(fecha_actual['year'])), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Calcular la diferencia en segundos entre las dos fechas
	var _diferencia_years = fecha_actual['year'] - fecha_anterior['year']
	var _diferencia_meses = fecha_actual['month'] - fecha_anterior['month']
	var diferencia_dias = fecha_actual['day'] - fecha_anterior['day']
	var diferencia_horas = fecha_actual['hour'] - fecha_anterior['hour']
	var diferencia_minutos = fecha_actual['minute'] - fecha_anterior['minute']
	var diferencia_segundos = fecha_actual['second'] - fecha_anterior['second']
	
	# Calcular la diferencia total de días, teniendo en cuenta los años bisiestos y los días por mes
	var total_dias = diferencia_dias
	for mes in range(fecha_anterior['month'], fecha_actual['month']):
		total_dias += dias_por_mes[mes - 1]  # Ajustar el índice del mes para la lista
	
	# Sumar los días de los años completos
	for year in range(fecha_anterior['year'], fecha_actual['year']):
		total_dias += 365 + es_bisiesto(year)
	
	# Convertir todo a segundos
	var total_segundos = total_dias * 86400 + diferencia_horas * 3600 + diferencia_minutos * 60 + diferencia_segundos
	
	# Convertir la diferencia a un texto legible
	if total_segundos < 60:
		return "hace unos pocos segundos"
	elif total_segundos < 120:
		return "hace 1 minuto"
	elif total_segundos < 3600:
		return "hace " + str(floor(total_segundos / 60)) + " minutos"
	elif total_segundos < 7200:
		return "hace 1 hora"
	elif total_segundos < 86400:
		return "hace " + str(floor(total_segundos / 3600)) + " horas"
	elif total_segundos < 172800:
		return "hace 1 día"
	else:
		return "hace " + str(floor(total_segundos / 86400)) + " días"


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
	return cropped_texture

