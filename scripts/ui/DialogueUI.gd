extends Control

# Referencias a nodos
@onready var dialogue_box = $DialogueBox
@onready var name_label = $DialogueBox/MarginContainer/VBoxContainer/TopRow/NamePanel/NameLabel
@onready var portrait = $DialogueBox/MarginContainer/VBoxContainer/MiddleRow/PortraitContainer/Portrait
@onready var dialogue_text = $DialogueBox/MarginContainer/VBoxContainer/MiddleRow/TextContainer/DialogueText
@onready var continue_indicator = $DialogueBox/MarginContainer/VBoxContainer/BottomRow/ContinueIndicator
@onready var choices_container = $DialogueBox/MarginContainer/VBoxContainer/ChoicesContainer

# Referencia al DialogueManager
var dialogue_manager = null

# Variables de estado
var current_dialogue_id = ""
var is_choice_active = false
var choice_buttons = []

# Precargar sonidos de texto para diferentes personajes
var character_sounds = {
	"default": preload("res://assets/audio/sfx/dialogue/text_default.wav"),
	"kaelen": preload("res://assets/audio/sfx/dialogue/text_kaelen.wav"),
	"sira": preload("res://assets/audio/sfx/dialogue/text_sira.wav"),
	"greta": preload("res://assets/audio/sfx/dialogue/text_greta.wav"),
	"kovak": preload("res://assets/audio/sfx/dialogue/text_kovak.wav"),
	"ghost_child": preload("res://assets/audio/sfx/dialogue/text_ghost_child.wav")
}

# Precargar retratos de personajes
var character_portraits = {
	"kaelen": {
		"neutral": preload("res://assets/sprites/portraits/kaelen_neutral.png"),
		"happy": preload("res://assets/sprites/portraits/kaelen_happy.png"),
		"angry": preload("res://assets/sprites/portraits/kaelen_angry.png"),
		"sad": preload("res://assets/sprites/portraits/kaelen_sad.png")
	},
	"sira": {
		"neutral": preload("res://assets/sprites/portraits/sira_neutral.png"),
		"happy": preload("res://assets/sprites/portraits/sira_happy.png"),
		"angry": preload("res://assets/sprites/portraits/sira_angry.png"),
		"sad": preload("res://assets/sprites/portraits/sira_sad.png")
	},
	# Añadir más personajes según sea necesario
}

func _ready():
	# Obtener referencia al DialogueManager
	dialogue_manager = get_node("/root/DialogueManager")
	
	# Conectar señales del DialogueManager
	dialogue_manager.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	dialogue_manager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	
	# Configurar el DialogueText
	dialogue_text.set_display_speed(0.03)
	dialogue_text.set_punctuation_delay(0.2)
	
	# Añadir sonidos de personajes
	for character in character_sounds:
		dialogue_text.add_character_sound(character, character_sounds[character])
	
	# Ocultar el diálogo inicialmente
	dialogue_box.visible = false
	choices_container.visible = false
	continue_indicator.visible = false
	
	# Recopilar botones de opciones
	for child in choices_container.get_children():
		if child is Button:
			choice_buttons.append(child)
			child.connect("pressed", Callable(self, "_on_choice_button_pressed").bind(child))

# Actualizar la UI con los datos del diálogo actual
func update_dialogue_ui():
	# Obtener datos del diálogo actual
	var dialogue_data = dialogue_manager.get_current_dialogue_text()
	
	# Verificar si hay datos válidos
	if dialogue_data.is_empty():
		return
	
	# Actualizar nombre del hablante
	name_label.text = dialogue_data["npc_name"] if dialogue_data["speaker"] == "npc" else "El Portador"
	
	# Actualizar retrato
	if dialogue_data["speaker"] == "npc":
		# Obtener el personaje y la emoción
		var character = dialogue_data["npc_name"].to_lower()
		var emotion = dialogue_data["emotion"]
		
		# Verificar si existe el retrato
		if character_portraits.has(character) and character_portraits[character].has(emotion):
			portrait.texture = character_portraits[character][emotion]
			portrait.visible = true
		else:
			portrait.visible = false
	else:
		# No mostrar retrato para el jugador
		portrait.visible = false
	
	# Actualizar texto
	dialogue_text.add_text(dialogue_data["text"], dialogue_data["npc_name"].to_lower() if dialogue_data["speaker"] == "npc" else "player")
	
	# Mostrar opciones si existen
	if not dialogue_data["choices"].is_empty():
		# Ocultar indicador de continuar
		continue_indicator.visible = false
		
		# Configurar opciones
		for i in range(choice_buttons.size()):
			if i < dialogue_data["choices"].size():
				choice_buttons[i].text = dialogue_data["choices"][i]
				choice_buttons[i].visible = true
			else:
				choice_buttons[i].visible = false
		
		# Mostrar contenedor de opciones cuando se complete el texto
		dialogue_text.connect("text_completed", Callable(self, "_show_choices"), CONNECT_ONE_SHOT)
	else:
		# Mostrar indicador de continuar cuando se complete el texto
		dialogue_text.connect("text_completed", Callable(self, "_show_continue_indicator"), CONNECT_ONE_SHOT)

# Mostrar el contenedor de opciones
func _show_choices():
	choices_container.visible = true
	is_choice_active = true

# Mostrar el indicador de continuar
func _show_continue_indicator():
	continue_indicator.visible = true

# Callbacks para señales
func _on_dialogue_started(dialogue_id):
	# Guardar ID del diálogo actual
	current_dialogue_id = dialogue_id
	
	# Mostrar el diálogo
	dialogue_box.visible = true
	
	# Actualizar la UI
	update_dialogue_ui()

func _on_dialogue_ended(dialogue_id):
	# Limpiar y ocultar
	dialogue_text.clear_text_queue()
	dialogue_box.visible = false
	choices_container.visible = false
	continue_indicator.visible = false
	is_choice_active = false
	current_dialogue_id = ""

func _on_choice_button_pressed(button):
	# Obtener índice de la opción
	var choice_index = choice_buttons.find(button)
	
	# Verificar que sea válido
	if choice_index == -1 or not is_choice_active:
		return
	
	# Ocultar opciones
	choices_container.visible = false
	is_choice_active = false
	
	# Seleccionar opción en el DialogueManager
	if dialogue_manager.select_dialogue_choice(choice_index):
		# Actualizar la UI con la nueva entrada
		update_dialogue_ui()

# Procesar entrada
func _input(event):
	# Verificar si se presiona la tecla de acción "ui_accept"
	if event.is_action_pressed("ui_accept") and dialogue_box.visible and not is_choice_active:
		# Si el texto aún se está mostrando, mostrarlo completo
		if not dialogue_text.is_text_displaying:
			# Avanzar al siguiente diálogo
			if dialogue_manager.advance_dialogue():
				# Actualizar la UI
				update_dialogue_ui()
				
				# Consumir el evento
				get_viewport().set_input_as_handled()
		else:
			# Mostrar todo el texto inmediatamente
			dialogue_text.skip_text_animation()
			
			# Consumir el evento
			get_viewport().set_input_as_handled()