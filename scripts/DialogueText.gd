extends RichTextLabel

# Señales
signal text_completed
signal character_displayed(character)

# Variables para la visualización del texto
var text_queue = []
var current_text = ""
var display_speed = 0.03  # Segundos por carácter
var punctuation_delay = 0.2  # Pausa adicional para puntuación
var auto_continue = false  # Si debe continuar automáticamente al siguiente texto
var auto_continue_delay = 2.0  # Segundos de espera antes de continuar automáticamente

# Referencias a nodos
@onready var display_timer = $DisplayTimer
@onready var continue_timer = $ContinueTimer
@onready var audio_player = $AudioStreamPlayer

# Sonidos para diferentes personajes
var character_sounds = {}

# Variables de estado
var is_text_displaying = false
var current_speaker = ""
var current_index = 0

func _ready():
	# Inicializar timers si no existen
	if not has_node("DisplayTimer"):
		display_timer = Timer.new()
		display_timer.name = "DisplayTimer"
		display_timer.one_shot = true
		add_child(display_timer)
		display_timer.connect("timeout", Callable(self, "_on_display_timer_timeout"))
	
	if not has_node("ContinueTimer"):
		continue_timer = Timer.new()
		continue_timer.name = "ContinueTimer"
		continue_timer.one_shot = true
		add_child(continue_timer)
		continue_timer.connect("timeout", Callable(self, "_on_continue_timer_timeout"))
	
	if not has_node("AudioStreamPlayer"):
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AudioStreamPlayer"
		add_child(audio_player)
	
	# Configuración inicial
	visible_characters = 0
	text = ""

# Añadir texto a la cola
func add_text(text_to_add: String, speaker: String = "") -> void:
	text_queue.append({"text": text_to_add, "speaker": speaker})
	
	# Si no hay texto mostrándose, mostrar el siguiente
	if not is_text_displaying:
		display_next_text()

# Mostrar el siguiente texto en la cola
func display_next_text() -> void:
	# Verificar si hay texto en la cola
	if text_queue.empty():
		is_text_displaying = false
		return
	
	# Obtener el siguiente texto
	var next_text_data = text_queue.pop_front()
	current_text = next_text_data["text"]
	current_speaker = next_text_data["speaker"]
	
	# Preparar para mostrar
	text = current_text
	visible_characters = 0
	current_index = 0
	is_text_displaying = true
	
	# Iniciar temporizador para mostrar el primer carácter
	display_timer.start(display_speed)

# Mostrar el siguiente carácter
func display_next_character() -> void:
	# Verificar si se han mostrado todos los caracteres
	if current_index >= current_text.length():
		_on_text_display_completed()
		return
	
	# Incrementar caracteres visibles
	visible_characters += 1
	current_index += 1
	
	# Emitir señal con el carácter mostrado
	var current_char = current_text[current_index - 1]
	emit_signal("character_displayed", current_char)
	
	# Reproducir sonido si corresponde
	if character_sounds.has(current_speaker) and audio_player and not current_char.strip_edges().is_empty():
		audio_player.stream = character_sounds[current_speaker]
		audio_player.pitch_scale = randf_range(0.9, 1.1)  # Variación aleatoria
		audio_player.play()
	
	# Determinar retraso para el siguiente carácter
	var next_delay = display_speed
	
	# Añadir retraso adicional para puntuación
	if current_char in [".", "!", "?", ":", ";", ","]:
		next_delay += punctuation_delay
	
	# Iniciar temporizador para el siguiente carácter
	display_timer.start(next_delay)

# Saltar la animación y mostrar todo el texto
func skip_text_animation() -> void:
	# Mostrar todo el texto inmediatamente
	visible_characters = -1  # -1 muestra todos los caracteres
	current_index = current_text.length()
	
	# Detener el temporizador
	display_timer.stop()
	
	# Llamar a la función de finalización
	_on_text_display_completed()

# Continuar al siguiente texto o emitir señal de finalización
func continue_dialogue() -> void:
	# Si el texto aún se está mostrando, mostrarlo completo
	if is_text_displaying and visible_characters < current_text.length():
		skip_text_animation()
		return
	
	# Si hay más texto en la cola, mostrar el siguiente
	if not text_queue.empty():
		display_next_text()
	else:
		# Limpiar y emitir señal de finalización
		is_text_displaying = false
		emit_signal("text_completed")

# Establecer la velocidad de visualización
func set_display_speed(speed: float) -> void:
	display_speed = speed

# Establecer el retraso para puntuación
func set_punctuation_delay(delay: float) -> void:
	punctuation_delay = delay

# Establecer si debe continuar automáticamente
func set_auto_continue(auto: bool, delay: float = 2.0) -> void:
	auto_continue = auto
	auto_continue_delay = delay

# Añadir sonido para un personaje específico
func add_character_sound(speaker: String, sound_stream: AudioStream) -> void:
	character_sounds[speaker] = sound_stream

# Limpiar la cola de texto
func clear_text_queue() -> void:
	text_queue.clear()
	is_text_displaying = false
	display_timer.stop()
	continue_timer.stop()

# Callback cuando se completa la visualización del texto
func _on_text_display_completed() -> void:
	is_text_displaying = false
	
	# Si debe continuar automáticamente
	if auto_continue:
		continue_timer.start(auto_continue_delay)

# Callbacks para los timers
func _on_display_timer_timeout() -> void:
	display_next_character()

func _on_continue_timer_timeout() -> void:
	continue_dialogue()

# Procesar entrada
func _input(event: InputEvent) -> void:
	# Verificar si se presiona la tecla de acción "ui_accept"
	if event.is_action_pressed("ui_accept"):
		# Cancelar auto-continuación si estaba activa
		if continue_timer.is_stopped() == false:
			continue_timer.stop()
		
		continue_dialogue()