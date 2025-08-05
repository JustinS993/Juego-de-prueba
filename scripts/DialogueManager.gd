extends Node

# Estructura de diálogo
# Un diálogo es un diccionario con la siguiente estructura:
# {
#   "id": "dialogo_unico_id",
#   "npc_name": "Nombre del NPC",
#   "portrait": "ruta/al/retrato.png",
#   "entries": [
#     {
#       "text": "Texto del diálogo",
#       "speaker": "npc" o "player",
#       "emotion": "neutral", "happy", "sad", etc.,
#       "conditions": {"flag_name": valor, ...},
#       "actions": [{"type": "set_flag", "flag": "nombre", "value": valor}, ...],
#       "choices": [
#         {
#           "text": "Opción de respuesta",
#           "next_entry": índice o "end",
#           "conditions": {"flag_name": valor, ...},
#           "actions": [{"type": "set_flag", "flag": "nombre", "value": valor}, ...]
#         },
#         ...
#       ]
#     },
#     ...
#   ]
# }

# Señales
signal dialogue_started(dialogue_id)
signal dialogue_ended(dialogue_id)
signal dialogue_choice_made(dialogue_id, choice_index)

# Variables
var current_dialogue: Dictionary = {}
var current_entry_index: int = 0
var dialogue_history: Array = []
var dialogue_library: Dictionary = {}

# Función de inicialización
func _ready() -> void:
	# Cargar diálogos predefinidos
	load_dialogue_library()

# Cargar la biblioteca de diálogos
func load_dialogue_library() -> void:
	# En una implementación real, esto cargaría los diálogos desde archivos JSON o similar
	# Por ahora, definimos algunos diálogos de ejemplo directamente en el código
	
	# Diálogo con Kaelen (Soldado Exiliado)
	dialogue_library["kaelen_first_meeting"] = {
		"id": "kaelen_first_meeting",
		"npc_name": "Kaelen",
		"portrait": "res://assets/sprites/portraits/kaelen.png",
		"entries": [
			{
				"text": "Alto ahí. No des un paso más si valoras tu vida.",
				"speaker": "npc",
				"emotion": "hostile",
				"choices": [
					{
						"text": "No busco problemas, solo estoy explorando.",
						"next_entry": 1
					},
					{
						"text": "¿Quién eres tú para darme órdenes?",
						"next_entry": 2
					},
					{
						"text": "[Preparar arma] Retrocede o lo lamentarás.",
						"next_entry": 3,
						"conditions": {"has_weapon": true}
					}
				]
			},
			{
				"text": "Hmm... Explorando, ¿eh? Nadie 'explora' estas ruinas a menos que busque algo valioso... o peligroso.",
				"speaker": "npc",
				"emotion": "suspicious",
				"next_entry": 4
			},
			{
				"text": "Alguien que ha visto demasiados como tú venir y no regresar. Este lugar está prohibido por una razón.",
				"speaker": "npc",
				"emotion": "angry",
				"next_entry": 4
			},
			{
				"text": "[Baja su arma lentamente] Interesante... La mayoría huye o suplica. Tienes agallas, lo reconozco.",
				"speaker": "npc",
				"emotion": "impressed",
				"actions": [{"type": "change_reputation", "faction": "hegemonia", "value": 5}],
				"next_entry": 4
			},
			{
				"text": "Soy Kaelen, ex-comandante de la Hegemonía. Ahora solo un vigilante de estas ruinas. Y tú... tienes la marca, ¿verdad?",
				"speaker": "npc",
				"emotion": "neutral",
				"actions": [{"type": "set_flag", "flag": "met_kaelen", "value": true}],
				"choices": [
					{
						"text": "¿Qué sabes sobre esta marca?",
						"next_entry": 5
					},
					{
						"text": "¿Por qué dejaste la Hegemonía?",
						"next_entry": 6
					},
					{
						"text": "No tengo tiempo para charlas. Necesito seguir adelante.",
						"next_entry": "end"
					}
				]
			},
			{
				"text": "Es un fragmento de La Semilla. Una tecnología antigua, poderosa... y maldita. Cambia a quienes la portan, les da poder pero también... propósito. Un propósito que no siempre es suyo.",
				"speaker": "npc",
				"emotion": "concerned",
				"next_entry": 7
			},
			{
				"text": "[Su mirada se endurece] Digamos que vi el verdadero rostro de mis superiores. Lo que planean hacer con La Semilla... no puedo ser parte de eso.",
				"speaker": "npc",
				"emotion": "bitter",
				"next_entry": 7
			},
			{
				"text": "Escucha, no sé qué te trajo aquí o qué planeas hacer, pero te daré un consejo: ten cuidado con las facciones. Todas quieren usar tu poder para sus propios fines.",
				"speaker": "npc",
				"emotion": "serious",
				"choices": [
					{
						"text": "¿Puedes ayudarme a entender este poder?",
						"next_entry": 8
					},
					{
						"text": "¿Qué me recomiendas hacer?",
						"next_entry": 9
					},
					{
						"text": "Gracias por la advertencia. Debo irme ahora.",
						"next_entry": "end",
						"actions": [{"type": "set_flag", "flag": "kaelen_alliance_potential", "value": true}]
					}
				]
			},
			{
				"text": "Puedo enseñarte algunas técnicas de combate que aprendí en la Hegemonía. Te servirán para defenderte. A cambio, solo te pido que consideres cuidadosamente tus alianzas futuras.",
				"speaker": "npc",
				"emotion": "helpful",
				"actions": [
					{"type": "set_flag", "flag": "kaelen_training_available", "value": true},
					{"type": "add_quest", "quest_id": "kaelen_combat_training"}
				],
				"next_entry": "end"
			},
			{
				"text": "Busca tu propio camino. No dejes que La Semilla o las facciones te controlen. Y si necesitas un aliado... bueno, estaré por aquí. Quizás podamos ayudarnos mutuamente.",
				"speaker": "npc",
				"emotion": "friendly",
				"actions": [
					{"type": "set_flag", "flag": "kaelen_alliance_offered", "value": true},
					{"type": "change_reputation", "faction": "hegemonia", "value": 10}
				],
				"next_entry": "end"
			}
		]
	}
	
	# Diálogo con Sira (Líder de los Errantes)
	dialogue_library["sira_first_meeting"] = {
		"id": "sira_first_meeting",
		"npc_name": "Sira",
		"portrait": "res://assets/sprites/portraits/sira.png",
		"entries": [
			{
				"text": "[Te observa atentamente] La marca en tu piel... brilla como las estrellas que guían a mi pueblo. Eres el Portador del que hablan las visiones.",
				"speaker": "npc",
				"emotion": "curious",
				"choices": [
					{
						"text": "¿Qué visiones? ¿Quién eres?",
						"next_entry": 1
					},
					{
						"text": "No sé de qué hablas. Solo busco respuestas sobre esta marca.",
						"next_entry": 2
					},
					{
						"text": "[Ocultar la marca] Debes confundirme con alguien más.",
						"next_entry": 3
					}
				]
			},
			{
				"text": "Soy Sira, líder de los Errantes. Nuestros videntes han soñado con tu llegada durante generaciones. La marca que llevas es parte de La Semilla, el poder que transformó nuestro mundo.",
				"speaker": "npc",
				"emotion": "reverent",
				"next_entry": 4
			},
			{
				"text": "Las respuestas y la marca están entrelazadas, Portador. Soy Sira, líder de los Errantes, y hemos esperado a alguien como tú. Alguien que pueda decidir el destino de lo que queda de nuestro mundo.",
				"speaker": "npc",
				"emotion": "wise",
				"next_entry": 4
			},
			{
				"text": "[Sonríe] La marca no puede ocultarse de quienes saben verla, Portador. Su energía resuena con las tormentas del desierto. Pero respeto tu cautela. En estos tiempos, la confianza es un lujo.",
				"speaker": "npc",
				"emotion": "amused",
				"next_entry": 4
			},
			{
				"text": "Mi pueblo ha sobrevivido en el Desierto Carmesí desde el Gran Colapso. Hemos aprendido a leer sus tormentas, a encontrar agua donde otros ven solo muerte. Y ahora, te hemos encontrado a ti.",
				"speaker": "npc",
				"emotion": "proud",
				"actions": [{"type": "set_flag", "flag": "met_sira", "value": true}],
				"choices": [
					{
						"text": "¿Qué quieres de mí?",
						"next_entry": 5
					},
					{
						"text": "Háblame más sobre La Semilla.",
						"next_entry": 6
					},
					{
						"text": "No estoy interesado en profecías o destinos.",
						"next_entry": 7
					}
				]
			},
			{
				"text": "No queremos nada que no estés dispuesto a dar. Pero ofrecemos una alianza. Los Errantes pueden guiarte a través del desierto, mostrarte secretos que otros han olvidado. A cambio, pedimos que consideres nuestro futuro cuando llegue el momento de tu decisión.",
				"speaker": "npc",
				"emotion": "sincere",
				"next_entry": 8
			},
			{
				"text": "La Semilla era una inteligencia creada para sanar el mundo. Pero algo salió mal. Se fragmentó, y sus piezas se dispersaron. La marca en tu piel es uno de esos fragmentos, quizás el más importante. Tiene el poder de comunicarse con el núcleo.",
				"speaker": "npc",
				"emotion": "educational",
				"next_entry": 8
			},
			{
				"text": "[Ríe suavemente] El destino nos encuentra a todos, lo aceptemos o no. Pero respeto tu camino. Solo recuerda que cuando las tormentas del desierto te rodeen, los Errantes estarán dispuestos a ofrecer refugio.",
				"speaker": "npc",
				"emotion": "understanding",
				"next_entry": 8
			},
			{
				"text": "Hay otros que buscan La Semilla. La Hegemonía quiere su poder para controlar lo que queda de la humanidad. Los Restauradores creen que puede revivir el viejo mundo. Y los Nihil... ellos desean usarla para terminar con todo.",
				"speaker": "npc",
				"emotion": "concerned",
				"choices": [
					{
						"text": "¿Y qué quieren los Errantes?",
						"next_entry": 9
					},
					{
						"text": "¿Cómo puedo confiar en ti?",
						"next_entry": 10
					},
					{
						"text": "Necesito tiempo para pensar en todo esto.",
						"next_entry": 11
					}
				]
			},
			{
				"text": "Queremos adaptación, no control ni restauración ni destrucción. El viejo mundo se fue, y el nuevo es duro pero hermoso a su manera. Buscamos un equilibrio donde la humanidad pueda prosperar sin repetir los errores del pasado.",
				"speaker": "npc",
				"emotion": "passionate",
				"actions": [{"type": "change_reputation", "faction": "restauradores", "value": 15}],
				"next_entry": 12
			},
			{
				"text": "No pido tu confianza inmediata, Portador. Las palabras son viento. Juzga por acciones. Permíteme ofrecerte un regalo: un mapa del Desierto Carmesí y un amuleto que te protegerá de sus tormentas más leves.",
				"speaker": "npc",
				"emotion": "offering",
				"actions": [
					{"type": "add_item", "item_id": "desert_map", "quantity": 1},
					{"type": "add_item", "item_id": "storm_amulet", "quantity": 1}
				],
				"next_entry": 12
			},
			{
				"text": "Por supuesto. El camino del Portador no es sencillo. Cuando estés listo, búscame en nuestro campamento principal al este. Hasta entonces, que las tormentas te eviten, viajero.",
				"speaker": "npc",
				"emotion": "respectful",
				"actions": [{"type": "set_flag", "flag": "sira_camp_available", "value": true}],
				"next_entry": "end"
			},
			{
				"text": "Si decides visitar nuestro campamento, serás bienvenido. Tenemos recursos, conocimiento y quizás algunas habilidades que podrían interesarte. El desierto es implacable con los solitarios, Portador.",
				"speaker": "npc",
				"emotion": "inviting",
				"actions": [
					{"type": "set_flag", "flag": "sira_alliance_potential", "value": true},
					{"type": "add_quest", "quest_id": "find_errantes_camp"}
				],
				"next_entry": "end"
			}
		]
	}

# Iniciar un diálogo
func start_dialogue(dialogue_id: String) -> bool:
	if not dialogue_library.has(dialogue_id):
		print("Error: Diálogo no encontrado: " + dialogue_id)
		return false
	
	# Cambiar al estado de diálogo
	GameManager.change_game_state(GameManager.GameState.DIALOGUE)
	
	# Configurar el diálogo actual
	current_dialogue = dialogue_library[dialogue_id].duplicate(true)
	current_entry_index = 0
	
	# Emitir señal de inicio
	emit_signal("dialogue_started", dialogue_id)
	
	# Mostrar la primera entrada
	return advance_dialogue()

# Avanzar al siguiente diálogo
func advance_dialogue() -> bool:
	if current_dialogue.empty() or current_entry_index == "end":
		end_dialogue()
		return false
	
	# Obtener la entrada actual
	var entry = current_dialogue["entries"][current_entry_index]
	
	# Verificar condiciones si existen
	if entry.has("conditions") and not check_conditions(entry["conditions"]):
		# Si no se cumplen las condiciones, intentar encontrar una alternativa
		var alternative_found = false
		for i in range(current_dialogue["entries"].size()):
			var alt_entry = current_dialogue["entries"][i]
			if alt_entry.has("alternative_to") and alt_entry["alternative_to"] == current_entry_index:
				if not alt_entry.has("conditions") or check_conditions(alt_entry["conditions"]):
					current_entry_index = i
					alternative_found = true
					break
		
		# Si no hay alternativa, terminar el diálogo
		if not alternative_found:
			end_dialogue()
			return false
		
		# Obtener la nueva entrada
		entry = current_dialogue["entries"][current_entry_index]
	
	# Ejecutar acciones si existen
	if entry.has("actions"):
		execute_actions(entry["actions"])
	
	# Añadir a la historia
	dialogue_history.append({
		"dialogue_id": current_dialogue["id"],
		"entry_index": current_entry_index,
		"text": entry["text"],
		"speaker": entry["speaker"]
	})
	
	# Actualizar el índice para la próxima entrada si está definido
	if entry.has("next_entry"):
		current_entry_index = entry["next_entry"]
	
	return true

# Seleccionar una opción de diálogo
func select_dialogue_choice(choice_index: int) -> bool:
	if current_dialogue.empty() or current_entry_index == "end":
		return false
	
	# Obtener la entrada actual
	var entry = current_dialogue["entries"][current_entry_index]
	
	# Verificar que la entrada tenga opciones y que el índice sea válido
	if not entry.has("choices") or choice_index < 0 or choice_index >= entry["choices"].size():
		return false
	
	# Obtener la opción seleccionada
	var choice = entry["choices"][choice_index]
	
	# Verificar condiciones de la opción si existen
	if choice.has("conditions") and not check_conditions(choice["conditions"]):
		return false
	
	# Ejecutar acciones de la opción si existen
	if choice.has("actions"):
		execute_actions(choice["actions"])
	
	# Añadir a la historia
	dialogue_history.append({
		"dialogue_id": current_dialogue["id"],
		"entry_index": current_entry_index,
		"choice_index": choice_index,
		"text": choice["text"],
		"speaker": "player"
	})
	
	# Emitir señal de elección
	emit_signal("dialogue_choice_made", current_dialogue["id"], choice_index)
	
	# Actualizar el índice para la próxima entrada
	if choice.has("next_entry"):
		current_entry_index = choice["next_entry"]
		
		# Si el siguiente es "end", terminar el diálogo
		if current_entry_index == "end":
			end_dialogue()
			return true
		
		# Avanzar automáticamente al siguiente diálogo
		return advance_dialogue()
	
	return false

# Terminar el diálogo actual
func end_dialogue() -> void:
	# Guardar el ID antes de limpiar
	var dialogue_id = current_dialogue["id"] if not current_dialogue.empty() else ""
	
	# Limpiar el diálogo actual
	current_dialogue = {}
	current_entry_index = 0
	
	# Cambiar al estado de exploración
	GameManager.change_game_state(GameManager.GameState.EXPLORATION)
	
	# Emitir señal de finalización
	emit_signal("dialogue_ended", dialogue_id)

# Verificar condiciones
func check_conditions(conditions: Dictionary) -> bool:
	for flag_name in conditions:
		var expected_value = conditions[flag_name]
		var actual_value = GameManager.check_story_flag(flag_name)
		
		# Caso especial para verificar si tiene un objeto
		if flag_name == "has_item":
			# TODO: Implementar verificación de inventario
			pass
		# Caso especial para verificar si tiene un arma equipada
		elif flag_name == "has_weapon":
			if GameManager.player_data["equipment"]["weapon"] == null:
				return false
		# Verificación normal de banderas
		elif actual_value != expected_value:
			return false
	
	return true

# Ejecutar acciones
func execute_actions(actions: Array) -> void:
	for action in actions:
		match action["type"]:
			"set_flag":
				GameManager.set_story_flag(action["flag"], action["value"])
			"change_reputation":
				GameManager.change_reputation(action["faction"], action["value"])
			"add_item":
				GameManager.add_to_inventory(action["item_id"], action["quantity"] if action.has("quantity") else 1)
			"remove_item":
				# TODO: Implementar remoción de inventario
				pass
			"add_quest":
				# TODO: Implementar sistema de misiones
				pass
			"complete_quest":
				# TODO: Implementar sistema de misiones
				pass
			"add_skill":
				GameManager.add_skill(action["skill_branch"], action["skill_id"])
			"heal_player":
				GameManager.modify_player_stat("health", action["amount"])
			"damage_player":
				GameManager.modify_player_stat("health", -action["amount"])
			"change_scene":
				# TODO: Implementar cambio de escena
				pass

# Obtener el texto actual para mostrar
func get_current_dialogue_text() -> Dictionary:
	if current_dialogue.empty() or current_entry_index == "end":
		return {}
	
	var entry = current_dialogue["entries"][current_entry_index]
	var result = {
		"npc_name": current_dialogue["npc_name"],
		"portrait": current_dialogue["portrait"],
		"text": entry["text"],
		"speaker": entry["speaker"],
		"emotion": entry["emotion"] if entry.has("emotion") else "neutral",
		"choices": []
	}
	
	# Añadir opciones si existen
	if entry.has("choices"):
		for choice in entry["choices"]:
			# Verificar condiciones de la opción
			if not choice.has("conditions") or check_conditions(choice["conditions"]):
				result["choices"].append(choice["text"])
	
	return result

# Crear un nuevo diálogo (útil para diálogos generados dinámicamente)
func create_dialogue(dialogue_data: Dictionary) -> String:
	# Generar un ID único
	var dialogue_id = "dynamic_" + str(Time.get_unix_time_from_system())
	
	# Asegurarse de que el diálogo tenga un ID
	dialogue_data["id"] = dialogue_id
	
	# Añadir a la biblioteca
	dialogue_library[dialogue_id] = dialogue_data
	
	return dialogue_id