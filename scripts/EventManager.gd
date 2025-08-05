extends Node

# EventManager.gd - Sistema de gestión de eventos para "Cenizas del Horizonte"
# Maneja eventos aleatorios, programados y basados en condiciones del mundo

# Señales
signal event_triggered(event_id, event_data)
signal event_completed(event_id, results)
signal event_failed(event_id, reason)
signal world_state_changed(state_id, old_value, new_value)

# Enumeraciones
enum EventType {
	RANDOM,      # Eventos aleatorios que pueden ocurrir en cualquier momento
	SCHEDULED,   # Eventos programados para ocurrir en momentos específicos
	STORY,       # Eventos relacionados con la historia principal
	FACTION,     # Eventos específicos de facciones
	LOCATION,    # Eventos específicos de ubicaciones
	WEATHER,     # Eventos climáticos
	ENCOUNTER    # Encuentros con NPCs o enemigos
}

enum EventStatus {
	INACTIVE,    # Evento no disponible aún
	AVAILABLE,   # Evento disponible para activar
	ACTIVE,      # Evento en curso
	COMPLETED,   # Evento completado
	FAILED,      # Evento fallido
	EXPIRED      # Evento expirado (ya no disponible)
}

# Variables
var events: Dictionary = {}
var active_events: Dictionary = {}
var completed_events: Array = []
var failed_events: Array = []
var world_state: Dictionary = {}
var event_cooldowns: Dictionary = {}
var random_event_timer: Timer
var weather_event_timer: Timer

# Constantes
const MIN_RANDOM_EVENT_TIME: int = 300  # 5 minutos en segundos
const MAX_RANDOM_EVENT_TIME: int = 900  # 15 minutos en segundos
const WEATHER_CHANGE_MIN_TIME: int = 600  # 10 minutos en segundos
const WEATHER_CHANGE_MAX_TIME: int = 1800  # 30 minutos en segundos

# Función de inicialización
func _ready() -> void:
	# Inicializar temporizadores
	random_event_timer = Timer.new()
	random_event_timer.one_shot = true
	random_event_timer.connect("timeout", self, "_on_random_event_timer_timeout")
	add_child(random_event_timer)
	
	weather_event_timer = Timer.new()
	weather_event_timer.one_shot = true
	weather_event_timer.connect("timeout", self, "_on_weather_event_timer_timeout")
	add_child(weather_event_timer)
	
	# Inicializar estado del mundo
	initialize_world_state()
	
	# Cargar eventos predefinidos
	load_predefined_events()
	
	# Iniciar temporizadores
	start_random_event_timer()
	start_weather_event_timer()

# Inicializar estado del mundo
func initialize_world_state() -> void:
	# Estado general del mundo
	world_state["current_day"] = 1
	world_state["current_time"] = 8.0  # Hora del día (8:00 AM)
	world_state["current_weather"] = "clear"  # Clima actual
	world_state["radiation_level"] = 0.2  # Nivel de radiación (0.0 a 1.0)
	
	# Estado de zonas
	world_state["zone_danger_levels"] = {
		"ruinas_drossal": 1,
		"desierto_carmesi": 2,
		"bosque_putrefacto": 3,
		"sector_helios_07": 4,
		"el_crater": 5
	}
	
	# Estado de recursos mundiales
	world_state["resource_scarcity"] = {
		"water": 0.7,  # Escasez de agua (0.0 a 1.0)
		"food": 0.5,   # Escasez de comida
		"medicine": 0.8,  # Escasez de medicinas
		"technology": 0.9  # Escasez de tecnología
	}
	
	# Estado de tensión entre facciones
	world_state["faction_tension"] = {
		"hegemonia_errantes": 0.8,  # Alta tensión
		"restauradores_nihil": 0.9,  # Muy alta tensión
		"drossal_survivors_scrap_raiders": 0.7  # Alta tensión
	}

# Cargar eventos predefinidos
func load_predefined_events() -> void:
	# Cargar eventos de historia
	load_story_events()
	
	# Cargar eventos de facciones
	load_faction_events()
	
	# Cargar eventos aleatorios
	load_random_events()
	
	# Cargar eventos climáticos
	load_weather_events()
	
	# Cargar eventos de ubicación
	load_location_events()

# Cargar eventos de historia
func load_story_events() -> void:
	# Evento: Despertar
	register_event({
		"id": "awakening",
		"title": "Despertar en la Oscuridad",
		"description": "Te despiertas en una instalación abandonada, sin recuerdos claros de quién eres o cómo llegaste allí.",
		"type": EventType.STORY,
		"status": EventStatus.AVAILABLE,
		"location": "ruinas_drossal",
		"required_level": 1,
		"required_quests": [],
		"required_events": [],
		"required_world_state": {},
		"actions": ["start_dialogue", "add_quest"],
		"action_params": {
			"dialogue_id": "awakening_intro",
			"quest_id": "despertar_oscuridad"
		},
		"choices": [],
		"outcomes": {},
		"rewards": {},
		"next_events": ["first_contact"],
		"cooldown": 0,  # No tiene enfriamiento (evento único)
		"expiration": 0  # No expira
	})
	
	# Evento: Primer Contacto
	register_event({
		"id": "first_contact",
		"title": "Primer Contacto",
		"description": "Un extraño te contacta a través de un dispositivo en tu brazo, mencionando algo sobre 'La Semilla'.",
		"type": EventType.STORY,
		"status": EventStatus.INACTIVE,
		"location": "ruinas_drossal",
		"required_level": 1,
		"required_quests": ["despertar_oscuridad"],
		"required_events": ["awakening"],
		"required_world_state": {},
		"actions": ["start_dialogue", "add_item"],
		"action_params": {
			"dialogue_id": "mysterious_contact",
			"item_id": "comunicador_antiguo",
			"item_amount": 1
		},
		"choices": [],
		"outcomes": {},
		"rewards": {},
		"next_events": ["the_mark"],
		"cooldown": 0,
		"expiration": 0
	})

# Cargar eventos de facciones
func load_faction_events() -> void:
	# Evento: Conflicto en Drossal
	register_event({
		"id": "drossal_conflict",
		"title": "Conflicto en Drossal",
		"description": "Los Saqueadores de Chatarra están atacando a los Supervivientes de Drossal por recursos. Tu intervención podría cambiar el resultado.",
		"type": EventType.FACTION,
		"status": EventStatus.INACTIVE,
		"location": "ruinas_drossal",
		"required_level": 3,
		"required_quests": [],
		"required_events": ["awakening"],
		"required_world_state": {
			"faction_tension.drossal_survivors_scrap_raiders": {"min": 0.6}
		},
		"actions": ["start_encounter"],
		"action_params": {
			"encounter_id": "drossal_raid"
		},
		"choices": [
			{"id": "help_survivors", "text": "Ayudar a los Supervivientes", "required_reputation": {"drossal_survivors": {"min": -20}}},
			{"id": "help_raiders", "text": "Ayudar a los Saqueadores", "required_reputation": {"scrap_raiders": {"min": -20}}},
			{"id": "stay_neutral", "text": "Mantenerse neutral", "required_reputation": {}}
		],
		"outcomes": {
			"help_survivors": {
				"world_state_changes": {"faction_tension.drossal_survivors_scrap_raiders": 0.9},
				"reputation_changes": {"drossal_survivors": 20, "scrap_raiders": -30}
			},
			"help_raiders": {
				"world_state_changes": {"faction_tension.drossal_survivors_scrap_raiders": 0.9},
				"reputation_changes": {"drossal_survivors": -30, "scrap_raiders": 20}
			},
			"stay_neutral": {
				"world_state_changes": {"faction_tension.drossal_survivors_scrap_raiders": 0.8},
				"reputation_changes": {"drossal_survivors": -10, "scrap_raiders": -10}
			}
		},
		"rewards": {
			"help_survivors": {
				"experience": 300,
				"items": [{"id": "medicina_casera", "amount": 3}],
				"currency": 100
			},
			"help_raiders": {
				"experience": 300,
				"items": [{"id": "pistola_chatarra", "amount": 1}],
				"currency": 150
			},
			"stay_neutral": {
				"experience": 150,
				"items": [],
				"currency": 50
			}
		},
		"next_events": [],
		"cooldown": 604800,  # 7 días en segundos
		"expiration": 86400  # 1 día en segundos
	})

# Cargar eventos aleatorios
func load_random_events() -> void:
	# Evento: Tormenta de Arena
	register_event({
		"id": "sandstorm",
		"title": "Tormenta de Arena",
		"description": "Una violenta tormenta de arena se aproxima, reduciendo la visibilidad y dañando el equipo no protegido.",
		"type": EventType.RANDOM,
		"status": EventStatus.INACTIVE,
		"location": "desierto_carmesi",
		"required_level": 1,
		"required_quests": [],
		"required_events": [],
		"required_world_state": {
			"current_weather": {"not": "sandstorm"}
		},
		"actions": ["change_weather", "apply_effect"],
		"action_params": {
			"weather": "sandstorm",
			"effect_id": "reduced_visibility",
			"effect_duration": 300  # 5 minutos
		},
		"choices": [
			{"id": "seek_shelter", "text": "Buscar refugio", "required_reputation": {}},
			{"id": "brave_storm", "text": "Enfrentar la tormenta", "required_reputation": {}}
		],
		"outcomes": {
			"seek_shelter": {
				"world_state_changes": {},
				"reputation_changes": {}
			},
			"brave_storm": {
				"world_state_changes": {},
				"reputation_changes": {}
			}
		},
		"rewards": {
			"seek_shelter": {
				"experience": 50,
				"items": [],
				"currency": 0
			},
			"brave_storm": {
				"experience": 100,
				"items": [{"id": "componente_raro", "amount": 1, "chance": 0.3}],
				"currency": 0
			}
		},
		"next_events": [],
		"cooldown": 86400,  # 1 día en segundos
		"expiration": 1800  # 30 minutos en segundos
	})
	
	# Evento: Mercader Ambulante
	register_event({
		"id": "wandering_merchant",
		"title": "Mercader Ambulante",
		"description": "Un mercader errante ha establecido un puesto temporal cerca. Ofrece objetos raros pero a precios elevados.",
		"type": EventType.RANDOM,
		"status": EventStatus.INACTIVE,
		"location": "*",  # Puede ocurrir en cualquier ubicación
		"required_level": 1,
		"required_quests": [],
		"required_events": [],
		"required_world_state": {},
		"actions": ["spawn_npc", "start_dialogue"],
		"action_params": {
			"npc_id": "wandering_merchant",
			"dialogue_id": "merchant_greeting"
		},
		"choices": [],
		"outcomes": {},
		"rewards": {},
		"next_events": [],
		"cooldown": 172800,  # 2 días en segundos
		"expiration": 3600  # 1 hora en segundos
	})

# Cargar eventos climáticos
func load_weather_events() -> void:
	# Evento: Lluvia Ácida
	register_event({
		"id": "acid_rain",
		"title": "Lluvia Ácida",
		"description": "Nubes verdosas se forman en el cielo y comienza a caer una lluvia que quema la piel y daña el equipo.",
		"type": EventType.WEATHER,
		"status": EventStatus.INACTIVE,
		"location": "*",  # Puede ocurrir en cualquier ubicación excepto interiores
		"required_level": 1,
		"required_quests": [],
		"required_events": [],
		"required_world_state": {
			"current_weather": {"not": "acid_rain"},
			"radiation_level": {"min": 0.4}
		},
		"actions": ["change_weather", "apply_effect", "damage_equipment"],
		"action_params": {
			"weather": "acid_rain",
			"effect_id": "acid_damage",
			"effect_duration": 600,  # 10 minutos
			"equipment_damage": 5  # Porcentaje de daño al equipo
		},
		"choices": [],
		"outcomes": {},
		"rewards": {},
		"next_events": [],
		"cooldown": 259200,  # 3 días en segundos
		"expiration": 1800  # 30 minutos en segundos
	})

# Cargar eventos de ubicación
func load_location_events() -> void:
	# Evento: Anomalía Temporal
	register_event({
		"id": "time_anomaly",
		"title": "Anomalía Temporal",
		"description": "Una extraña distorsión en el espacio-tiempo aparece, mostrando fragmentos del pasado o posibles futuros.",
		"type": EventType.LOCATION,
		"status": EventStatus.INACTIVE,
		"location": "el_crater",
		"required_level": 10,
		"required_quests": [],
		"required_events": [],
		"required_world_state": {
			"radiation_level": {"min": 0.6}
		},
		"actions": ["start_dialogue", "show_vision"],
		"action_params": {
			"dialogue_id": "anomaly_vision",
			"vision_id": "future_glimpse"
		},
		"choices": [
			{"id": "interact", "text": "Interactuar con la anomalía", "required_reputation": {}},
			{"id": "avoid", "text": "Evitar la anomalía", "required_reputation": {}}
		],
		"outcomes": {
			"interact": {
				"world_state_changes": {"radiation_level": 0.7},
				"reputation_changes": {}
			},
			"avoid": {
				"world_state_changes": {},
				"reputation_changes": {}
			}
		},
		"rewards": {
			"interact": {
				"experience": 500,
				"items": [{"id": "fragmento_temporal", "amount": 1}],
				"currency": 0
			},
			"avoid": {
				"experience": 100,
				"items": [],
				"currency": 0
			}
		},
		"next_events": [],
		"cooldown": 604800,  # 7 días en segundos
		"expiration": 3600  # 1 hora en segundos
	})

# Registrar un nuevo evento
func register_event(event_data: Dictionary) -> void:
	# Verificar si el evento ya existe
	if events.has(event_data["id"]):
		push_error("Evento ya registrado: " + event_data["id"])
		return
	
	# Añadir el evento al diccionario
	events[event_data["id"]] = event_data

# Iniciar temporizador para eventos aleatorios
func start_random_event_timer() -> void:
	# Generar tiempo aleatorio
	var time = rand_range(MIN_RANDOM_EVENT_TIME, MAX_RANDOM_EVENT_TIME)
	random_event_timer.start(time)

# Iniciar temporizador para eventos climáticos
func start_weather_event_timer() -> void:
	# Generar tiempo aleatorio
	var time = rand_range(WEATHER_CHANGE_MIN_TIME, WEATHER_CHANGE_MAX_TIME)
	weather_event_timer.start(time)

# Manejador de timeout para eventos aleatorios
func _on_random_event_timer_timeout() -> void:
	# Intentar activar un evento aleatorio
	trigger_random_event()
	
	# Reiniciar el temporizador
	start_random_event_timer()

# Manejador de timeout para eventos climáticos
func _on_weather_event_timer_timeout() -> void:
	# Intentar cambiar el clima
	trigger_weather_change()
	
	# Reiniciar el temporizador
	start_weather_event_timer()

# Activar un evento aleatorio
func trigger_random_event() -> bool:
	# Obtener ubicación actual del jugador
	var current_location = get_current_location()
	
	# Filtrar eventos aleatorios disponibles para esta ubicación
	var available_events = []
	
	for event_id in events:
		var event = events[event_id]
		
		# Verificar si es un evento aleatorio
		if event["type"] != EventType.RANDOM:
			continue
		
		# Verificar si está en enfriamiento
		if event_cooldowns.has(event_id):
			continue
		
		# Verificar ubicación
		if event["location"] != "*" and event["location"] != current_location:
			continue
		
		# Verificar nivel requerido
		if event["required_level"] > get_player_level():
			continue
		
		# Verificar misiones requeridas
		if not check_required_quests(event["required_quests"]):
			continue
		
		# Verificar eventos requeridos
		if not check_required_events(event["required_events"]):
			continue
		
		# Verificar estado del mundo requerido
		if not check_required_world_state(event["required_world_state"]):
			continue
		
		# Evento disponible
		available_events.append(event_id)
	
	# Si no hay eventos disponibles, retornar falso
	if available_events.empty():
		return false
	
	# Seleccionar un evento aleatorio
	var selected_event = available_events[randi() % available_events.size()]
	
	# Activar el evento
	return trigger_event(selected_event)

# Activar un cambio de clima
func trigger_weather_change() -> bool:
	# Obtener clima actual
	var current_weather = world_state["current_weather"]
	
	# Lista de climas posibles
	var possible_weathers = ["clear", "cloudy", "rainy", "foggy"]
	
	# Añadir climas especiales según condiciones
	if world_state["radiation_level"] >= 0.4:
		possible_weathers.append("acid_rain")
	
	if get_current_location() == "desierto_carmesi":
		possible_weathers.append("sandstorm")
	
	if get_current_location() == "bosque_putrefacto":
		possible_weathers.append("toxic_mist")
	
	# Eliminar el clima actual de las posibilidades
	var index = possible_weathers.find(current_weather)
	if index >= 0:
		possible_weathers.remove(index)
	
	# Seleccionar un nuevo clima aleatorio
	var new_weather = possible_weathers[randi() % possible_weathers.size()]
	
	# Cambiar el clima
	change_weather(new_weather)
	
	return true

# Cambiar el clima
func change_weather(weather: String) -> void:
	# Guardar clima anterior
	var old_weather = world_state["current_weather"]
	
	# Actualizar clima
	world_state["current_weather"] = weather
	
	# Emitir señal de cambio de estado del mundo
	emit_signal("world_state_changed", "current_weather", old_weather, weather)
	
	# Aplicar efectos según el clima
	apply_weather_effects(weather)

# Aplicar efectos según el clima
func apply_weather_effects(weather: String) -> void:
	# Implementar efectos específicos según el clima
	match weather:
		"clear":
			# Buen clima, sin efectos negativos
			pass
		"cloudy":
			# Ligeramente más oscuro
			pass
		"rainy":
			# Reduce velocidad de movimiento
			pass
		"foggy":
			# Reduce visibilidad
			pass
		"acid_rain":
			# Daña al jugador y equipo si está a la intemperie
			pass
		"sandstorm":
			# Reduce visibilidad y velocidad de movimiento
			pass
		"toxic_mist":
			# Aplica efecto de veneno
			pass

# Activar un evento específico
func trigger_event(event_id: String) -> bool:
	# Verificar si el evento existe
	if not events.has(event_id):
		push_error("Evento no encontrado: " + event_id)
		return false
	
	# Obtener datos del evento
	var event_data = events[event_id]
	
	# Verificar si el evento ya está activo
	if active_events.has(event_id):
		return false
	
	# Verificar si el evento ya fue completado (para eventos únicos)
	if event_data["cooldown"] == 0 and event_id in completed_events:
		return false
	
	# Actualizar estado del evento
	event_data["status"] = EventStatus.ACTIVE
	
	# Añadir a eventos activos
	active_events[event_id] = event_data
	
	# Establecer tiempo de expiración si es necesario
	if event_data["expiration"] > 0:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = event_data["expiration"]
		timer.connect("timeout", self, "_on_event_expiration", [event_id])
		add_child(timer)
		timer.start()
	
	# Ejecutar acciones del evento
	execute_event_actions(event_id, event_data["actions"], event_data["action_params"])
	
	# Emitir señal
	emit_signal("event_triggered", event_id, event_data)
	
	return true

# Ejecutar acciones de un evento
func execute_event_actions(event_id: String, actions: Array, params: Dictionary) -> void:
	# Implementar cada acción
	for action in actions:
		match action:
			"start_dialogue":
				if params.has("dialogue_id"):
					start_dialogue(params["dialogue_id"])
			"add_quest":
				if params.has("quest_id"):
					add_quest(params["quest_id"])
			"add_item":
				if params.has("item_id") and params.has("item_amount"):
					add_item(params["item_id"], params["item_amount"])
			"change_weather":
				if params.has("weather"):
					change_weather(params["weather"])
			"apply_effect":
				if params.has("effect_id") and params.has("effect_duration"):
					apply_effect(params["effect_id"], params["effect_duration"])
			"damage_equipment":
				if params.has("equipment_damage"):
					damage_equipment(params["equipment_damage"])
			"spawn_npc":
				if params.has("npc_id"):
					spawn_npc(params["npc_id"])
			"show_vision":
				if params.has("vision_id"):
					show_vision(params["vision_id"])
			"start_encounter":
				if params.has("encounter_id"):
					start_encounter(params["encounter_id"])

# Seleccionar una opción en un evento
func select_event_choice(event_id: String, choice_id: String) -> bool:
	# Verificar si el evento existe y está activo
	if not active_events.has(event_id):
		return false
	
	# Obtener datos del evento
	var event_data = active_events[event_id]
	
	# Verificar si la opción existe
	var choice_exists = false
	for choice in event_data["choices"]:
		if choice["id"] == choice_id:
			choice_exists = true
			break
	
	if not choice_exists:
		return false
	
	# Verificar requisitos de reputación
	for choice in event_data["choices"]:
		if choice["id"] == choice_id:
			if not check_required_reputation(choice["required_reputation"]):
				return false
	
	# Aplicar cambios según la opción seleccionada
	if event_data["outcomes"].has(choice_id):
		var outcome = event_data["outcomes"][choice_id]
		
		# Aplicar cambios al estado del mundo
		if outcome.has("world_state_changes"):
			apply_world_state_changes(outcome["world_state_changes"])
		
		# Aplicar cambios de reputación
		if outcome.has("reputation_changes"):
			apply_reputation_changes(outcome["reputation_changes"])
	
	# Otorgar recompensas
	if event_data["rewards"].has(choice_id):
		var rewards = event_data["rewards"][choice_id]
		grant_rewards(rewards)
	
	# Completar el evento
	complete_event(event_id, choice_id)
	
	return true

# Completar un evento
func complete_event(event_id: String, result: String = "") -> void:
	# Verificar si el evento existe y está activo
	if not active_events.has(event_id):
		return
	
	# Obtener datos del evento
	var event_data = active_events[event_id]
	
	# Actualizar estado del evento
	event_data["status"] = EventStatus.COMPLETED
	
	# Eliminar de eventos activos
	active_events.erase(event_id)
	
	# Añadir a eventos completados
	if not event_id in completed_events:
		completed_events.append(event_id)
	
	# Establecer enfriamiento si es necesario
	if event_data["cooldown"] > 0:
		event_cooldowns[event_id] = OS.get_unix_time() + event_data["cooldown"]
	
	# Activar eventos siguientes si existen
	if event_data.has("next_events") and not event_data["next_events"].empty():
		for next_event in event_data["next_events"]:
			# Actualizar estado del siguiente evento
			if events.has(next_event):
				events[next_event]["status"] = EventStatus.AVAILABLE
	
	# Emitir señal
	emit_signal("event_completed", event_id, result)

# Fallar un evento
func fail_event(event_id: String, reason: String = "") -> void:
	# Verificar si el evento existe y está activo
	if not active_events.has(event_id):
		return
	
	# Obtener datos del evento
	var event_data = active_events[event_id]
	
	# Actualizar estado del evento
	event_data["status"] = EventStatus.FAILED
	
	# Eliminar de eventos activos
	active_events.erase(event_id)
	
	# Añadir a eventos fallidos
	if not event_id in failed_events:
		failed_events.append(event_id)
	
	# Establecer enfriamiento si es necesario
	if event_data["cooldown"] > 0:
		event_cooldowns[event_id] = OS.get_unix_time() + event_data["cooldown"]
	
	# Emitir señal
	emit_signal("event_failed", event_id, reason)

# Manejador de expiración de eventos
func _on_event_expiration(event_id: String) -> void:
	# Verificar si el evento sigue activo
	if active_events.has(event_id):
		# Obtener datos del evento
		var event_data = active_events[event_id]
		
		# Actualizar estado del evento
		event_data["status"] = EventStatus.EXPIRED
		
		# Eliminar de eventos activos
		active_events.erase(event_id)
		
		# Establecer enfriamiento si es necesario
		if event_data["cooldown"] > 0:
			event_cooldowns[event_id] = OS.get_unix_time() + event_data["cooldown"]

# Verificar misiones requeridas
func check_required_quests(required_quests: Array) -> bool:
	# Si no hay requisitos, retornar verdadero
	if required_quests.empty():
		return true
	
	# Obtener referencia al gestor de misiones
	var quest_manager = get_node("/root/QuestManager")
	
	# Verificar cada misión requerida
	for quest_id in required_quests:
		if not quest_manager.is_quest_completed(quest_id):
			return false
	
	return true

# Verificar eventos requeridos
func check_required_events(required_events: Array) -> bool:
	# Si no hay requisitos, retornar verdadero
	if required_events.empty():
		return true
	
	# Verificar cada evento requerido
	for event_id in required_events:
		if not event_id in completed_events:
			return false
	
	return true

# Verificar estado del mundo requerido
func check_required_world_state(required_state: Dictionary) -> bool:
	# Si no hay requisitos, retornar verdadero
	if required_state.empty():
		return true
	
	# Verificar cada estado requerido
	for key in required_state:
		# Manejar claves anidadas (por ejemplo, "faction_tension.hegemonia_errantes")
		var value = get_nested_world_state(key)
		
		# Si la clave no existe, retornar falso
		if value == null:
			return false
		
		# Verificar condición
		var condition = required_state[key]
		
		# Si la condición es un diccionario, verificar según el tipo
		if condition is Dictionary:
			# Verificar valor mínimo
			if condition.has("min") and value < condition["min"]:
				return false
			
			# Verificar valor máximo
			if condition.has("max") and value > condition["max"]:
				return false
			
			# Verificar valor exacto
			if condition.has("equals") and value != condition["equals"]:
				return false
			
			# Verificar valor no igual
			if condition.has("not") and value == condition["not"]:
				return false
		# Si la condición es un valor directo, verificar igualdad
		elif value != condition:
			return false
	
	return true

# Verificar requisitos de reputación
func check_required_reputation(required_reputation: Dictionary) -> bool:
	# Si no hay requisitos, retornar verdadero
	if required_reputation.empty():
		return true
	
	# Obtener referencia al gestor de facciones
	var faction_manager = get_node("/root/FactionManager")
	
	# Verificar cada facción requerida
	for faction_id in required_reputation:
		var reputation = faction_manager.get_reputation(faction_id)
		var condition = required_reputation[faction_id]
		
		# Verificar condición
		if condition is Dictionary:
			# Verificar valor mínimo
			if condition.has("min") and reputation < condition["min"]:
				return false
			
			# Verificar valor máximo
			if condition.has("max") and reputation > condition["max"]:
				return false
		elif reputation < condition:
			return false
	
	return true

# Aplicar cambios al estado del mundo
func apply_world_state_changes(changes: Dictionary) -> void:
	# Aplicar cada cambio
	for key in changes:
		# Guardar valor anterior
		var old_value = get_nested_world_state(key)
		
		# Aplicar nuevo valor
		set_nested_world_state(key, changes[key])
		
		# Emitir señal de cambio
		emit_signal("world_state_changed", key, old_value, changes[key])

# Aplicar cambios de reputación
func apply_reputation_changes(changes: Dictionary) -> void:
	# Obtener referencia al gestor de facciones
	var faction_manager = get_node("/root/FactionManager")
	
	# Aplicar cada cambio
	for faction_id in changes:
		faction_manager.modify_reputation(faction_id, changes[faction_id])

# Otorgar recompensas
func grant_rewards(rewards: Dictionary) -> void:
	# Otorgar experiencia
	if rewards.has("experience"):
		add_experience(rewards["experience"])
	
	# Otorgar objetos
	if rewards.has("items"):
		for item in rewards["items"]:
			# Verificar probabilidad si existe
			if item.has("chance"):
				if randf() > item["chance"]:
					continue
			
			# Añadir objeto
			add_item(item["id"], item["amount"])
	
	# Otorgar moneda
	if rewards.has("currency"):
		add_currency(rewards["currency"])

# Obtener valor anidado del estado del mundo
func get_nested_world_state(key: String):
	# Dividir la clave por puntos
	var parts = key.split(".")
	
	# Si solo hay una parte, obtener directamente
	if parts.size() == 1:
		return world_state.get(key)
	
	# Si hay múltiples partes, navegar por la estructura
	var current = world_state
	
	for i in range(parts.size()):
		var part = parts[i]
		
		# Verificar si existe la clave
		if not current.has(part):
			return null
		
		# Si es la última parte, retornar el valor
		if i == parts.size() - 1:
			return current[part]
		
		# Si no es la última parte, avanzar al siguiente nivel
		current = current[part]
		
		# Verificar si el siguiente nivel es un diccionario
		if not current is Dictionary:
			return null
	
	return null

# Establecer valor anidado en el estado del mundo
func set_nested_world_state(key: String, value) -> void:
	# Dividir la clave por puntos
	var parts = key.split(".")
	
	# Si solo hay una parte, establecer directamente
	if parts.size() == 1:
		world_state[key] = value
		return
	
	# Si hay múltiples partes, navegar por la estructura
	var current = world_state
	
	for i in range(parts.size() - 1):
		var part = parts[i]
		
		# Crear diccionario si no existe
		if not current.has(part):
			current[part] = {}
		
		# Avanzar al siguiente nivel
		current = current[part]
	
	# Establecer valor en el último nivel
	current[parts[parts.size() - 1]] = value

# Funciones auxiliares para acciones de eventos

# Iniciar diálogo
func start_dialogue(dialogue_id: String) -> void:
	# Obtener referencia al gestor de diálogos
	var dialogue_manager = get_node("/root/DialogueManager")
	
	# Iniciar diálogo
	dialogue_manager.start_dialogue(dialogue_id)

# Añadir misión
func add_quest(quest_id: String) -> void:
	# Obtener referencia al gestor de misiones
	var quest_manager = get_node("/root/QuestManager")
	
	# Añadir misión
	quest_manager.add_quest(quest_id)

# Añadir objeto
func add_item(item_id: String, amount: int) -> void:
	# Obtener referencia al gestor de inventario
	var inventory_manager = get_node("/root/InventoryManager")
	
	# Añadir objeto
	inventory_manager.add_item(item_id, amount)

# Aplicar efecto
func apply_effect(effect_id: String, duration: float) -> void:
	# Obtener referencia al gestor de efectos
	var effect_manager = get_node("/root/EffectManager")
	
	# Aplicar efecto
	effect_manager.apply_effect(effect_id, duration)

# Dañar equipo
func damage_equipment(damage_percent: float) -> void:
	# Obtener referencia al gestor de inventario
	var inventory_manager = get_node("/root/InventoryManager")
	
	# Dañar equipo equipado
	inventory_manager.damage_equipped_items(damage_percent)

# Generar NPC
func spawn_npc(npc_id: String) -> void:
	# Obtener referencia al gestor de NPCs
	var npc_manager = get_node("/root/NPCManager")
	
	# Generar NPC
	npc_manager.spawn_npc(npc_id)

# Mostrar visión
func show_vision(vision_id: String) -> void:
	# Obtener referencia al gestor de UI
	var ui_manager = get_node("/root/UIManager")
	
	# Mostrar visión
	ui_manager.show_vision(vision_id)

# Iniciar encuentro
func start_encounter(encounter_id: String) -> void:
	# Obtener referencia al gestor de combate
	var combat_manager = get_node("/root/CombatManager")
	
	# Iniciar encuentro
	combat_manager.start_encounter(encounter_id)

# Añadir experiencia
func add_experience(amount: int) -> void:
	# Obtener referencia al gestor de jugador
	var player_manager = get_node("/root/PlayerManager")
	
	# Añadir experiencia
	player_manager.add_experience(amount)

# Añadir moneda
func add_currency(amount: int) -> void:
	# Obtener referencia al gestor de inventario
	var inventory_manager = get_node("/root/InventoryManager")
	
	# Añadir moneda
	inventory_manager.add_currency(amount)

# Obtener nivel del jugador
func get_player_level() -> int:
	# Obtener referencia al gestor de jugador
	var player_manager = get_node("/root/PlayerManager")
	
	# Obtener nivel
	return player_manager.get_level()

# Obtener ubicación actual del jugador
func get_current_location() -> String:
	# Obtener referencia al gestor de jugador
	var player_manager = get_node("/root/PlayerManager")
	
	# Obtener ubicación
	return player_manager.get_current_location()

# Obtener eventos disponibles
func get_available_events() -> Array:
	var available = []
	
	for event_id in events:
		if events[event_id]["status"] == EventStatus.AVAILABLE:
			available.append(event_id)
	
	return available

# Obtener eventos activos
func get_active_events() -> Array:
	return active_events.keys()

# Obtener eventos completados
func get_completed_events() -> Array:
	return completed_events

# Obtener eventos fallidos
func get_failed_events() -> Array:
	return failed_events

# Obtener datos de un evento
func get_event_data(event_id: String) -> Dictionary:
	if events.has(event_id):
		return events[event_id].duplicate()
	
	return {}

# Guardar datos de eventos
func save_event_data() -> Dictionary:
	return {
		"world_state": world_state,
		"active_events": active_events,
		"completed_events": completed_events,
		"failed_events": failed_events,
		"event_cooldowns": event_cooldowns
	}

# Cargar datos de eventos
func load_event_data(data: Dictionary) -> void:
	if data.has("world_state"):
		world_state = data["world_state"]
	
	if data.has("active_events"):
		active_events = data["active_events"]
	
	if data.has("completed_events"):
		completed_events = data["completed_events"]
	
	if data.has("failed_events"):
		failed_events = data["failed_events"]
	
	if data.has("event_cooldowns"):
		event_cooldowns = data["event_cooldowns"]