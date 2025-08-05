extends RichTextLabel

# Señales
signal text_completed
signal char_displayed(character)

# Variables
var text_queue = []  # Cola de textos a mostrar
var current_text = ""  # Texto actual
var display_speed = 0.03  # Tiempo entre caracteres (segundos)
var punctuation_delay = 0.2  # Retraso adicional para puntuación
var is_displaying = false  # Si está mostrando texto actualmente
var can_skip = true  # Si se puede saltar la animación
var auto_continue = false  # Si continúa automáticamente al siguiente texto
var auto_continue_delay = 1.0  # Tiempo de espera antes de continuar automáticamente

# Referencias a nodos
@onready var display_timer = $DisplayTimer
@onready var continue_timer = $ContinueTimer
@onready var audio_player = $AudioStreamPlayer

# Sonidos
var default_sound = null  # Sonido por defecto para el texto
var character_sounds = {}  # Sonidos específicos por personaje

# Función de inicialización
func _ready() -> void:
	# Configurar temporizadores
	display_timer = Timer.new()
	display_timer.one_shot = true
	display_timer.connect("timeout", Callable(self, "_on_display_timer_timeout"))
	add_child(display_timer)
	
	continue_timer = Timer.new()
	continue_timer.one_shot = true
	continue_timer.connect("timeout", Callable(self, "_on_continue_timer_timeout"))
	add_child(continue_timer)
	
	# Configurar reproductor de audio
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = -15  # Volumen bajo para no ser molesto
	add_child(audio_player)
	
	# Cargar sonido por defecto
	var default_sound_path = "res://assets/audio/ui/text_default.wav"
	if ResourceLoader.exists(default_sound_path):
		default_sound = load(default_sound_path)
	
	# Inicializar vacío
	text = ""
	visible_characters = 0

# Función para añadir texto a la cola
func add_text(new_text: String, character_name: String = "") -> void:
	# Añadir a la cola
	text_queue.append({"text": new_text, "character": character_name})
	
	# Si no está mostrando texto, comenzar
	if not is_displaying:
		display_next_text()

# Función para mostrar el siguiente texto en la cola
func display_next_text() -> void:
	# Verificar si hay texto en la cola
	if text_queue.is_empty():
		is_displaying = false
		return
	
	# Obtener siguiente texto
	var next_item = text_queue.pop_front()
	current_text = next_item["text"]
	var character = next_item["character"]
	
	# Configurar sonido según el personaje
	if character != "" and character_sounds.has(character):
		audio_player.stream = character_sounds[character]
	else:
		audio_player.stream = default_sound
	
	# Reiniciar texto
	text = current_text
	visible_characters = 0
	
	# Comenzar a mostrar
	is_displaying = true
	display_timer.start(display_speed)

# Función para mostrar el siguiente carácter
func display_next_char() -> void:
	# Verificar si se ha mostrado todo el texto
	if visible_characters >= text.length():
		_on_text_completed()
		return
	
	# Mostrar siguiente carácter
	visible_characters += 1
	
	# Obtener carácter actual
	var current_char = text[visible_characters - 1] if visible_characters > 0 and visible_characters <= text.length() else ""
	
	# Emitir señal con el carácter mostrado
	emit_signal("char_displayed", current_char)
	
	# Reproducir sonido si no es un espacio
	if current_char != " " and audio_player.stream:
		# Variar ligeramente el tono para que no sea monótono
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
	
	# Determinar retraso para el siguiente carácter
	var next_delay = display_speed
	
	# Añadir retraso adicional para puntuación
	if current_char in [".", "!", "?", ":", ";", ","]:
		next_delay = punctuation_delay
	
	# Iniciar temporizador para el siguiente carácter
	display_timer.start(next_delay)

# Función para mostrar todo el texto inmediatamente
func skip_text_animation() -> void:
	# Verificar si se puede saltar
	if not can_skip:
		return
	
	# Mostrar todo el texto
	visible_characters = text.length()
	
	# Detener temporizador
	display_timer.stop()
	
	# Llamar a función de texto completado
	_on_text_completed()

# Función para continuar al siguiente texto
func continue_dialogue() -> void:
	# Si está mostrando texto, saltar animación
	if is_displaying and visible_characters < text.length():
		skip_text_animation()
		return
	
	# Si no está mostrando texto, mostrar siguiente
	display_next_text()

# Función para establecer la velocidad de visualización
func set_display_speed(speed: float) -> void:
	display_speed = speed

# Función para establecer el retraso de puntuación
func set_punctuation_delay(delay: float) -> void:
	punctuation_delay = delay

# Función para establecer si se puede saltar la animación
func set_can_skip(skip: bool) -> void:
	can_skip = skip

# Función para establecer si continúa automáticamente
func set_auto_continue(auto: bool, delay: float = 1.0) -> void:
	auto_continue = auto
	auto_continue_delay = delay

# Función para añadir un sonido específico para un personaje
func add_character_sound(character_name: String, sound_path: String) -> void:
	# Verificar si existe el sonido
	if ResourceLoader.exists(sound_path):
		character_sounds[character_name] = load(sound_path)

# Función para limpiar la cola de textos
func clear_queue() -> void:
	text_queue.clear()
	is_displaying = false
	display_timer.stop()
	continue_timer.stop()

# Callback cuando se completa el temporizador de visualización
func _on_display_timer_timeout() -> void:
	display_next_char()

# Callback cuando se completa el temporizador de continuación
func _on_continue_timer_timeout() -> void:
	display_next_text()

# Callback cuando se completa el texto
func _on_text_completed() -> void:
	# Emitir señal
	emit_signal("text_completed")
	
	# Si está configurado para continuar automáticamente
	if auto_continue and not text_queue.is_empty():
		continue_timer.start(auto_continue_delay)
	else:
		is_displaying = false

# Función para procesar entrada
func _input(event: InputEvent) -> void:
	# Verificar si es un evento de acción de "ui_accept"
	if event.is_action_pressed("ui_accept"):
		continue_dialogue()