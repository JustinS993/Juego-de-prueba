extends CanvasLayer

# Señales
signal dialogue_closed

# Referencias a nodos de la UI
onready var dialogue_panel = $DialoguePanel
onready var npc_name_label = $DialoguePanel/NPCInfo/NPCName
onready var npc_portrait = $DialoguePanel/NPCInfo/NPCPortrait
onready var dialogue_text = $DialoguePanel/DialogueContent/DialogueText
onready var player_choices = $DialoguePanel/DialogueContent/PlayerChoices
onready var continue_button = $DialoguePanel/DialogueContent/ContinueButton
onready var animation_player = $AnimationPlayer

# Variables para controlar el diálogo
var is_typing = false
var current_text = ""
var display_text = ""
var typing_speed = 0.03
var current_emotion = "neutral"
var choice_buttons = []

# Diccionario de emociones y sus correspondientes animaciones faciales
const EMOTIONS = {
	"neutral": "neutral",
	"happy": "happy",
	"sad": "sad",
	"angry": "angry",
	"surprised": "surprised",
	"afraid": "afraid",
	"confused": "confused",
	"amused": "amused",
	"wise": "wise",
	"sincere": "sincere",
	"educational": "educational",
	"understanding": "understanding",
	"concerned": "concerned",
	"passionate": "passionate",
	"offering": "offering",
	"respectful": "respectful",
	"inviting": "inviting"
}

# Colores para diferentes hablantes
const SPEAKER_COLORS = {
	"player": Color(0.2, 0.6, 1.0),  # Azul para el jugador
	"npc": Color(1.0, 0.8, 0.2),     # Amarillo para NPCs
	"system": Color(0.8, 0.8, 0.8)   # Gris para mensajes del sistema
}

func _ready():
	# Conectar señales del DialogueManager
	DialogueManager.connect("dialogue_started", self, "_on_dialogue_started")
	DialogueManager.connect("dialogue_ended", self, "_on_dialogue_ended")
	
	# Ocultar el panel de diálogo al inicio
	dialogue_panel.visible = false
	continue_button.visible = false
	
	# Conectar señal del botón continuar
	continue_button.connect("pressed", self, "_on_continue_button_pressed")

# Función llamada cuando comienza un diálogo
func _on_dialogue_started(dialogue_id):
	# Mostrar el panel de diálogo con animación
	dialogue_panel.visible = true
	animation_player.play("dialogue_appear")
	
	# Actualizar el diálogo
	update_dialogue()

# Función llamada cuando termina un diálogo
func _on_dialogue_ended(dialogue_id):
	# Ocultar el panel de diálogo con animación
	animation_player.play("dialogue_disappear")
	yield(animation_player, "animation_finished")
	dialogue_panel.visible = false
	
	# Emitir señal de que el diálogo se ha cerrado
	emit_signal("dialogue_closed")

# Actualizar el contenido del diálogo
func update_dialogue():
	# Obtener la información del diálogo actual
	var dialogue_info = DialogueManager.get_current_dialogue_text()
	
	if dialogue_info.empty():
		return
	
	# Actualizar nombre e imagen del NPC
	npc_name_label.text = dialogue_info["npc_name"]
	
	# Cargar el retrato del NPC
	var portrait_path = "res://assets/portraits/" + dialogue_info["portrait"]
	if dialogue_info.has("emotion") and EMOTIONS.has(dialogue_info["emotion"]):
		current_emotion = dialogue_info["emotion"]
		portrait_path += "_" + EMOTIONS[current_emotion]
	portrait_path += ".png"
	
	# Cargar la textura del retrato
	var texture = load(portrait_path)
	if texture:
		npc_portrait.texture = texture
	else:
		# Cargar un retrato por defecto si no se encuentra
		npc_portrait.texture = load("res://assets/portraits/default.png")
	
	# Configurar el texto del diálogo
	current_text = dialogue_info["text"]
	display_text = ""
	
	# Configurar el color del texto según el hablante
	if SPEAKER_COLORS.has(dialogue_info["speaker"]):
		dialogue_text.add_color_override("default_color", SPEAKER_COLORS[dialogue_info["speaker"]])
	
	# Iniciar la animación de escritura
	is_typing = true
	start_typing_animation()
	
	# Limpiar opciones anteriores
	clear_choices()
	
	# Si hay opciones, mostrarlas
	if dialogue_info.has("choices") and dialogue_info["choices"].size() > 0:
		continue_button.visible = false
		for i in range(dialogue_info["choices"].size()):
			add_choice_button(dialogue_info["choices"][i], i)
	else:
		# Si no hay opciones, mostrar el botón de continuar
		continue_button.visible = true

# Iniciar la animación de escritura del texto
func start_typing_animation():
	display_text = ""
	is_typing = true
	
	# Desactivar el botón de continuar mientras se escribe
	continue_button.disabled = true
	
	# Iniciar el temporizador para la animación de escritura
	$TypingTimer.wait_time = typing_speed
	$TypingTimer.start()

# Función llamada en cada tick del temporizador de escritura
func _on_typing_timer_timeout():
	if is_typing:
		if display_text.length() < current_text.length():
			# Añadir el siguiente carácter
			display_text += current_text[display_text.length()]
			dialogue_text.text = display_text
			
			# Reproducir sonido de escritura (opcional)
			if display_text.length() % 3 == 0:
				$TypingSound.play()
		else:
			# Finalizar la animación de escritura
			is_typing = false
			$TypingTimer.stop()
			
			# Activar el botón de continuar
			continue_button.disabled = false

# Añadir un botón de opción
func add_choice_button(choice_text, choice_index):
	var button = Button.new()
	button.text = choice_text
	button.connect("pressed", self, "_on_choice_button_pressed", [choice_index])
	player_choices.add_child(button)
	choice_buttons.append(button)

# Limpiar todas las opciones
func clear_choices():
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

# Función llamada cuando se presiona un botón de opción
func _on_choice_button_pressed(choice_index):
	# Seleccionar la opción en el DialogueManager
	DialogueManager.select_dialogue_choice(choice_index)
	
	# Actualizar el diálogo
	update_dialogue()

# Función llamada cuando se presiona el botón de continuar
func _on_continue_button_pressed():
	# Si aún está escribiendo, mostrar todo el texto de inmediato
	if is_typing:
		is_typing = false
		$TypingTimer.stop()
		dialogue_text.text = current_text
		continue_button.disabled = false
		return
	
	# Avanzar al siguiente diálogo
	DialogueManager.advance_dialogue()
	
	# Actualizar el diálogo
	update_dialogue()

# Función para saltar el diálogo actual (útil para teclas de acceso rápido)
func skip_dialogue():
	DialogueManager.end_dialogue()

# Procesar entrada de teclado
func _input(event):
	if not dialogue_panel.visible:
		return
	
	if event is InputEventKey and event.pressed:
		# Tecla Espacio o Enter para continuar
		if event.scancode == KEY_SPACE or event.scancode == KEY_ENTER:
			if continue_button.visible and not continue_button.disabled:
				_on_continue_button_pressed()
		
		# Tecla Escape para saltar el diálogo
		elif event.scancode == KEY_ESCAPE:
			skip_dialogue()