extends Panel

# NotificationItem.gd - Elemento individual de notificación para "Cenizas del Horizonte"
# Muestra una notificación con título, mensaje, icono y color personalizable

# Señales
signal notification_clicked(notification_id)
signal notification_hidden(notification_id)

# Referencias a nodos
onready var title_label = $Title
onready var message_label = $Message
onready var icon_texture = $Icon
onready var color_bar = $ColorBar
onready var close_button = $CloseButton
onready var timer = $Timer
onready var animation_player = $AnimationPlayer

# Variables
var notification_id = -1
var duration = 5.0
var is_hiding = false

# Función de inicialización
func _ready() -> void:
	# Conectar señales
	close_button.connect("pressed", self, "_on_close_button_pressed")
	timer.connect("timeout", self, "_on_timer_timeout")
	connect("gui_input", self, "_on_gui_input")
	
	# Iniciar con animación de entrada
	modulate.a = 0
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	# Iniciar temporizador si la duración es mayor que 0
	if duration > 0:
		timer.start(duration)

# Configurar la notificación
func setup(id: int, title_text: String, message_text: String, 
			icon = null, color = Color(0, 0.7, 1), time: float = 5.0) -> void:
	# Guardar ID
	notification_id = id
	
	# Establecer textos
	title_label.text = title_text
	message_label.text = message_text
	
	# Establecer icono si se proporciona
	if icon != null:
		icon_texture.texture = icon
		icon_texture.show()
	else:
		icon_texture.hide()
	
	# Establecer color
	color_bar.color = color
	
	# Establecer duración
	duration = time

# Ocultar la notificación
func hide_notification() -> void:
	# Evitar múltiples llamadas
	if is_hiding:
		return
	
	is_hiding = true
	
	# Detener temporizador
	timer.stop()
	
	# Reproducir animación de salida
	animation_player.play("fade")
	
	# Conectar señal de finalización de animación
	if not animation_player.is_connected("animation_finished", self, "_on_animation_finished"):
		animation_player.connect("animation_finished", self, "_on_animation_finished")

# Manejador de clic en el botón de cierre
func _on_close_button_pressed() -> void:
	hide_notification()

# Manejador de timeout del temporizador
func _on_timer_timeout() -> void:
	hide_notification()

# Manejador de finalización de animación
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade":
		# Emitir señal
		emit_signal("notification_hidden", notification_id)
		
		# Eliminar nodo
		queue_free()

# Manejador de entrada de GUI
func _on_gui_input(event: InputEvent) -> void:
	# Verificar si es un clic
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# Emitir señal
		emit_signal("notification_clicked", notification_id)
		
		# Ocultar notificación
		hide_notification()