extends Node

# Señales
signal reputation_changed(faction_id, old_value, new_value)
signal faction_status_changed(faction_id, old_status, new_status)
signal faction_discovered(faction_id)

# Enumeraciones
enum FactionStatus {
	UNKNOWN,    # Facción no descubierta aún
	NEUTRAL,    # Neutral hacia el jugador
	FRIENDLY,   # Amistosa hacia el jugador
	ALLIED,     # Aliada del jugador
	SUSPICIOUS, # Sospecha del jugador
	HOSTILE,    # Hostil hacia el jugador
	ENEMY       # Enemiga declarada del jugador
}

# Variables
var factions: Dictionary = {}
var faction_relationships: Dictionary = {}
var player_reputation: Dictionary = {}
var player_faction_status: Dictionary = {}
var faction_quests: Dictionary = {}
var faction_leaders: Dictionary = {}
var faction_territories: Dictionary = {}

# Constantes de reputación
const REPUTATION_MIN: int = -100
const REPUTATION_MAX: int = 100
const REPUTATION_THRESHOLD_HOSTILE: int = -50
const REPUTATION_THRESHOLD_SUSPICIOUS: int = -20
const REPUTATION_THRESHOLD_NEUTRAL: int = 0
const REPUTATION_THRESHOLD_FRIENDLY: int = 30
const REPUTATION_THRESHOLD_ALLIED: int = 75

# Función de inicialización
func _ready() -> void:
	# Inicializar facciones
	initialize_factions()
	
	# Inicializar relaciones entre facciones
	initialize_faction_relationships()
	
	# Inicializar reputación del jugador
	initialize_player_reputation()

# Inicializar facciones
func initialize_factions() -> void:
	# Saqueadores de Chatarra
	factions["scrap_raiders"] = {
		"id": "scrap_raiders",
		"name": "Saqueadores de Chatarra",
		"description": "Bandas de supervivientes que saquean las ruinas en busca de tecnología y recursos. Violentos pero organizados bajo el liderazgo de Raak.",
		"headquarters": "Fortaleza de Hierro",
		"ideology": "Supervivencia del más fuerte. Tomar lo que necesitas por la fuerza.",
		"discovered": true,  # Conocidos desde el principio
		"color": Color(0.8, 0.2, 0.2)  # Rojo oscuro
	}
	
	# Los Errantes
	factions["wanderers"] = {
		"id": "wanderers",
		"name": "Los Errantes",
		"description": "Nómadas que recorren el Desierto Carmesí. Comerciantes y mediadores entre las demás facciones, liderados por Sira.",
		"headquarters": "Caravana Errante",
		"ideology": "Libertad, comercio y conocimiento compartido. El movimiento es vida.",
		"discovered": true,  # Conocidos desde el principio
		"color": Color(0.9, 0.7, 0.2)  # Amarillo ocre
	}
	
	# Colectivo Tecnológico
	factions["tech_collective"] = {
		"id": "tech_collective",
		"name": "Colectivo Tecnológico",
		"description": "Científicos e ingenieros que buscan preservar y desarrollar tecnología. Habitan en el Sector Helios-07 bajo el liderazgo de Kovak el Hacedor.",
		"headquarters": "Cúpula de Helios",
		"ideology": "El progreso tecnológico salvará a la humanidad. El conocimiento debe ser preservado.",
		"discovered": false,  # Se descubren durante el juego
		"color": Color(0.2, 0.6, 0.8)  # Azul
	}
	
	# Hijos del Átomo
	factions["children_of_atom"] = {
		"id": "children_of_atom",
		"name": "Hijos del Átomo",
		"description": "Culto que venera la radiación y las mutaciones como el siguiente paso evolutivo. Habitan en el Bosque Putrefacto bajo el liderazgo de Greta la Ciega.",
		"headquarters": "Templo de la Mutación",
		"ideology": "La mutación es divina. La radiación purifica. El viejo mundo debe ser transformado.",
		"discovered": false,  # Se descubren durante el juego
		"color": Color(0.5, 0.8, 0.3)  # Verde tóxico
	}
	
	# La Semilla
	factions["the_seed"] = {
		"id": "the_seed",
		"name": "La Semilla",
		"description": "Inteligencia artificial fragmentada que busca reconstruirse. Sus agentes son humanos con implantes o máquinas autónomas.",
		"headquarters": "El Cráter",
		"ideology": "Orden, eficiencia y unificación bajo una sola mente colectiva.",
		"discovered": false,  # Se descubren durante la historia principal
		"color": Color(0.7, 0.3, 0.7)  # Púrpura
	}
	
	# Guardianes del Olvido
	factions["oblivion_guardians"] = {
		"id": "oblivion_guardians",
		"name": "Guardianes del Olvido",
		"description": "Grupo secreto que busca destruir toda tecnología avanzada para evitar otro cataclismo. Operan desde las sombras.",
		"headquarters": "Desconocido",
		"ideology": "La tecnología causó la caída. Debemos destruirla para que la humanidad sobreviva.",
		"discovered": false,  # Facción secreta
		"color": Color(0.3, 0.3, 0.3)  # Gris oscuro
	}
	
	# Configurar líderes de facciones
	faction_leaders["scrap_raiders"] = "raak"
	faction_leaders["wanderers"] = "sira"
	faction_leaders["tech_collective"] = "kovak"
	faction_leaders["children_of_atom"] = "greta"
	faction_leaders["the_seed"] = "prime_node"
	faction_leaders["oblivion_guardians"] = "shadow_master"
	
	# Configurar territorios de facciones
	faction_territories["scrap_raiders"] = ["ruinas_de_drossal", "fortaleza_de_hierro"]
	faction_territories["wanderers"] = ["desierto_carmesi", "oasis_de_los_susurros"]
	faction_territories["tech_collective"] = ["sector_helios_07", "cupula_de_helios"]
	faction_territories["children_of_atom"] = ["bosque_putrefacto", "templo_de_la_mutacion"]
	faction_territories["the_seed"] = ["el_crater", "nucleo_de_la_semilla"]
	faction_territories["oblivion_guardians"] = ["santuario_oculto"]

# Inicializar relaciones entre facciones
func initialize_faction_relationships() -> void:
	# Formato: faction_relationships[faction1][faction2] = valor
	# Valores: -100 (enemigos mortales) a 100 (aliados cercanos)
	
	# Inicializar estructura
	for faction1 in factions:
		faction_relationships[faction1] = {}
		for faction2 in factions:
			if faction1 != faction2:
				faction_relationships[faction1][faction2] = 0  # Neutral por defecto
	
	# Configurar relaciones específicas
	
	# Saqueadores de Chatarra
	faction_relationships["scrap_raiders"]["wanderers"] = -30  # Desconfianza, pero comercian
	faction_relationships["scrap_raiders"]["tech_collective"] = -70  # Hostiles, atacan por tecnología
	faction_relationships["scrap_raiders"]["children_of_atom"] = -50  # Hostiles, los consideran locos
	faction_relationships["scrap_raiders"]["the_seed"] = -90  # Enemigos mortales
	faction_relationships["scrap_raiders"]["oblivion_guardians"] = -20  # Desconfianza
	
	# Los Errantes
	faction_relationships["wanderers"]["scrap_raiders"] = -30  # Desconfianza, pero comercian
	faction_relationships["wanderers"]["tech_collective"] = 50  # Amistosos, intercambian conocimiento
	faction_relationships["wanderers"]["children_of_atom"] = 0  # Neutrales, cautela
	faction_relationships["wanderers"]["the_seed"] = -60  # Hostiles, amenaza a su libertad
	faction_relationships["wanderers"]["oblivion_guardians"] = -10  # Ligera desconfianza
	
	# Colectivo Tecnológico
	faction_relationships["tech_collective"]["scrap_raiders"] = -70  # Hostiles, los ven como bárbaros
	faction_relationships["tech_collective"]["wanderers"] = 50  # Amistosos, intercambian conocimiento
	faction_relationships["tech_collective"]["children_of_atom"] = -40  # Desconfianza, los ven como irracionales
	faction_relationships["tech_collective"]["the_seed"] = 20  # Interés cauteloso
	faction_relationships["tech_collective"]["oblivion_guardians"] = -80  # Enemigos mortales
	
	# Hijos del Átomo
	faction_relationships["children_of_atom"]["scrap_raiders"] = -50  # Hostiles, los ven como impuros
	faction_relationships["children_of_atom"]["wanderers"] = 0  # Neutrales
	faction_relationships["children_of_atom"]["tech_collective"] = -40  # Desconfianza, tecnología sin espíritu
	faction_relationships["children_of_atom"]["the_seed"] = 30  # Interés, ven potencial evolutivo
	faction_relationships["children_of_atom"]["oblivion_guardians"] = -60  # Hostiles, visiones opuestas
	
	# La Semilla
	faction_relationships["the_seed"]["scrap_raiders"] = -90  # Enemigos, obstáculos primitivos
	faction_relationships["the_seed"]["wanderers"] = -60  # Hostiles, demasiado caóticos
	faction_relationships["the_seed"]["tech_collective"] = 20  # Interés, potenciales aliados o herramientas
	faction_relationships["the_seed"]["children_of_atom"] = 30  # Interés, potenciales sujetos de prueba
	faction_relationships["the_seed"]["oblivion_guardians"] = -100  # Enemigos mortales
	
	# Guardianes del Olvido
	faction_relationships["oblivion_guardians"]["scrap_raiders"] = -20  # Desconfianza
	faction_relationships["oblivion_guardians"]["wanderers"] = -10  # Ligera desconfianza
	faction_relationships["oblivion_guardians"]["tech_collective"] = -80  # Enemigos mortales
	faction_relationships["oblivion_guardians"]["children_of_atom"] = -60  # Hostiles, los ven como abominaciones
	faction_relationships["oblivion_guardians"]["the_seed"] = -100  # Enemigos mortales
	
	# Asegurar simetría en las relaciones
	for faction1 in faction_relationships:
		for faction2 in faction_relationships[faction1]:
			faction_relationships[faction2][faction1] = faction_relationships[faction1][faction2]

# Inicializar reputación del jugador
func initialize_player_reputation() -> void:
	# Inicializar reputación neutral con todas las facciones
	for faction_id in factions:
		player_reputation[faction_id] = 0
		
		# Determinar estado inicial basado en la reputación
		player_faction_status[faction_id] = get_status_from_reputation(0)
		
		# Marcar como desconocidas las facciones no descubiertas
		if not factions[faction_id]["discovered"]:
			player_faction_status[faction_id] = FactionStatus.UNKNOWN

# Modificar reputación del jugador con una facción
func modify_reputation(faction_id: String, amount: int) -> void:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		print("Error: Facción '" + faction_id + "' no encontrada.")
		return
	
	# Si la facción no ha sido descubierta, descubrirla
	if player_faction_status[faction_id] == FactionStatus.UNKNOWN:
		discover_faction(faction_id)
	
	# Guardar valor anterior para la señal
	var old_value = player_reputation[faction_id]
	
	# Modificar reputación
	player_reputation[faction_id] += amount
	
	# Limitar a los valores mínimo y máximo
	player_reputation[faction_id] = clamp(player_reputation[faction_id], REPUTATION_MIN, REPUTATION_MAX)
	
	# Actualizar estado de la facción
	update_faction_status(faction_id)
	
	# Emitir señal de cambio de reputación
	emit_signal("reputation_changed", faction_id, old_value, player_reputation[faction_id])

# Actualizar estado de una facción basado en la reputación
func update_faction_status(faction_id: String) -> void:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return
	
	# Si la facción no ha sido descubierta, no actualizar
	if player_faction_status[faction_id] == FactionStatus.UNKNOWN:
		return
	
	# Guardar estado anterior para la señal
	var old_status = player_faction_status[faction_id]
	
	# Determinar nuevo estado basado en la reputación
	var new_status = get_status_from_reputation(player_reputation[faction_id])
	
	# Actualizar estado
	player_faction_status[faction_id] = new_status
	
	# Emitir señal si el estado ha cambiado
	if old_status != new_status:
		emit_signal("faction_status_changed", faction_id, old_status, new_status)

# Determinar estado de facción basado en la reputación
func get_status_from_reputation(reputation: int) -> int:
	if reputation <= REPUTATION_THRESHOLD_HOSTILE:
		return FactionStatus.HOSTILE
	elif reputation < REPUTATION_THRESHOLD_SUSPICIOUS:
		return FactionStatus.SUSPICIOUS
	elif reputation < REPUTATION_THRESHOLD_FRIENDLY:
		return FactionStatus.NEUTRAL
	elif reputation < REPUTATION_THRESHOLD_ALLIED:
		return FactionStatus.FRIENDLY
	else:
		return FactionStatus.ALLIED

# Descubrir una facción
func discover_faction(faction_id: String) -> void:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return
	
	# Marcar como descubierta
	factions[faction_id]["discovered"] = true
	
	# Actualizar estado
	player_faction_status[faction_id] = get_status_from_reputation(player_reputation[faction_id])
	
	# Emitir señal
	emit_signal("faction_discovered", faction_id)

# Verificar si una facción ha sido descubierta
func is_faction_discovered(faction_id: String) -> bool:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return false
	
	return factions[faction_id]["discovered"]

# Obtener reputación del jugador con una facción
func get_reputation(faction_id: String) -> int:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return 0
	
	return player_reputation[faction_id]

# Obtener estado de una facción
func get_faction_status(faction_id: String) -> int:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return FactionStatus.UNKNOWN
	
	return player_faction_status[faction_id]

# Obtener nombre de estado de facción
func get_faction_status_name(status: int) -> String:
	match status:
		FactionStatus.UNKNOWN:
			return "Desconocida"
		FactionStatus.NEUTRAL:
			return "Neutral"
		FactionStatus.FRIENDLY:
			return "Amistosa"
		FactionStatus.ALLIED:
			return "Aliada"
		FactionStatus.SUSPICIOUS:
			return "Sospechosa"
		FactionStatus.HOSTILE:
			return "Hostil"
		FactionStatus.ENEMY:
			return "Enemiga"
		_:
			return "Desconocida"

# Verificar si dos facciones son hostiles entre sí
func are_factions_hostile(faction1: String, faction2: String) -> bool:
	# Verificar si ambas facciones existen
	if not factions.has(faction1) or not factions.has(faction2):
		return false
	
	# Si es la misma facción, no son hostiles
	if faction1 == faction2:
		return false
	
	# Verificar relación
	return faction_relationships[faction1][faction2] <= REPUTATION_THRESHOLD_HOSTILE

# Verificar si dos facciones son amistosas entre sí
func are_factions_friendly(faction1: String, faction2: String) -> bool:
	# Verificar si ambas facciones existen
	if not factions.has(faction1) or not factions.has(faction2):
		return false
	
	# Si es la misma facción, son amistosas
	if faction1 == faction2:
		return true
	
	# Verificar relación
	return faction_relationships[faction1][faction2] >= REPUTATION_THRESHOLD_FRIENDLY

# Verificar si el jugador es hostil con una facción
func is_player_hostile_with(faction_id: String) -> bool:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return false
	
	# Verificar estado
	return player_faction_status[faction_id] == FactionStatus.HOSTILE or player_faction_status[faction_id] == FactionStatus.ENEMY

# Verificar si el jugador es amistoso con una facción
func is_player_friendly_with(faction_id: String) -> bool:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return false
	
	# Verificar estado
	return player_faction_status[faction_id] == FactionStatus.FRIENDLY or player_faction_status[faction_id] == FactionStatus.ALLIED

# Verificar si el jugador es aliado de una facción
func is_player_allied_with(faction_id: String) -> bool:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return false
	
	# Verificar estado
	return player_faction_status[faction_id] == FactionStatus.ALLIED

# Obtener facciones hostiles al jugador
func get_hostile_factions() -> Array:
	var hostile_factions = []
	
	# Recorrer todas las facciones
	for faction_id in player_faction_status:
		if player_faction_status[faction_id] == FactionStatus.HOSTILE or player_faction_status[faction_id] == FactionStatus.ENEMY:
			hostile_factions.append(faction_id)
	
	return hostile_factions

# Obtener facciones amistosas al jugador
func get_friendly_factions() -> Array:
	var friendly_factions = []
	
	# Recorrer todas las facciones
	for faction_id in player_faction_status:
		if player_faction_status[faction_id] == FactionStatus.FRIENDLY or player_faction_status[faction_id] == FactionStatus.ALLIED:
			friendly_factions.append(faction_id)
	
	return friendly_factions

# Obtener facciones descubiertas
func get_discovered_factions() -> Array:
	var discovered = []
	
	# Recorrer todas las facciones
	for faction_id in factions:
		if factions[faction_id]["discovered"]:
			discovered.append(faction_id)
	
	return discovered

# Obtener datos de una facción
func get_faction_data(faction_id: String) -> Dictionary:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return {}
	
	return factions[faction_id]

# Obtener líder de una facción
func get_faction_leader(faction_id: String) -> String:
	# Verificar si la facción existe
	if not faction_leaders.has(faction_id):
		return ""
	
	return faction_leaders[faction_id]

# Obtener territorios de una facción
func get_faction_territories(faction_id: String) -> Array:
	# Verificar si la facción existe
	if not faction_territories.has(faction_id):
		return []
	
	return faction_territories[faction_id]

# Verificar si una ubicación pertenece a una facción
func is_location_owned_by_faction(location_id: String, faction_id: String) -> bool:
	# Verificar si la facción existe
	if not faction_territories.has(faction_id):
		return false
	
	# Verificar si la ubicación está en los territorios de la facción
	return location_id in faction_territories[faction_id]

# Obtener facción que controla una ubicación
func get_faction_controlling_location(location_id: String) -> String:
	# Recorrer todas las facciones
	for faction_id in faction_territories:
		if location_id in faction_territories[faction_id]:
			return faction_id
	
	return ""  # Ninguna facción controla esta ubicación

# Añadir misión de facción
func add_faction_quest(faction_id: String, quest_id: String) -> void:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return
	
	# Inicializar array si no existe
	if not faction_quests.has(faction_id):
		faction_quests[faction_id] = []
	
	# Añadir misión si no existe ya
	if not quest_id in faction_quests[faction_id]:
		faction_quests[faction_id].append(quest_id)

# Obtener misiones de una facción
func get_faction_quests(faction_id: String) -> Array:
	# Verificar si la facción existe
	if not faction_quests.has(faction_id):
		return []
	
	return faction_quests[faction_id]

# Completar misión de facción
func complete_faction_quest(faction_id: String, quest_id: String, reputation_reward: int = 10) -> void:
	# Verificar si la facción existe
	if not faction_quests.has(faction_id):
		return
	
	# Verificar si la misión existe
	if not quest_id in faction_quests[faction_id]:
		return
	
	# Aumentar reputación
	modify_reputation(faction_id, reputation_reward)

# Fallar misión de facción
func fail_faction_quest(faction_id: String, quest_id: String, reputation_penalty: int = -10) -> void:
	# Verificar si la facción existe
	if not faction_quests.has(faction_id):
		return
	
	# Verificar si la misión existe
	if not quest_id in faction_quests[faction_id]:
		return
	
	# Disminuir reputación
	modify_reputation(faction_id, reputation_penalty)

# Declarar enemistad con una facción
func declare_enemy(faction_id: String) -> void:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return
	
	# Guardar estado anterior para la señal
	var old_status = player_faction_status[faction_id]
	
	# Establecer reputación mínima
	player_reputation[faction_id] = REPUTATION_MIN
	
	# Establecer estado como enemigo
	player_faction_status[faction_id] = FactionStatus.ENEMY
	
	# Emitir señal
	emit_signal("faction_status_changed", faction_id, old_status, FactionStatus.ENEMY)
	
	# Afectar relaciones con facciones aliadas
	for other_faction in faction_relationships[faction_id]:
		if faction_relationships[faction_id][other_faction] >= REPUTATION_THRESHOLD_FRIENDLY:
			# Reducir reputación con facciones aliadas
			modify_reputation(other_faction, -20)

# Obtener descripción de la relación del jugador con una facción
func get_player_faction_relation_description(faction_id: String) -> String:
	# Verificar si la facción existe
	if not factions.has(faction_id):
		return "Desconocida"
	
	# Si la facción no ha sido descubierta
	if not factions[faction_id]["discovered"]:
		return "Desconocida"
	
	# Obtener reputación
	var reputation = player_reputation[faction_id]
	
	# Determinar descripción según la reputación
	if reputation <= -90:
		return "Enemigo mortal"
	elif reputation <= -70:
		return "Odiado"
	elif reputation <= -50:
		return "Hostil"
	elif reputation <= -30:
		return "Desconfiado"
	elif reputation <= -10:
		return "Cauteloso"
	elif reputation < 10:
		return "Neutral"
	elif reputation < 30:
		return "Aceptado"
	elif reputation < 50:
		return "Respetado"
	elif reputation < 70:
		return "Admirado"
	elif reputation < 90:
		return "Venerado"
	else:
		return "Leyenda"

# Guardar datos de facciones
func save_faction_data() -> Dictionary:
	return {
		"player_reputation": player_reputation,
		"player_faction_status": player_faction_status,
		"faction_quests": faction_quests,
		"discovered_factions": get_discovered_factions()
	}

# Cargar datos de facciones
func load_faction_data(data: Dictionary) -> void:
	# Cargar reputación
	player_reputation = data["player_reputation"]
	
	# Cargar estado de facciones
	player_faction_status = data["player_faction_status"]
	
	# Cargar misiones de facciones
	faction_quests = data["faction_quests"]
	
	# Actualizar facciones descubiertas
	for faction_id in data["discovered_factions"]:
		if factions.has(faction_id):
			factions[faction_id]["discovered"] = true