extends Control

var min_size = Vector2(581, 131)
var new_min_size = Vector2(581, 66)


func now() -> Dictionary:
	return Time.get_datetime_dict_from_system()

func colocar_datos(_email, fecha_hora, nickname, texto_estado)->void:
	$estado_label.text = texto_estado
	$nickname.text = nickname
	$fecha_hora.text = Global.calcular_diferencia_tiempo(now(), fecha_hora)

func adaptar_panel():
	var label_y = $estado_label.get_size().y
	if label_y > 111:
		label_y = 111
		$estado_label.clip_text = true
		$estado_label.rect_min_size = Vector2(553, 111)
		$label_refuerzo.visible = true
		$label_refuerzo.rect_position.y = $label_refuerzo.rect_position.y + label_y
		var nuevo_y = label_y + 70
		self.rect_min_size = Vector2(581,nuevo_y)
		$Panel.rect_min_size = Vector2(581,nuevo_y)
		$Button.rect_min_size = Vector2(581,nuevo_y + 3)
	else:
		var nuevo_y = label_y + 50
		self.rect_min_size = Vector2(581,nuevo_y)
		$Panel.rect_min_size = Vector2(581,nuevo_y)
		$Button.rect_min_size = Vector2(581,nuevo_y + 3)
