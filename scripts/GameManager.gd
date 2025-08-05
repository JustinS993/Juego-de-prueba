extends Node

# Enumeraciones para estados del juego
enum GameState {
	MAIN_MENU,
	EXPLORATION,
	DIALOGUE,
	COMBAT,
	INVENTORY,
	SKILL_TREE,
	PAUSED
}

# Enumeraciones para facciones
enum Faction {
	NEUTRAL,
	RESTAURADORES,
	HEGEMONIA,
	NIHIL
}

# Variables del juego
var current_game_state: int = GameState.MAIN_MENU
var player_data: Dictionary = {
	"name": "El Portador",
	"level": 1,
	"experience": 0,
	"health": 100,
	"max_health": 100,
	"energy": 50,
	"max_energy": 50,
	"mutant_charge": 0,
	"max_mutant_charge": 100,
	"attributes": {
		"strength": 5,
		"agility": 5,
		"resistance": 5,
		"intellect": 5,
		"perception": 5,
		"will": 5
	},
	"skills": {
		"combat": [],
		"technology": [],
		"mutation": []
	},
	"inventory": [],
	"equipment": {
		"weapon": null,
		"armor": null,
		"accessory": null
	},
	"reputation": {
		"restauradores": 0,
		"hegemonia": 0,
		"nihil": 0
	},
	"discovered_locations": [],
	"completed_quests": [],
	"active_quests": [],
	"story_flags": {}
}

# Variables de seguimiento de misiones
var tracked_quest = {
	"quest_id": "",
	"objective_id": ""
}

var current_scene: Node = null
var current_location: String = ""
var game_time: float = 0.0  # Tiempo de juego en segundos
var day_cycle: float = 0.0  # 0.0 = amanecer, 0.5 = mediodía, 1.0 = anochecer

# Señales
signal game_state_changed(new_state)
signal player_stats_changed(stat_name, new_value)
signal reputation_changed(faction, value)
signal quest_updated(quest_id, status)
signal day_cycle_changed(time_of_day)
signal tracked_quest_changed(quest_id, objective_id)

# Función de inicialización
func _ready() -> void:
	# Configuración inicial
	process_mode = Node.PROCESS_MODE_ALWAYS  # Permite que este nodo funcione incluso cuando el juego está pausado
	
	# Conectar señales internas
	connect("game_state_changed", Callable(self, "_on_game_state_changed"))
	connect("tracked_quest_changed", Callable(self, "_on_tracked_quest_changed"))

# Función llamada cada frame
func _process(delta: float) -> void:
	# Actualizar tiempo de juego
	game_time += delta
	
	# Actualizar ciclo día/noche (un día completo dura 24 minutos de tiempo real)
	var previous_day_cycle = day_cycle
	day_cycle = fmod(game_time / (24.0 * 60.0), 1.0)
	
	# Emitir señal si el ciclo del día ha cambiado significativamente
	if abs(day_cycle - previous_day_cycle) > 0.01 or (previous_day_cycle > 0.95 and day_cycle < 0.05):
		emit_signal("day_cycle_changed", day_cycle)

# Cambiar el estado del juego
func change_game_state(new_state: int) -> void:
	var previous_state = current_game_state
	current_game_state = new_state
	
	# Pausar el juego si estamos en el menú de pausa
	if new_state == GameState.PAUSED:
		get_tree().paused = true
	elif previous_state == GameState.PAUSED:
		get_tree().paused = false
	
	emit_signal("game_state_changed", new_state)

# Modificar atributos del jugador
func modify_player_attribute(attribute: String, amount: int) -> void:
	if player_data["attributes"].has(attribute):
		player_data["attributes"][attribute] += amount
		emit_signal("player_stats_changed", attribute, player_data["attributes"][attribute])

# Modificar estadísticas del jugador
func modify_player_stat(stat: String, amount: int) -> void:
	if player_data.has(stat):
		player_data[stat] += amount
		
		# Asegurarse de que los valores no excedan los máximos
		if stat == "health" and player_data[stat] > player_data["max_health"]:
			player_data[stat] = player_data["max_health"]
		elif stat == "energy" and player_data[stat] > player_data["max_energy"]:
			player_data[stat] = player_data["max_energy"]
		elif stat == "mutant_charge" and player_data[stat] > player_data["max_mutant_charge"]:
			player_data[stat] = player_data["max_mutant_charge"]
		
		emit_signal("player_stats_changed", stat, player_data[stat])

# Cambiar la reputación con una facción
func change_reputation(faction: String, amount: int) -> void:
	if player_data["reputation"].has(faction):
		player_data["reputation"][faction] += amount
		
		# Limitar la reputación entre -100 y 100
		player_data["reputation"][faction] = clamp(player_data["reputation"][faction], -100, 100)
		
		emit_signal("reputation_changed", faction, player_data["reputation"][faction])

# Añadir una habilidad al jugador
func add_skill(skill_branch: String, skill_id: String) -> bool:
	if player_data["skills"].has(skill_branch) and not skill_id in player_data["skills"][skill_branch]:
		player_data["skills"][skill_branch].append(skill_id)
		return true
	return false

# Verificar si el jugador tiene una habilidad
func has_skill(skill_branch: String, skill_id: String) -> bool:
	if player_data["skills"].has(skill_branch):
		return skill_id in player_data["skills"][skill_branch]
	return false

# Añadir un objeto al inventario
func add_to_inventory(item_id: String, quantity: int = 1) -> bool:
	# Buscar si el objeto ya existe en el inventario
	for item in player_data["inventory"]:
		if item["id"] == item_id:
			item["quantity"] += quantity
			return true
	
	# Si no existe, añadirlo como nuevo
	player_data["inventory"].append({"id": item_id, "quantity": quantity})
	return true

# Establecer una bandera de historia
func set_story_flag(flag_name: String, value) -> void:
	player_data["story_flags"][flag_name] = value

# Verificar una bandera de historia
func check_story_flag(flag_name: String):
	if player_data["story_flags"].has(flag_name):
		return player_data["story_flags"][flag_name]
	return null

# Guardar el juego
func save_game(slot: int = 1) -> bool:
	# Crear un diccionario con todos los datos a guardar
	var save_data = {
		"player": player_data,
		"game_time": game_time,
		"current_location": current_location,
		"version": "0.1"
	}
	
	# Llamar al SaveManager para guardar los datos
	return SaveManager.save_game(save_data, slot)

# Cargar el juego
func load_game(slot: int = 1) -> bool:
	# Llamar al SaveManager para cargar los datos
	var load_data = SaveManager.load_game(slot)
	
	if load_data:
		# Actualizar los datos del jugador y del juego
		player_data = load_data["player"]
		game_time = load_data["game_time"]
		current_location = load_data["current_location"]
		
		# Cargar la escena correspondiente
		# TODO: Implementar la carga de la escena basada en current_location
		
		return true
	return false

# Manejador de cambio de estado del juego
func _on_game_state_changed(new_state: int) -> void:
	# Lógica adicional cuando cambia el estado del juego
	pass

# Obtener el nivel de relación con una facción
func get_faction_standing(faction: String) -> String:
	if not player_data["reputation"].has(faction):
		return "Neutral"
	
	var rep = player_data["reputation"][faction]
	
	if rep >= 75:
		return "Aliado"
	elif rep >= 50:
		return "Amistoso"
	elif rep >= 25:
		return "Respetado"
	elif rep >= 0:
		return "Neutral"
	elif rep >= -25:
		return "Desconfiado"
	elif rep >= -50:
		return "Hostil"
	elif rep >= -75:
		return "Odiado"
	else:
		return "Enemigo Jurado"

# Calcular el daño basado en atributos
func calculate_damage(base_damage: int, attribute: String) -> int:
	var attribute_value = player_data["attributes"][attribute] if player_data["attributes"].has(attribute) else 5
	var modifier = 1.0 + (attribute_value - 5) * 0.1  # +10% por cada punto por encima de 5
	return int(base_damage * modifier)

# Verificar si el jugador puede aprender una nueva habilidad
func can_learn_skill(skill_branch: String, skill_id: String, required_level: int, required_skills: Array) -> bool:
	# Verificar nivel
	if player_data["level"] < required_level:
		return false
	
	# Verificar habilidades requeridas
	for req_skill in required_skills:
		if not has_skill(skill_branch, req_skill):
			return false
	
	return true

# Establecer misión seguida
func set_tracked_quest(quest_id: String, objective_id: String = "") -> void:
	# Si no se especifica objetivo, usar el primer objetivo no completado
	if objective_id == "" and quest_id != "":
		var quest_data = QuestManager.get_quest_info(quest_id)
		if not quest_data.empty():
			for obj in quest_data["objectives"]:
				if not obj["completed"]:
					objective_id = obj["id"]
					break
	
	# Actualizar misión seguida
	tracked_quest = {
		"quest_id": quest_id,
		"objective_id": objective_id
	}
	
	# Emitir señal
	emit_signal("tracked_quest_changed", quest_id, objective_id)

# Obtener misión seguida
func get_tracked_quest() -> Dictionary:
	return tracked_quest

# Cuando cambia la misión seguida
func _on_tracked_quest_changed(quest_id: String, objective_id: String) -> void:
	# Actualizar UI del rastreador de misiones
	if has_node("/root/QuestTracker"):
		get_node("/root/QuestTracker").update_tracker()