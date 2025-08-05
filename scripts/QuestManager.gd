extends Node

# Enumeraciones para estados de misiones
enum QuestStatus {
	INACTIVE,
	ACTIVE,
	COMPLETED,
	FAILED
}

# Enumeraciones para tipos de misiones
enum QuestType {
	MAIN,
	SIDE,
	FACTION,
	EXPLORATION,
	BOSS_HUNT
}

# Señales
signal quest_added(quest_id)
signal quest_updated(quest_id, status)
signal quest_completed(quest_id)
signal quest_failed(quest_id)
signal objective_completed(quest_id, objective_id)

# Variables
var quest_library: Dictionary = {}
var active_quests: Dictionary = {}
var completed_quests: Array = []
var failed_quests: Array = []

# Función de inicialización
func _ready() -> void:
	# Cargar misiones predefinidas
	load_quest_library()

# Cargar la biblioteca de misiones
func load_quest_library() -> void:
	# En una implementación real, esto cargaría las misiones desde archivos JSON o similar
	# Por ahora, definimos algunas misiones de ejemplo directamente en el código
	
	# Misión principal: Despertar
	quest_library["main_awakening"] = {
		"id": "main_awakening",
		"title": "Despertar en las Ruinas",
		"description": "Has despertado en una instalación abandonada sin recuerdos. Descubre quién eres y qué es la extraña marca en tu piel.",
		"type": QuestType.MAIN,
		"giver": "auto",
		"location": "Complejo Génesis",
		"level_requirement": 1,
		"prerequisites": [],
		"objectives": [
			{
				"id": "escape_facility",
				"description": "Escapa de la instalación abandonada",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "reach_drossal",
				"description": "Llega a las Ruinas de Drossal",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 100,
			"items": [{"id": "basic_medkit", "quantity": 2}],
			"skills": [],
			"reputation": [],
			"story_flags": [{"flag": "prologue_completed", "value": true}]
		},
		"next_quest": "main_the_mark",
		"failure_conditions": [],
		"time_limit": 0  # 0 significa sin límite de tiempo
	}
	
	# Misión principal: La Marca
	quest_library["main_the_mark"] = {
		"id": "main_the_mark",
		"title": "La Marca",
		"description": "La extraña marca en tu piel parece ser un fragmento de algo llamado 'La Semilla'. Busca información sobre su origen y propósito.",
		"type": QuestType.MAIN,
		"giver": "Greta la Ciega",
		"location": "Ruinas de Drossal",
		"level_requirement": 2,
		"prerequisites": ["main_awakening"],
		"objectives": [
			{
				"id": "find_greta",
				"description": "Encuentra a Greta la Ciega en las Ruinas de Drossal",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "retrieve_ancient_text",
				"description": "Recupera el texto antiguo de la biblioteca en ruinas",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "return_to_greta",
				"description": "Regresa con Greta para descifrar el texto",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 200,
			"items": [{"id": "seed_fragment_enhancer", "quantity": 1}],
			"skills": [{"branch": "mutation", "id": "regeneration_cellular"}],
			"reputation": [],
			"story_flags": [{"flag": "knows_about_seed", "value": true}]
		},
		"next_quest": "main_desert_journey",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Misión secundaria: Kaelen - Entrenamiento de Combate
	quest_library["kaelen_combat_training"] = {
		"id": "kaelen_combat_training",
		"title": "Técnicas de Supervivencia",
		"description": "Kaelen, el ex-comandante de la Hegemonía, ha ofrecido enseñarte técnicas de combate que te ayudarán a sobrevivir en este mundo hostil.",
		"type": QuestType.SIDE,
		"giver": "Kaelen",
		"location": "Ruinas de Drossal",
		"level_requirement": 1,
		"prerequisites": [],
		"objectives": [
			{
				"id": "defeat_training_dummies",
				"description": "Derrota a los maniquíes de entrenamiento",
				"target_amount": 5,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "learn_counterattack",
				"description": "Aprende la técnica de contraataque",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "defeat_kaelen_sparring",
				"description": "Demuestra tu habilidad en un combate de entrenamiento contra Kaelen",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 150,
			"items": [{"id": "military_stimpack", "quantity": 1}],
			"skills": [{"branch": "combat", "id": "counterattack"}],
			"reputation": [{"faction": "hegemonia", "value": 5}],
			"story_flags": [{"flag": "kaelen_respect", "value": true}]
		},
		"next_quest": "kaelen_past_demons",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Misión de facción: Encontrar el Campamento de los Errantes
	quest_library["find_errantes_camp"] = {
		"id": "find_errantes_camp",
		"title": "Nómadas del Desierto",
		"description": "Sira te ha invitado al campamento principal de los Errantes en el Desierto Carmesí. Encuentra su ubicación y descubre más sobre esta facción de supervivientes nómadas.",
		"type": QuestType.FACTION,
		"giver": "Sira",
		"location": "Desierto Carmesí",
		"level_requirement": 3,
		"prerequisites": [],
		"objectives": [
			{
				"id": "reach_desert",
				"description": "Llega al Desierto Carmesí",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "follow_markers",
				"description": "Sigue los marcadores de los Errantes a través del desierto",
				"target_amount": 3,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "survive_sandstorm",
				"description": "Sobrevive a la tormenta de arena usando el amuleto de Sira",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "reach_camp",
				"description": "Llega al campamento principal de los Errantes",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 200,
			"items": [
				{"id": "errantes_garb", "quantity": 1},
				{"id": "water_purifier", "quantity": 1}
			],
			"skills": [],
			"reputation": [{"faction": "restauradores", "value": 15}],
			"story_flags": [{"flag": "errantes_camp_discovered", "value": true}]
		},
		"next_quest": "errantes_trial",
		"failure_conditions": [
			{"type": "item_missing", "item_id": "storm_amulet"}
		],
		"time_limit": 0
	}
	
	# Misión de caza de jefe: La Bestia del Bosque
	quest_library["hunt_raak"] = {
		"id": "hunt_raak",
		"title": "El Devorador del Bosque",
		"description": "Una criatura monstruosa conocida como Raak está aterrorizando a los exploradores en el Bosque Putrefacto. Los Restauradores han puesto precio a su cabeza.",
		"type": QuestType.BOSS_HUNT,
		"giver": "Tablón de Misiones de los Restauradores",
		"location": "Bosque Putrefacto",
		"level_requirement": 5,
		"prerequisites": [],
		"objectives": [
			{
				"id": "find_raak_lair",
				"description": "Localiza la guarida de Raak siguiendo los rastros de destrucción",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "collect_samples",
				"description": "Recoge muestras de la sustancia tóxica que Raak secreta",
				"target_amount": 3,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "defeat_raak",
				"description": "Derrota a Raak, el Devorador",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "return_proof",
				"description": "Regresa con prueba de la muerte de Raak",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 500,
			"items": [
				{"id": "raak_toxin_vial", "quantity": 1},
				{"id": "technofragments", "quantity": 50}
			],
			"skills": [{"branch": "mutation", "id": "toxic_adaptation"}],
			"reputation": [{"faction": "restauradores", "value": 20}],
			"story_flags": [{"flag": "raak_defeated", "value": true}]
		},
		"next_quest": "",
		"failure_conditions": [],
		"time_limit": 0
	}

# Añadir una misión a las misiones activas
func add_quest(quest_id: String) -> bool:
	# Verificar si la misión existe en la biblioteca
	if not quest_library.has(quest_id):
		print("Error: Misión no encontrada: " + quest_id)
		return false
	
	# Verificar si la misión ya está activa o completada
	if active_quests.has(quest_id) or quest_id in completed_quests or quest_id in failed_quests:
		print("Error: La misión ya está activa, completada o fallida: " + quest_id)
		return false
	
	# Verificar prerrequisitos
	var quest_data = quest_library[quest_id]
	for prereq in quest_data["prerequisites"]:
		if not prereq in completed_quests:
			print("Error: Prerrequisito no completado: " + prereq)
			return false
	
	# Verificar nivel requerido
	if GameManager.player_data["level"] < quest_data["level_requirement"]:
		print("Error: Nivel insuficiente para la misión: " + quest_id)
		return false
	
	# Añadir la misión a las activas
	active_quests[quest_id] = quest_data.duplicate(true)
	active_quests[quest_id]["status"] = QuestStatus.ACTIVE
	
	# Emitir señal
	emit_signal("quest_added", quest_id)
	
	return true

# Actualizar el progreso de un objetivo de misión
func update_objective(quest_id: String, objective_id: String, amount: int = 1) -> bool:
	# Verificar si la misión está activa
	if not active_quests.has(quest_id):
		return false
	
	# Buscar el objetivo
	var quest = active_quests[quest_id]
	var objective_found = false
	
	for objective in quest["objectives"]:
		if objective["id"] == objective_id and not objective["completed"]:
			objective_found = true
			
			# Actualizar la cantidad actual
			objective["current_amount"] += amount
			
			# Verificar si se ha completado el objetivo
			if objective["current_amount"] >= objective["target_amount"]:
				objective["current_amount"] = objective["target_amount"]
				objective["completed"] = true
				emit_signal("objective_completed", quest_id, objective_id)
				
				# Verificar si todos los objetivos están completados
				var all_completed = true
				for obj in quest["objectives"]:
					if not obj["completed"]:
						all_completed = false
						break
				
				if all_completed:
					complete_quest(quest_id)
			
			# Emitir señal de actualización
			emit_signal("quest_updated", quest_id, quest["status"])
			break
	
	return objective_found

# Completar una misión
func complete_quest(quest_id: String) -> bool:
	# Verificar si la misión está activa
	if not active_quests.has(quest_id):
		return false
	
	# Obtener los datos de la misión
	var quest = active_quests[quest_id]
	
	# Otorgar recompensas
	# Experiencia
	GameManager.player_data["experience"] += quest["rewards"]["experience"]
	
	# Objetos
	for item in quest["rewards"]["items"]:
		GameManager.add_to_inventory(item["id"], item["quantity"])
	
	# Habilidades
	for skill in quest["rewards"]["skills"]:
		GameManager.add_skill(skill["branch"], skill["id"])
	
	# Reputación
	for rep in quest["rewards"]["reputation"]:
		GameManager.change_reputation(rep["faction"], rep["value"])
	
	# Banderas de historia
	for flag in quest["rewards"]["story_flags"]:
		GameManager.set_story_flag(flag["flag"], flag["value"])
	
	# Actualizar estado de la misión
	quest["status"] = QuestStatus.COMPLETED
	
	# Mover de activas a completadas
	completed_quests.append(quest_id)
	active_quests.erase(quest_id)
	
	# Emitir señal
	emit_signal("quest_completed", quest_id)
	
	# Añadir siguiente misión si existe
	if quest["next_quest"] != "":
		add_quest(quest["next_quest"])
	
	return true

# Fallar una misión
func fail_quest(quest_id: String) -> bool:
	# Verificar si la misión está activa
	if not active_quests.has(quest_id):
		return false
	
	# Actualizar estado de la misión
	active_quests[quest_id]["status"] = QuestStatus.FAILED
	
	# Mover de activas a fallidas
	failed_quests.append(quest_id)
	active_quests.erase(quest_id)
	
	# Emitir señal
	emit_signal("quest_failed", quest_id)
	
	return true

# Verificar condiciones de fallo
func check_failure_conditions(quest_id: String) -> bool:
	# Verificar si la misión está activa
	if not active_quests.has(quest_id):
		return false
	
	# Obtener los datos de la misión
	var quest = active_quests[quest_id]
	
	# Verificar cada condición de fallo
	for condition in quest["failure_conditions"]:
		match condition["type"]:
			"item_missing":
				# Verificar si el jugador tiene el objeto requerido
				var has_item = false
				for item in GameManager.player_data["inventory"]:
					if item["id"] == condition["item_id"]:
						has_item = true
						break
				
				if not has_item:
					return true  # Condición de fallo cumplida
				
			"npc_dead":
				# Verificar si un NPC necesario está muerto
				if GameManager.check_story_flag("npc_" + condition["npc_id"] + "_dead") == true:
					return true  # Condición de fallo cumplida
				
			"time_expired":
				# Verificar si se ha agotado el tiempo (implementación pendiente)
				pass
				
			"faction_hostile":
				# Verificar si una facción necesaria es hostil
				var standing = GameManager.get_faction_standing(condition["faction"])
				if standing == "Hostil" or standing == "Odiado" or standing == "Enemigo Jurado":
					return true  # Condición de fallo cumplida
	
	return false  # Ninguna condición de fallo cumplida

# Obtener información de una misión
func get_quest_info(quest_id: String) -> Dictionary:
	# Verificar si la misión está activa
	if active_quests.has(quest_id):
		return active_quests[quest_id]
	
	# Verificar si la misión está en la biblioteca
	if quest_library.has(quest_id):
		return quest_library[quest_id]
	
	return {}

# Obtener todas las misiones activas
func get_active_quests() -> Array:
	var quests = []
	for quest_id in active_quests:
		quests.append(active_quests[quest_id])
	return quests

# Obtener todas las misiones completadas
func get_completed_quests() -> Array:
	var quests = []
	for quest_id in completed_quests:
		if quest_library.has(quest_id):
			quests.append(quest_library[quest_id])
	return quests

# Obtener todas las misiones fallidas
func get_failed_quests() -> Array:
	var quests = []
	for quest_id in failed_quests:
		if quest_library.has(quest_id):
			quests.append(quest_library[quest_id])
	return quests

# Obtener misiones disponibles para el jugador
func get_available_quests() -> Array:
	var available = []
	
	for quest_id in quest_library:
		# Omitir misiones ya activas, completadas o fallidas
		if active_quests.has(quest_id) or quest_id in completed_quests or quest_id in failed_quests:
			continue
		
		# Verificar prerrequisitos y nivel
		var quest = quest_library[quest_id]
		var prereqs_met = true
		
		for prereq in quest["prerequisites"]:
			if not prereq in completed_quests:
				prereqs_met = false
				break
		
		if prereqs_met and GameManager.player_data["level"] >= quest["level_requirement"]:
			available.append(quest)
	
	return available

# Verificar si una misión está activa
func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

# Verificar si una misión está completada
func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests

# Verificar si una misión ha fallado
func is_quest_failed(quest_id: String) -> bool:
	return quest_id in failed_quests

# Obtener el progreso de un objetivo específico
func get_objective_progress(quest_id: String, objective_id: String) -> Dictionary:
	# Verificar si la misión está activa
	if not active_quests.has(quest_id):
		return {}
	
	# Buscar el objetivo
	for objective in active_quests[quest_id]["objectives"]:
		if objective["id"] == objective_id:
			return {
				"current": objective["current_amount"],
				"target": objective["target_amount"],
				"completed": objective["completed"],
				"progress": float(objective["current_amount"]) / float(objective["target_amount"])
			}
	
	return {}

# Obtener el progreso general de una misión
func get_quest_progress(quest_id: String) -> float:
	# Verificar si la misión está activa
	if not active_quests.has(quest_id):
		return 0.0
	
	# Calcular el progreso promedio de todos los objetivos
	var total_objectives = active_quests[quest_id]["objectives"].size()
	var completed_objectives = 0
	
	for objective in active_quests[quest_id]["objectives"]:
		if objective["completed"]:
			completed_objectives += 1
		else:
			# Añadir progreso parcial
			completed_objectives += float(objective["current_amount"]) / float(objective["target_amount"])
	
	return completed_objectives / total_objectives

# Función para actualizar y verificar todas las misiones activas
func update_all_quests() -> void:
	# Verificar condiciones de fallo para todas las misiones activas
	var quests_to_check = active_quests.keys()
	for quest_id in quests_to_check:
		if check_failure_conditions(quest_id):
			fail_quest(quest_id)