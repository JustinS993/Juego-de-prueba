extends Control

# Variables
var start_position: Vector2 = Vector2.ZERO
var end_position: Vector2 = Vector2.ZERO
var connection_color: Color = Color.WHITE
var is_active: bool = false
var start_skill_id: String = ""
var end_skill_id: String = ""

# Constantes
const LINE_WIDTH: float = 3.0
const INACTIVE_OPACITY: float = 0.4

# Función de inicialización
func _ready() -> void:
	# Asegurar que el control ocupe todo el espacio disponible
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Configurar para recibir eventos de dibujo
	set_process(false)

# Función de dibujo
func _draw() -> void:
	# Calcular color según estado
	var draw_color = connection_color
	if not is_active:
		draw_color.a = INACTIVE_OPACITY
	
	# Dibujar línea de conexión
	draw_line(start_position, end_position, draw_color, LINE_WIDTH)
	
	# Dibujar círculo en el punto final para suavizar la conexión
	draw_circle(end_position, LINE_WIDTH / 2, draw_color)

# Establecer posición inicial
func set_start_position(pos: Vector2) -> void:
	start_position = pos
	queue_redraw()

# Establecer posición final
func set_end_position(pos: Vector2) -> void:
	end_position = pos
	queue_redraw()

# Establecer color de la conexión
func set_color(color: Color) -> void:
	connection_color = color
	queue_redraw()

# Establecer estado activo/inactivo
func set_active(active: bool) -> void:
	is_active = active
	queue_redraw()

# Establecer IDs de las habilidades conectadas
func set_skill_ids(start_id: String, end_id: String) -> void:
	start_skill_id = start_id
	end_skill_id = end_id

# Obtener IDs de las habilidades conectadas
func get_skill_ids() -> Array:
	return [start_skill_id, end_skill_id]