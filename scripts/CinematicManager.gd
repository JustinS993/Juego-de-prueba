extends Node

# Señales
signal cinematic_started(cinematic_id)
signal cinematic_ended(cinematic_id)
signal cinematic_choice_made(cinematic_id, choice_index)

# Enumeración para los tipos de cinemáticas
enum CinematicType {
	INTRO,           # Introducción del juego
	STORY,           # Eventos principales de la historia
	VISION,          # Visiones o sueños del protagonista
	FLASHBACK,       # Recuerdos del pasado
	FACTION_EVENT,   # Eventos relacionados con facciones
	ENDING           # Finales del juego
}

# Estructura de una cinemática
class Cinematic:
	var id: String
	var title: String
	var type: int
	var scenes: Array
	var conditions: Dictionary
	var actions: Array
	var choices: Array
	var has_played: bool = false
	
	func _init(p_id: String, p_title: String, p_type: int):
		id = p_id
		title = p_title
		type = p_type
		scenes = []
		conditions = {}
		actions = []
		choices = []

# Estructura de una escena de cinemática
class CinematicScene:
	var background: String
	var characters: Array
	var text: String
	var narration: bool
	var music: String
	var sound_effects: Array
	var duration: float
	var camera_effects: Dictionary
	var particle_effects: Array
	
	func _init(p_background: String, p_text: String, p_narration: bool = true):
		background = p_background
		text = p_text
		narration = p_narration
		characters = []
		sound_effects = []
		camera_effects = {}
		particle_effects = []
		duration = 3.0
		music = ""

# Variables para gestionar las cinemáticas
var cinematics = {}
var current_cinematic = null
var current_scene_index = 0
var cinematic_history = []

# Cargar cinemáticas predefinidas
func _ready():
	load_cinematics()

# Cargar todas las cinemáticas del juego
func load_cinematics():
	# Cinemática de introducción
	var intro = Cinematic.new("intro", "Despertar en la Oscuridad", CinematicType.INTRO)
	
	# Escenas de la introducción
	var scene1 = CinematicScene.new("res://assets/cinematics/lab_destroyed.png", 
		"La oscuridad te envuelve. Fragmentos de recuerdos flotan como cenizas en tu mente. Una explosión. Gritos. Y luego... nada.")
	scene1.duration = 5.0
	scene1.music = "res://assets/music/intro_theme.ogg"
	scene1.camera_effects = {"type": "fade_in", "duration": 3.0}
	
	var scene2 = CinematicScene.new("res://assets/cinematics/player_mark.png", 
		"Tus ojos se abren lentamente. Una luz azulada emana de tu piel. Una marca. No estaba ahí antes... ¿o sí?")
	scene2.duration = 4.0
	scene2.camera_effects = {"type": "focus", "target": "mark"}
	scene2.particle_effects = [{"type": "glow", "color": "blue", "intensity": 0.7}]
	
	var scene3 = CinematicScene.new("res://assets/cinematics/lab_exit.png", 
		"El laboratorio está en ruinas. Equipos destrozados. Cuerpos... No puedes recordar quiénes eran. Pero la salida está ahí, llamándote.")
	scene3.duration = 4.5
	scene3.sound_effects = [{"name": "alarm", "volume": -10, "position": 1.0}]
	
	# Añadir escenas a la cinemática
	intro.scenes = [scene1, scene2, scene3]
	
	# Acciones que se ejecutarán al finalizar la cinemática
	intro.actions = [
		{"type": "set_flag", "flag": "intro_completed", "value": true},
		{"type": "add_quest", "quest_id": "escape_lab"}
	]
	
	# Añadir la cinemática a la colección
	cinematics["intro"] = intro
	
	# Cinemática de visión de La Semilla
	var seed_vision = Cinematic.new("seed_vision", "Ecos de La Semilla", CinematicType.VISION)
	
	# Escenas de la visión
	var vision1 = CinematicScene.new("res://assets/cinematics/seed_core.png", 
		"Una voz resuena en tu cabeza. No son palabras, sino impresiones. Imágenes de un mundo verde y próspero. Luego, destrucción. Fuego. Radiación.")
	vision1.duration = 5.0
	vision1.music = "res://assets/music/vision_theme.ogg"
	vision1.camera_effects = {"type": "distortion", "intensity": 0.3}
	vision1.particle_effects = [{"type": "particles", "texture": "data", "amount": 50}]
	
	var vision2 = CinematicScene.new("res://assets/cinematics/seed_fragments.png", 
		"La ves. La Semilla. Una inteligencia creada para sanar, fragmentada en el desastre. Tú tienes un fragmento. Otros buscan los demás. El núcleo espera en el Cráter.")
	vision2.duration = 5.0
	vision2.camera_effects = {"type": "pulse", "frequency": 0.5}
	
	var vision3 = CinematicScene.new("res://assets/cinematics/three_paths.png", 
		"Tres caminos se abren ante ti: Restaurar el mundo a su antigua gloria. Forjar un nuevo orden bajo tu control. O terminar con todo, para siempre.")
	vision3.duration = 6.0
	vision3.camera_effects = {"type": "split", "parts": 3}
	
	# Añadir escenas a la cinemática
	seed_vision.scenes = [vision1, vision2, vision3]
	
	# Condiciones para que se active esta cinemática
	seed_vision.conditions = {"has_reached_desierto": true}
	
	# Acciones que se ejecutarán al finalizar la cinemática
	seed_vision.actions = [
		{"type": "set_flag", "flag": "had_first_vision", "value": true},
		{"type": "add_skill_point", "branch": "mutacion", "amount": 1}
	]
	
	# Añadir la cinemática a la colección
	cinematics["seed_vision"] = seed_vision
	
	# Cinemática de encuentro con La Hegemonía
	var hegemonia_encounter = Cinematic.new("hegemonia_encounter", "El Puño de Hierro", CinematicType.FACTION_EVENT)
	
	# Escenas del encuentro
	var hegemonia1 = CinematicScene.new("res://assets/cinematics/hegemonia_patrol.png", 
		"Una patrulla de La Hegemonía bloquea el camino. Armaduras pulidas, armas de energía. El símbolo del puño cerrado brilla en sus hombreras.")
	hegemonia1.duration = 4.0
	hegemonia1.music = "res://assets/music/tension_theme.ogg"
	
	var hegemonia2 = CinematicScene.new("res://assets/cinematics/commander_vex.png", 
		"El Comandante Vex da un paso al frente. Sus ojos cibernéticos escanean tu cuerpo, deteniéndose en la marca brillante. 'Tú... tienes algo que nos pertenece.'")
	hegemonia2.duration = 5.0
	hegemonia2.narration = false
	hegemonia2.characters = [{"name": "Comandante Vex", "position": "center", "emotion": "suspicious"}]
	
	# Añadir escenas a la cinemática
	hegemonia_encounter.scenes = [hegemonia1, hegemonia2]
	
	# Condiciones para que se active esta cinemática
	hegemonia_encounter.conditions = {"entering_sector_helios": true, "hegemonia_reputation": {"max": 20}}
	
	# Opciones de elección para el jugador
	hegemonia_encounter.choices = [
		{
			"text": "Intentar razonar con ellos",
			"actions": [
				{"type": "start_dialogue", "dialogue_id": "vex_negotiation"},
				{"type": "change_reputation", "faction": "hegemonia", "value": 10}
			]
		},
		{
			"text": "Prepararse para luchar",
			"actions": [
				{"type": "start_combat", "encounter_id": "hegemonia_patrol"},
				{"type": "change_reputation", "faction": "hegemonia", "value": -20}
			]
		},
		{
			"text": "Intentar huir",
			"conditions": {"player_agility": {"min": 3}},
			"actions": [
				{"type": "skill_check", "skill": "agility", "difficulty": 7, 
				 "success": [{"type": "set_flag", "flag": "escaped_hegemonia", "value": true}],
				 "failure": [{"type": "start_combat", "encounter_id": "hegemonia_patrol_advantage"}]
				}
			]
		}
	]
	
	# Añadir la cinemática a la colección
	cinematics["hegemonia_encounter"] = hegemonia_encounter

# Iniciar una cinemática por su ID
func start_cinematic(cinematic_id: String) -> bool:
	if not cinematics.has(cinematic_id):
		print("Error: Cinemática no encontrada: " + cinematic_id)
		return false
	
	# Verificar condiciones si existen
	var cinematic = cinematics[cinematic_id]
	if not cinematic.conditions.empty() and not check_conditions(cinematic.conditions):
		print("Condiciones no cumplidas para la cinemática: " + cinematic_id)
		return false
	
	# Cambiar al estado de cinemática
	GameManager.change_game_state(GameManager.GameState.CINEMATIC)
	
	# Configurar la cinemática actual
	current_cinematic = cinematic
	current_scene_index = 0
	
	# Emitir señal de inicio
	emit_signal("cinematic_started", cinematic_id)
	
	# Mostrar la primera escena
	return show_next_scene()

# Mostrar la siguiente escena de la cinemática actual
func show_next_scene() -> bool:
	if current_cinematic == null or current_scene_index >= current_cinematic.scenes.size():
		end_cinematic()
		return false
	
	# Obtener la escena actual
	var scene = current_cinematic.scenes[current_scene_index]
	
	# Enviar la información de la escena a CinematicUI
	var scene_data = {
		"background": scene.background,
		"text": scene.text,
		"narration": scene.narration,
		"characters": scene.characters,
		"music": scene.music,
		"sound_effects": scene.sound_effects,
		"duration": scene.duration,
		"camera_effects": scene.camera_effects,
		"particle_effects": scene.particle_effects
	}
	
	# Emitir señal para que CinematicUI muestre la escena
	get_tree().call_group("cinematic_ui", "show_scene", scene_data)
	
	# Incrementar el índice para la próxima escena
	current_scene_index += 1
	
	return true

# Finalizar la cinemática actual
func end_cinematic() -> void:
	if current_cinematic == null:
		return
	
	# Guardar el ID antes de limpiar
	var cinematic_id = current_cinematic.id
	
	# Marcar como reproducida
	current_cinematic.has_played = true
	
	# Ejecutar acciones si existen
	if not current_cinematic.actions.empty():
		execute_actions(current_cinematic.actions)
	
	# Mostrar opciones si existen
	if not current_cinematic.choices.empty():
		show_cinematic_choices()
		return
	
	# Limpiar la cinemática actual
	current_cinematic = null
	current_scene_index = 0
	
	# Cambiar al estado anterior
	GameManager.restore_previous_game_state()
	
	# Emitir señal de finalización
	emit_signal("cinematic_ended", cinematic_id)

# Mostrar opciones de elección al final de la cinemática
func show_cinematic_choices() -> void:
	if current_cinematic == null or current_cinematic.choices.empty():
		return
	
	# Filtrar opciones basadas en condiciones
	var valid_choices = []
	for choice in current_cinematic.choices:
		if not choice.has("conditions") or check_conditions(choice["conditions"]):
			valid_choices.append(choice)
	
	# Enviar las opciones a CinematicUI
	get_tree().call_group("cinematic_ui", "show_choices", valid_choices)

# Seleccionar una opción de elección
func select_cinematic_choice(choice_index: int) -> void:
	if current_cinematic == null or choice_index < 0 or choice_index >= current_cinematic.choices.size():
		return
	
	# Obtener la opción seleccionada
	var choice = current_cinematic.choices[choice_index]
	
	# Verificar condiciones de la opción
	if choice.has("conditions") and not check_conditions(choice["conditions"]):
		return
	
	# Ejecutar acciones de la opción
	if choice.has("actions"):
		execute_actions(choice["actions"])
	
	# Guardar el ID antes de limpiar
	var cinematic_id = current_cinematic.id
	
	# Emitir señal de elección
	emit_signal("cinematic_choice_made", cinematic_id, choice_index)
	
	# Limpiar la cinemática actual
	current_cinematic = null
	current_scene_index = 0
	
	# Cambiar al estado anterior
	GameManager.restore_previous_game_state()
	
	# Emitir señal de finalización
	emit_signal("cinematic_ended", cinematic_id)

# Verificar condiciones
func check_conditions(conditions: Dictionary) -> bool:
	for key in conditions:
		var condition = conditions[key]
		
		# Condición de bandera
		if condition is bool:
			if GameManager.check_story_flag(key) != condition:
				return false
		
		# Condición de rango (min/max)
		elif condition is Dictionary:
			var value = 0
			
			# Verificar reputación de facción
			if key.ends_with("_reputation"):
				var faction = key.replace("_reputation", "")
				value = GameManager.get_faction_reputation(faction)
			
			# Verificar estadística del jugador
			elif key.begins_with("player_"):
				var stat = key.replace("player_", "")
				value = GameManager.get_player_stat(stat)
			
			# Verificar valor mínimo
			if condition.has("min") and value < condition["min"]:
				return false
			
			# Verificar valor máximo
			if condition.has("max") and value > condition["max"]:
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
			"add_quest":
				GameManager.add_quest(action["quest_id"])
			"add_skill_point":
				GameManager.add_skill_point(action["branch"], action["amount"] if action.has("amount") else 1)
			"start_dialogue":
				DialogueManager.start_dialogue(action["dialogue_id"])
			"start_combat":
				CombatManager.start_combat(action["encounter_id"])
			"skill_check":
				perform_skill_check(action)

# Realizar una prueba de habilidad
func perform_skill_check(action: Dictionary) -> void:
	var skill = action["skill"]
	var difficulty = action["difficulty"]
	var player_skill = GameManager.get_player_stat(skill)
	
	# Generar un número aleatorio entre 1 y 10
	var roll = randi() % 10 + 1
	
	# Sumar la habilidad del jugador al resultado
	var total = roll + player_skill
	
	# Determinar si la prueba es exitosa
	var success = total >= difficulty
	
	# Ejecutar las acciones correspondientes
	if success and action.has("success"):
		execute_actions(action["success"])
	elif not success and action.has("failure"):
		execute_actions(action["failure"])

# Verificar si hay cinemáticas disponibles para reproducir automáticamente
func check_auto_cinematics() -> void:
	for id in cinematics:
		var cinematic = cinematics[id]
		
		# Verificar si ya se ha reproducido
		if cinematic.has_played:
			continue
		
		# Verificar condiciones
		if cinematic.conditions.empty() or check_conditions(cinematic.conditions):
			start_cinematic(id)
			break