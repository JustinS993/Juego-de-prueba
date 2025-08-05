extends Node2D

# Variables
var text: String = ""
var text_color: Color = Color.WHITE
var duration: float = 1.5
var rise_height: float = 50.0
var fade_rate: float = 0.8
var scale_start: float = 0.5
var scale_end: float = 1.0
var is_critical: bool = false

# Referencias a nodos
@onready var label = $Label
@onready var timer = $Timer

# Función de inicialización
func _ready() -> void:
	# Configurar temporizador
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	# Inicializar propiedades
	modulate.a = 1.0
	scale = Vector2(scale_start, scale_start)
	
	# Aplicar texto y color
	if label:
		label.text = text
		label.add_theme_color_override("font_color", text_color)
		
		# Si es crítico, aplicar efecto visual
		if is_critical:
			label.add_theme_font_size_override("font_size", 24)  # Tamaño más grande
			scale_end = 1.2  # Escala final más grande

# Función de proceso
func _process(delta: float) -> void:
	# Mover hacia arriba
	position.y -= rise_height * delta / duration
	
	# Desvanecer gradualmente
	modulate.a -= fade_rate * delta
	
	# Escalar gradualmente
	var scale_factor = scale_start + (scale_end - scale_start) * (1.0 - modulate.a)
	scale = Vector2(scale_factor, scale_factor)
	
	# Si se ha desvanecido completamente, eliminar
	if modulate.a <= 0:
		queue_free()

# Establecer texto y color
func set_text(p_text: String, p_color: Color = Color.WHITE) -> void:
	text = p_text
	text_color = p_color
	
	# Aplicar si el nodo ya está listo
	if label:
		label.text = text
		label.add_theme_color_override("font_color", text_color)

# Establecer si es crítico
func set_critical(critical: bool) -> void:
	is_critical = critical
	
	# Aplicar si el nodo ya está listo
	if label and is_critical:
		label.add_theme_font_size_override("font_size", 24)  # Tamaño más grande
		scale_end = 1.2  # Escala final más grande

# Reproducir animación
func play() -> void:
	# Iniciar temporizador
	timer.start()

# Cuando finaliza el temporizador
func _on_timer_timeout() -> void:
	# Aumentar la velocidad de desvanecimiento para una salida más rápida
	fade_rate = 2.0