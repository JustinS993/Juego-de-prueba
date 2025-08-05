extends Node

# Señales
signal combat_started(enemies)
signal combat_ended(victory)
signal turn_started(entity)
signal turn_ended(entity)
signal action_performed(entity, action, target, result)
signal initiative_updated(initiative_order)
signal entity_stats_changed(entity, stat, value)

# Enumeraciones
enum CombatState {
	INACTIVE,
	INITIALIZING,
	PLAYER_TURN,
	ENEMY_TURN,
	ANIMATING,
	ENDING
}

enum ActionType {
	ATTACK,
	SKILL,
	ITEM,
	DEFEND,
	FLEE,
	PERSUADE
}

# Variables de estado
var current_state: int = CombatState.INACTIVE
var initiative_order: Array = []
var current_turn_index: int = 0
var current_entity = null
var player = null
var enemies: Array = []
var allies: Array = []
var environment_effects: Dictionary = {}
var combat_log: Array = []
var turn_count: int = 0
var is_player_mutant_reaction_available: bool = true

# Constantes
const MAX_COMBAT_TURNS: int = 30  # Límite para evitar combates infinitos
const BASE_FLEE_CHANCE: float = 0.4  # 40% de probabilidad base de huir
const BASE_PERSUADE_CHANCE: float = 0.3  # 30% de probabilidad base de persuadir

# Función de inicialización
func _ready() -> void:
	# Conectar señales relevantes
	GameManager.connect("game_state_changed", Callable(self, "_on_game_state_changed"))

# Iniciar combate con enemigos dados
func start_combat(enemy_list: Array, environment: String = "", is_ambush: bool = false) -> void:
	# Verificar que no estemos ya en combate
	if current_state != CombatState.INACTIVE:
		return
	
	# Cambiar estado del juego
	GameManager.change_game_state(GameManager.GameState.COMBAT)
	
	# Inicializar variables de combate
	current_state = CombatState.INITIALIZING
	enemies = enemy_list.duplicate()
	player = GameManager.get_player_node()
	allies = get_active_allies()
	turn_count = 0
	combat_log.clear()
	is_player_mutant_reaction_available = true
	
	# Configurar efectos del entorno
	setup_environment_effects(environment)
	
	# Calcular iniciativa y orden de turnos
	calculate_initiative(is_ambush)
	
	# Aplicar efectos de inicio de combate
	apply_combat_start_effects()
	
	# Emitir señal de inicio de combate
	emit_signal("combat_started", enemies)
	
	# Iniciar el primer turno
	start_next_turn()

# Calcular iniciativa para todos los participantes
func calculate_initiative(is_ambush: bool) -> void:
	initiative_order.clear()
	
	# Añadir jugador y aliados
	initiative_order.append({
		"entity": player,
		"is_player": true,
		"initiative": calculate_entity_initiative(player, is_ambush and false)  # Penalización si es emboscado
	})
	
	for ally in allies:
		initiative_order.append({
			"entity": ally,
			"is_player": false,
			"is_ally": true,
			"initiative": calculate_entity_initiative(ally, is_ambush and false)
		})
	
	# Añadir enemigos
	for enemy in enemies:
		initiative_order.append({
			"entity": enemy,
			"is_player": false,
			"is_ally": false,
			"initiative": calculate_entity_initiative(enemy, is_ambush and true)  # Bonificación si emboscan
		})
	
	# Ordenar por iniciativa (mayor a menor)
	initiative_order.sort_custom(Callable(self, "_sort_by_initiative"))
	
	# Emitir señal con el orden de iniciativa
	emit_signal("initiative_updated", initiative_order)

# Función de comparación para ordenar por iniciativa
func _sort_by_initiative(a: Dictionary, b: Dictionary) -> bool:
	return a["initiative"] > b["initiative"]

# Calcular iniciativa para una entidad
func calculate_entity_initiative(entity, has_advantage: bool) -> float:
	var base_initiative: float = 0.0
	
	if entity == player:
		# Para el jugador, usar atributos de GameManager
		var agility = GameManager.player_data["attributes"]["agility"]
		var perception = GameManager.player_data["attributes"]["perception"]
		base_initiative = agility * 1.5 + perception * 0.5
		
		# Bonificación por habilidades
		if GameManager.has_skill("combat", "quick_reflexes"):
			base_initiative += 5
		
		# Bonificación por equipo
		if GameManager.player_data["equipment"]["accessory"] == "reflex_enhancer":
			base_initiative += 3
	else:
		# Para enemigos y aliados, usar sus propios atributos
		# Asumimos que tienen una estructura similar a la del jugador
		base_initiative = entity.get_stat("agility") * 1.5 + entity.get_stat("perception") * 0.5
	
	# Aplicar ventaja/desventaja
	if has_advantage:
		base_initiative *= 1.5  # 50% de bonificación
	
	# Añadir un pequeño factor aleatorio (±10%)
	var random_factor = randf_range(0.9, 1.1)
	
	return base_initiative * random_factor

# Iniciar el siguiente turno en el orden de iniciativa
func start_next_turn() -> void:
	# Verificar si el combate ha terminado
	if current_state == CombatState.ENDING:
		return
	
	# Verificar límite de turnos para evitar combates infinitos
	if turn_count >= MAX_COMBAT_TURNS:
		end_combat(false)  # Empate o huida
		return
	
	# Incrementar contador de turnos si volvemos al principio del orden
	if current_turn_index >= initiative_order.size():
		current_turn_index = 0
		turn_count += 1
		
		# Aplicar efectos de inicio de ronda
		apply_turn_effects()
	
	# Obtener la entidad actual
	var turn_data = initiative_order[current_turn_index]
	current_entity = turn_data["entity"]
	
	# Verificar si la entidad sigue viva
	if not is_entity_active(current_entity):
		# Pasar al siguiente turno si la entidad está derrotada
		current_turn_index += 1
		start_next_turn()
		return
	
	# Establecer el estado según el tipo de entidad
	if turn_data["is_player"]:
		current_state = CombatState.PLAYER_TURN
	else:
		current_state = CombatState.ENEMY_TURN
		# Procesar turno de IA después de un breve retraso
		await get_tree().create_timer(0.5).timeout
		process_ai_turn(current_entity, turn_data["is_ally"])
	
	# Emitir señal de inicio de turno
	emit_signal("turn_started", current_entity)

# Procesar el turno de una entidad controlada por IA
func process_ai_turn(entity, is_ally: bool) -> void:
	# Verificar que sea el turno de la IA
	if current_state != CombatState.ENEMY_TURN or current_entity != entity:
		return
	
	# Determinar objetivo y acción
	var action_type: int
	var target
	var skill_id: String = ""
	var item_id: String = ""
	
	if is_ally:
		# Lógica para aliados (priorizar ayudar al jugador)
		if player.get_health_percentage() < 0.3 and entity.has_healing_ability():
			# Curar al jugador si está bajo de salud
			action_type = ActionType.SKILL
			target = player
			skill_id = entity.get_healing_skill_id()
		else:
			# Atacar a un enemigo
			action_type = ActionType.ATTACK
			target = get_optimal_target(entity, enemies, false)
	else:
		# Lógica para enemigos
		# Probabilidad de usar habilidad especial
		var use_skill_chance = 0.3  # 30% de probabilidad base
		
		# Aumentar probabilidad si el enemigo está débil
		if entity.get_health_percentage() < 0.4:
			use_skill_chance += 0.2
		
		if randf() < use_skill_chance and entity.has_combat_skills():
			action_type = ActionType.SKILL
			skill_id = entity.get_random_combat_skill()
			
			# Determinar objetivo según el tipo de habilidad
			if entity.is_skill_offensive(skill_id):
				# Habilidad ofensiva contra jugador o aliados
				var potential_targets = [player]
				potential_targets.append_array(allies)
				target = get_optimal_target(entity, potential_targets, true)
			else:
				# Habilidad defensiva o de apoyo para sí mismo u otro enemigo
				target = entity  # Por defecto, a sí mismo
				
				# A veces, ayudar a otros enemigos
				if randf() < 0.4 and enemies.size() > 1:
					var other_enemies = enemies.duplicate()
					other_enemies.erase(entity)
					target = other_enemies[randi() % other_enemies.size()]
		else:
			# Ataque básico
			action_type = ActionType.ATTACK
			
			# Priorizar al jugador, pero a veces atacar a los aliados
			if allies.size() > 0 and randf() < 0.3:
				target = allies[randi() % allies.size()]
			else:
				target = player
	
	# Ejecutar la acción después de una breve pausa para efectos visuales
	await get_tree().create_timer(0.8).timeout
	
	# Realizar la acción seleccionada
	match action_type:
		ActionType.ATTACK:
			perform_attack(entity, target)
		ActionType.SKILL:
			perform_skill(entity, target, skill_id)
		ActionType.DEFEND:
			perform_defend(entity)
	
	# Finalizar el turno después de otra breve pausa
	await get_tree().create_timer(0.5).timeout
	end_turn()

# Obtener el objetivo óptimo basado en la estrategia
func get_optimal_target(attacker, potential_targets: Array, is_offensive: bool) -> Object:
	# Filtrar objetivos activos
	var active_targets = []
	for target in potential_targets:
		if is_entity_active(target):
			active_targets.append(target)
	
	if active_targets.size() == 0:
		return null
	
	# Estrategia simple: si es ofensivo, atacar al más débil
	# Si es defensivo, ayudar al más dañado
	active_targets.sort_custom(Callable(self, "_sort_by_health"))
	
	if is_offensive:
		# Atacar al más débil (menor salud)
		return active_targets[0]
	else:
		# Ayudar al más dañado (menor salud)
		return active_targets[0]

# Función de comparación para ordenar por salud
func _sort_by_health(a: Object, b: Object) -> bool:
	return a.get_health_percentage() < b.get_health_percentage()

# Realizar un ataque básico
func perform_attack(attacker, target) -> void:
	# Verificar que ambas entidades estén activas
	if not is_entity_active(attacker) or not is_entity_active(target):
		return
	
	# Calcular daño base
	var damage = calculate_attack_damage(attacker, target)
	
	# Aplicar daño
	var result = apply_damage(target, damage, "physical", attacker)
	
	# Registrar acción en el log
	log_action(attacker, "attack", target, result)
	
	# Emitir señal
	emit_signal("action_performed", attacker, "attack", target, result)
	
	# Verificar si el combate ha terminado
	check_combat_end()

# Realizar una habilidad
func perform_skill(attacker, target, skill_id: String) -> void:
	# Verificar que ambas entidades estén activas
	if not is_entity_active(attacker) or not is_entity_active(target):
		return
	
	# Obtener datos de la habilidad
	var skill_data = get_skill_data(attacker, skill_id)
	
	if skill_data == null:
		# Habilidad no encontrada, realizar ataque normal
		perform_attack(attacker, target)
		return
	
	# Verificar si tiene suficiente energía/maná
	if not has_enough_energy(attacker, skill_data["energy_cost"]):
		# Energía insuficiente, realizar ataque normal
		perform_attack(attacker, target)
		return
	
	# Consumir energía
	consume_energy(attacker, skill_data["energy_cost"])
	
	# Aplicar efectos según el tipo de habilidad
	var result = {}
	
	match skill_data["type"]:
		"damage":
			# Calcular daño de la habilidad
			var damage = calculate_skill_damage(attacker, target, skill_data)
			
			# Aplicar daño
			result = apply_damage(target, damage, skill_data["damage_type"], attacker)
			
			# Aplicar efectos adicionales
			if skill_data.has("effects"):
				apply_skill_effects(target, skill_data["effects"], attacker)
		"heal":
			# Calcular curación
			var heal_amount = calculate_heal_amount(attacker, target, skill_data)
			
			# Aplicar curación
			result = apply_healing(target, heal_amount, attacker)
		"buff":
			# Aplicar mejora
			result = apply_buff(target, skill_data["buff_type"], skill_data["buff_value"], skill_data["buff_duration"])
		"debuff":
			# Aplicar penalización
			result = apply_debuff(target, skill_data["debuff_type"], skill_data["debuff_value"], skill_data["debuff_duration"])
		"special":
			# Efectos especiales personalizados
			result = apply_special_skill_effect(attacker, target, skill_data)
	
	# Registrar acción en el log
	log_action(attacker, "skill_" + skill_id, target, result)
	
	# Emitir señal
	emit_signal("action_performed", attacker, "skill_" + skill_id, target, result)
	
	# Verificar si el combate ha terminado
	check_combat_end()

# Realizar acción de defensa
func perform_defend(entity) -> void:
	# Aplicar estado de defensa
	var result = apply_buff(entity, "defense", 50, 1)  # 50% más de defensa por 1 turno
	
	# Registrar acción en el log
	log_action(entity, "defend", entity, result)
	
	# Emitir señal
	emit_signal("action_performed", entity, "defend", entity, result)

# Intentar huir del combate
func attempt_flee() -> bool:
	# Solo el jugador puede intentar huir
	if current_state != CombatState.PLAYER_TURN or current_entity != player:
		return false
	
	# Calcular probabilidad de huida
	var flee_chance = calculate_flee_chance()
	
	# Intentar huir
	var success = randf() < flee_chance
	
	# Registrar intento en el log
	log_action(player, "flee", null, {"success": success, "chance": flee_chance})
	
	# Emitir señal
	emit_signal("action_performed", player, "flee", null, {"success": success})
	
	if success:
		# Huida exitosa
		end_combat(false)
		return true
	else:
		# Huida fallida, perder el turno
		end_turn()
		return false

# Calcular probabilidad de huida
func calculate_flee_chance() -> float:
	# Base + bonificación por agilidad
	var chance = BASE_FLEE_CHANCE + (GameManager.player_data["attributes"]["agility"] * 0.02)
	
	# Bonificación por habilidades
	if GameManager.has_skill("combat", "escape_artist"):
		chance += 0.2
	
	# Penalización por número y nivel de enemigos
	var enemy_penalty = 0.0
	for enemy in enemies:
		if is_entity_active(enemy):
			enemy_penalty += 0.05  # 5% menos por cada enemigo activo
			
			# Enemigos más fuertes dificultan más la huida
			var level_diff = enemy.get_level() - GameManager.player_data["level"]
			if level_diff > 0:
				enemy_penalty += level_diff * 0.02
	
	chance -= enemy_penalty
	
	# Límites
	return clamp(chance, 0.1, 0.9)  # Mínimo 10%, máximo 90%

# Intentar persuadir a los enemigos
func attempt_persuade() -> bool:
	# Solo el jugador puede intentar persuadir
	if current_state != CombatState.PLAYER_TURN or current_entity != player:
		return false
	
	# Verificar si los enemigos son persuadibles
	var can_be_persuaded = true
	for enemy in enemies:
		if is_entity_active(enemy) and not enemy.is_persuadable():
			can_be_persuaded = false
			break
	
	if not can_be_persuaded:
		# Al menos un enemigo no puede ser persuadido
		log_action(player, "persuade", null, {"success": false, "reason": "immune"})
		emit_signal("action_performed", player, "persuade", null, {"success": false})
		return false
	
	# Calcular probabilidad de persuasión
	var persuade_chance = calculate_persuade_chance()
	
	# Intentar persuadir
	var success = randf() < persuade_chance
	
	# Registrar intento en el log
	log_action(player, "persuade", null, {"success": success, "chance": persuade_chance})
	
	# Emitir señal
	emit_signal("action_performed", player, "persuade", null, {"success": success})
	
	if success:
		# Persuasión exitosa
		# En lugar de terminar el combate, podría dar recompensas especiales
		end_combat(true, true)  # Victoria por persuasión
		return true
	else:
		# Persuasión fallida, perder el turno
		end_turn()
		return false

# Calcular probabilidad de persuasión
func calculate_persuade_chance() -> float:
	# Base + bonificación por carisma
	var chance = BASE_PERSUADE_CHANCE + (GameManager.player_data["attributes"]["charisma"] * 0.05)
	
	# Bonificación por habilidades
	if GameManager.has_skill("technology", "negotiator"):
		chance += 0.15
	
	# Bonificación/penalización por reputación con la facción
	var faction = enemies[0].get_faction()  # Asumimos que todos los enemigos son de la misma facción
	if GameManager.player_data["reputation"].has(faction):
		var rep = GameManager.player_data["reputation"][faction]
		chance += rep * 0.01  # +/- 1% por punto de reputación
	
	# Penalización por número y nivel de enemigos
	var enemy_penalty = 0.0
	for enemy in enemies:
		if is_entity_active(enemy):
			enemy_penalty += 0.08  # 8% menos por cada enemigo
			
			# Enemigos más fuertes son más difíciles de persuadir
			var level_diff = enemy.get_level() - GameManager.player_data["level"]
			if level_diff > 0:
				enemy_penalty += level_diff * 0.03
	
	chance -= enemy_penalty
	
	# Límites
	return clamp(chance, 0.05, 0.75)  # Mínimo 5%, máximo 75%

# Activar la Reacción Mutante (habilidad límite)
func activate_mutant_reaction() -> bool:
	# Solo el jugador puede usar la Reacción Mutante
	if current_state != CombatState.PLAYER_TURN or current_entity != player:
		return false
	
	# Verificar si está disponible
	if not is_player_mutant_reaction_available:
		return false
	
	# Verificar si tiene suficiente carga mutante
	if GameManager.player_data["mutant_charge"] < GameManager.player_data["max_mutant_charge"]:
		return false
	
	# Consumir toda la carga mutante
	GameManager.player_data["mutant_charge"] = 0
	emit_signal("entity_stats_changed", player, "mutant_charge", 0)
	
	# Marcar como usada
	is_player_mutant_reaction_available = false
	
	# Determinar el efecto según las habilidades del jugador
	var reaction_effect = determine_mutant_reaction_effect()
	
	# Aplicar el efecto
	var result = apply_mutant_reaction(reaction_effect)
	
	# Registrar en el log
	log_action(player, "mutant_reaction", null, result)
	
	# Emitir señal
	emit_signal("action_performed", player, "mutant_reaction", null, result)
	
	# No termina el turno, el jugador puede seguir actuando
	return true

# Determinar el efecto de la Reacción Mutante según las habilidades
func determine_mutant_reaction_effect() -> String:
	# Priorizar según las ramas de habilidad desbloqueadas
	var combat_level = GameManager.get_skill_tree_level("combat")
	var tech_level = GameManager.get_skill_tree_level("technology")
	var mutation_level = GameManager.get_skill_tree_level("mutation")
	
	# Determinar la rama dominante
	if mutation_level >= combat_level and mutation_level >= tech_level:
		# Rama de mutación dominante
		if GameManager.has_skill("mutation", "time_distortion"):
			return "time_freeze"
		elif GameManager.has_skill("mutation", "regenerative_burst"):
			return "full_heal"
		else:
			return "mutation_surge"
	elif combat_level >= tech_level:
		# Rama de combate dominante
		if GameManager.has_skill("combat", "berserker_rage"):
			return "berserk"
		elif GameManager.has_skill("combat", "tactical_mastery"):
			return "critical_strike"
		else:
			return "combat_surge"
	else:
		# Rama de tecnología dominante
		if GameManager.has_skill("technology", "override_protocol"):
			return "hack_enemies"
		elif GameManager.has_skill("technology", "energy_manipulation"):
			return "energy_blast"
		else:
			return "tech_surge"

# Aplicar el efecto de la Reacción Mutante
func apply_mutant_reaction(effect_type: String) -> Dictionary:
	var result = {"effect": effect_type}
	
	match effect_type:
		"time_freeze":
			# Otorga un turno extra al jugador y aliados
			result["extra_turns"] = 1 + allies.size()
			
			# Insertar turnos adicionales en la iniciativa
			var current_index = current_turn_index
			
			# Primero para el jugador
			initiative_order.insert(current_index + 1, {
				"entity": player,
				"is_player": true,
				"initiative": 999,  # Valor alto para asegurar que va primero
				"is_extra_turn": true
			})
			
			# Luego para cada aliado
			for i in range(allies.size()):
				if is_entity_active(allies[i]):
					initiative_order.insert(current_index + 2 + i, {
						"entity": allies[i],
						"is_player": false,
						"is_ally": true,
						"initiative": 998 - i,  # Valor alto pero en orden
						"is_extra_turn": true
					})
			
			# Actualizar señal de iniciativa
			emit_signal("initiative_updated", initiative_order)
		"full_heal":
			# Curación completa para el jugador y aliados
			var heal_amount = GameManager.player_data["max_health"] - GameManager.player_data["health"]
			GameManager.modify_player_stat("health", heal_amount)
			result["player_healed"] = heal_amount
			
			# Curar aliados
			result["allies_healed"] = []
			for ally in allies:
				if is_entity_active(ally):
					var ally_heal = ally.get_max_health() - ally.get_health()
					ally.heal(ally_heal)
					result["allies_healed"].append({"ally": ally, "amount": ally_heal})
		"mutation_surge":
			# Aumentar temporalmente todos los atributos
			var buff_amount = 5
			for attr in GameManager.player_data["attributes"].keys():
				GameManager.player_data["attributes"][attr] += buff_amount
			
			# Registrar para revertir al final del combate
			result["buffed_attributes"] = buff_amount
			
			# Efecto visual de transformación
			# En una implementación real, esto activaría una animación
		"berserk":
			# Aumentar daño y velocidad, pero reducir defensa
			apply_buff(player, "attack", 100, 3)  # +100% daño por 3 turnos
			apply_buff(player, "speed", 50, 3)   # +50% velocidad
			apply_debuff(player, "defense", -30, 3)  # -30% defensa
			result["buffs"] = [{"stat": "attack", "value": 100}, {"stat": "speed", "value": 50}]
			result["debuffs"] = [{"stat": "defense", "value": -30}]
		"critical_strike":
			# Ataque devastador a todos los enemigos
			result["damages"] = []
			for enemy in enemies:
				if is_entity_active(enemy):
					var damage = calculate_attack_damage(player, enemy) * 3  # Triple daño
					var dmg_result = apply_damage(enemy, damage, "physical", player)
					result["damages"].append({"enemy": enemy, "damage": dmg_result["damage"]})
		"combat_surge":
			# Recuperar energía y aumentar defensa
			GameManager.modify_player_stat("energy", GameManager.player_data["max_energy"])
			apply_buff(player, "defense", 70, 2)  # +70% defensa por 2 turnos
			result["energy_restored"] = GameManager.player_data["max_energy"]
			result["buffs"] = [{"stat": "defense", "value": 70}]
		"hack_enemies":
			# Desactivar temporalmente a los enemigos
			result["hacked_enemies"] = []
			for enemy in enemies:
				if is_entity_active(enemy) and enemy.is_hackable():
					apply_debuff(enemy, "stunned", 100, 2)  # Aturdido por 2 turnos
					result["hacked_enemies"].append(enemy)
		"energy_blast":
			# Daño de energía a todos los enemigos
			result["damages"] = []
			for enemy in enemies:
				if is_entity_active(enemy):
					var damage = GameManager.player_data["attributes"]["intelligence"] * 10
					var dmg_result = apply_damage(enemy, damage, "energy", player)
					result["damages"].append({"enemy": enemy, "damage": dmg_result["damage"]})
		"tech_surge":
			# Reparar aliados mecánicos y mejorar equipamiento
			result["repaired_allies"] = []
			for ally in allies:
				if is_entity_active(ally) and ally.is_mechanical():
					var heal_amount = ally.get_max_health() * 0.5  # 50% de curación
					ally.heal(int(heal_amount))
					result["repaired_allies"].append({"ally": ally, "amount": heal_amount})
			
			# Mejorar arma temporalmente
			apply_buff(player, "attack", 50, 3)  # +50% daño por 3 turnos
			result["buffs"] = [{"stat": "attack", "value": 50}]
	
	# Verificar si el combate ha terminado
	check_combat_end()
	
	return result

# Finalizar el turno actual
func end_turn() -> void:
	# Verificar que estemos en un estado válido
	if current_state == CombatState.ENDING or current_state == CombatState.INACTIVE:
		return
	
	# Emitir señal de fin de turno
	emit_signal("turn_ended", current_entity)
	
	# Procesar efectos de fin de turno
	process_end_of_turn_effects(current_entity)
	
	# Pasar al siguiente turno
	current_turn_index += 1
	start_next_turn()

# Procesar efectos al final del turno
func process_end_of_turn_effects(entity) -> void:
	# Reducir duración de efectos de estado
	reduce_status_effect_durations(entity)
	
	# Aplicar daño o curación por efectos de estado
	apply_status_effect_damage(entity)
	
	# Regeneración natural (si aplica)
	apply_natural_regeneration(entity)

# Finalizar el combate
func end_combat(victory: bool, persuaded: bool = false) -> void:
	# Cambiar estado
	current_state = CombatState.ENDING
	
	# Procesar resultados
	if victory:
		# Calcular recompensas
		var rewards = calculate_rewards(persuaded)
		
		# Otorgar recompensas
		grant_rewards(rewards)
		
		# Registrar victoria en el log
		log_action(null, "combat_end", null, {"result": "victory", "rewards": rewards})
	else:
		# Registrar derrota o huida en el log
		log_action(null, "combat_end", null, {"result": "escape"})
	
	# Limpiar efectos de combate
	cleanup_combat_effects()
	
	# Emitir señal de fin de combate
	emit_signal("combat_ended", victory)
	
	# Restaurar estado del juego
	GameManager.change_game_state(GameManager.GameState.EXPLORATION)

# Calcular recompensas del combate
func calculate_rewards(persuaded: bool) -> Dictionary:
	var rewards = {
		"experience": 0,
		"items": [],
		"currency": 0,
		"reputation": {}
	}
	
	# Calcular experiencia base según los enemigos derrotados
	for enemy in enemies:
		# Experiencia base por nivel
		var exp = enemy.get_level() * 10
		
		# Bonificación por enemigos más fuertes que el jugador
		var level_diff = enemy.get_level() - GameManager.player_data["level"]
		if level_diff > 0:
			exp += level_diff * 5
		
		rewards["experience"] += exp
		
		# Objetos y monedas
		var enemy_loot = enemy.get_loot()
		if enemy_loot.has("items"):
			rewards["items"].append_array(enemy_loot["items"])
		
		if enemy_loot.has("currency"):
			rewards["currency"] += enemy_loot["currency"]
	
	# Ajustar recompensas si fue por persuasión
	if persuaded:
		# Menos experiencia pero más reputación
		rewards["experience"] = int(rewards["experience"] * 0.7)
		
		# Añadir reputación con la facción
		var faction = enemies[0].get_faction()
		rewards["reputation"][faction] = 5  # +5 de reputación
		
		# Posibilidad de objetos especiales por persuasión
		if randf() < 0.3:  # 30% de probabilidad
			rewards["items"].append({"id": "faction_token_" + faction, "quantity": 1})
	
	# Bonificación por habilidades
	if GameManager.has_skill("technology", "scavenger"):
		# Más objetos
		var extra_items = int(rewards["items"].size() * 0.5)  # 50% más
		for i in range(extra_items):
			# En una implementación real, esto generaría objetos aleatorios
			rewards["items"].append({"id": "scrap_metal", "quantity": 1})
	
	if GameManager.has_skill("combat", "trophy_hunter"):
		# Más experiencia
		rewards["experience"] = int(rewards["experience"] * 1.2)  # 20% más
	
	return rewards

# Otorgar recompensas al jugador
func grant_rewards(rewards: Dictionary) -> void:
	# Experiencia
	if rewards.has("experience") and rewards["experience"] > 0:
		player.gain_experience(rewards["experience"])
	
	# Objetos
	if rewards.has("items"):
		for item in rewards["items"]:
			GameManager.add_to_inventory(item["id"], item["quantity"])
	
	# Moneda
	if rewards.has("currency") and rewards["currency"] > 0:
		GameManager.player_data["currency"] += rewards["currency"]
	
	# Reputación
	if rewards.has("reputation"):
		for faction in rewards["reputation"]:
			GameManager.modify_reputation(faction, rewards["reputation"][faction])
	
	# Carga mutante (siempre se gana algo en combate)
	var mutant_charge = int(rewards["experience"] * 0.1)  # 10% de la experiencia
	GameManager.modify_player_stat("mutant_charge", mutant_charge)

# Verificar si el combate ha terminado
func check_combat_end() -> bool:
	# Verificar si todos los enemigos están derrotados
	var all_enemies_defeated = true
	for enemy in enemies:
		if is_entity_active(enemy):
			all_enemies_defeated = false
			break
	
	if all_enemies_defeated:
		# Victoria
		end_combat(true)
		return true
	
	# Verificar si el jugador está derrotado
	if not is_entity_active(player):
		# Derrota
		end_combat(false)
		return true
	
	# Verificar si todos los aliados están derrotados y el jugador también
	var all_allies_defeated = true
	for ally in allies:
		if is_entity_active(ally):
			all_allies_defeated = false
			break
	
	if all_allies_defeated and not is_entity_active(player):
		# Derrota
		end_combat(false)
		return true
	
	return false

# Verificar si una entidad está activa (viva y puede actuar)
func is_entity_active(entity) -> bool:
	if entity == null:
		return false
	
	if entity == player:
		return GameManager.player_data["health"] > 0
	else:
		# Para enemigos y aliados
		return entity.is_alive() and not entity.has_status_effect("stunned")

# Obtener aliados activos
func get_active_allies() -> Array:
	# En una implementación real, esto buscaría aliados en el grupo del jugador
	# Por ahora, devolvemos una lista vacía
	return []

# Configurar efectos del entorno
func setup_environment_effects(environment: String) -> void:
	environment_effects.clear()
	
	match environment:
		"toxic_swamp":
			# Daño por toxicidad cada turno
			environment_effects["toxic_damage"] = 5
			# Reducción de velocidad
			environment_effects["speed_penalty"] = 20  # -20%
		"radiation_zone":
			# Daño por radiación
			environment_effects["radiation_damage"] = 3
			# Posibilidad de mutación (beneficio para el jugador)
			environment_effects["mutation_chance"] = 0.1  # 10%
		"abandoned_lab":
			# Bonificación para habilidades tecnológicas
			environment_effects["tech_bonus"] = 15  # +15%
		"unstable_ruins":
			# Posibilidad de derrumbe
			environment_effects["collapse_chance"] = 0.05  # 5% por turno
			environment_effects["collapse_damage"] = 20

# Aplicar efectos de inicio de combate
func apply_combat_start_effects() -> void:
	# Aplicar efectos del entorno al inicio
	if environment_effects.has("tech_bonus") and GameManager.has_skill("technology", "environmental_analysis"):
		# Bonificación adicional para jugadores con la habilidad adecuada
		apply_buff(player, "tech_power", environment_effects["tech_bonus"] * 2, 3)
	
	# Aplicar efectos de habilidades pasivas
	if GameManager.has_skill("combat", "battle_ready"):
		# Bonificación de iniciativa ya aplicada en calculate_initiative
		# Bonificación de defensa al inicio del combate
		apply_buff(player, "defense", 25, 2)  # +25% defensa por 2 turnos
	
	if GameManager.has_skill("mutation", "adaptive_physiology"):
		# Resistencia a efectos negativos del entorno
		apply_buff(player, "environmental_resistance", 50, -1)  # 50% de resistencia, duración indefinida

# Aplicar efectos al inicio de cada ronda
func apply_turn_effects() -> void:
	# Aplicar efectos del entorno
	if environment_effects.has("toxic_damage"):
		# Verificar resistencia
		var resistance = 0
		if player.has_status_effect("environmental_resistance"):
			resistance = player.get_status_effect_value("environmental_resistance")
		
		# Aplicar daño reducido por resistencia
		var damage = int(environment_effects["toxic_damage"] * (1 - resistance / 100.0))
		if damage > 0:
			apply_damage(player, damage, "toxic", null)
		
		# También a los aliados
		for ally in allies:
			if is_entity_active(ally):
				apply_damage(ally, damage, "toxic", null)
	
	if environment_effects.has("radiation_damage"):
		# Similar al daño tóxico
		var resistance = 0
		if player.has_status_effect("environmental_resistance"):
			resistance = player.get_status_effect_value("environmental_resistance")
		
		var damage = int(environment_effects["radiation_damage"] * (1 - resistance / 100.0))
		if damage > 0:
			apply_damage(player, damage, "radiation", null)
		
		# Posibilidad de mutación beneficiosa
		if environment_effects.has("mutation_chance") and randf() < environment_effects["mutation_chance"]:
			# Efecto positivo aleatorio
			var effect = ["attack", "defense", "speed"][randi() % 3]
			apply_buff(player, effect, 15, 3)  # +15% por 3 turnos
	
	if environment_effects.has("collapse_chance") and randf() < environment_effects["collapse_chance"]:
		# Derrumbe que afecta a todos
		var damage = environment_effects["collapse_damage"]
		
		# Daño al jugador
		apply_damage(player, damage, "physical", null)
		
		# Daño a aliados
		for ally in allies:
			if is_entity_active(ally):
				apply_damage(ally, damage, "physical", null)
		
		# Daño a enemigos
		for enemy in enemies:
			if is_entity_active(enemy):
				apply_damage(enemy, damage, "physical", null)

# Calcular daño de ataque
func calculate_attack_damage(attacker, target) -> int:
	var base_damage = 0
	
	if attacker == player:
		# Daño base del jugador
		var strength = GameManager.player_data["attributes"]["strength"]
		base_damage = strength * 2
		
		# Bonificación por arma equipada
		if GameManager.player_data["equipment"]["weapon"] != null:
			# En una implementación real, esto obtendría el daño del arma
			base_damage += 10  # Valor de ejemplo
	else:
		# Daño base de enemigos y aliados
		base_damage = attacker.get_attack_damage()
	
	# Aplicar modificadores de estado
	if attacker.has_status_effect("attack"):
		var modifier = attacker.get_status_effect_value("attack")
		base_damage = int(base_damage * (1 + modifier / 100.0))
	
	# Calcular reducción de daño del objetivo
	var damage_reduction = 0
	
	if target == player:
		# Reducción del jugador
		var resistance = GameManager.player_data["attributes"]["resistance"]
		damage_reduction = resistance * 0.5  # 0.5% por punto
		
		# Bonificación por armadura
		if GameManager.player_data["equipment"]["armor"] != null:
			# En una implementación real, esto obtendría la defensa de la armadura
			damage_reduction += 10  # Valor de ejemplo
	else:
		# Reducción de enemigos y aliados
		damage_reduction = target.get_defense()
	
	# Aplicar modificadores de estado de defensa
	if target.has_status_effect("defense"):
		var modifier = target.get_status_effect_value("defense")
		damage_reduction += modifier
	
	# Calcular daño final (mínimo 1)
	var final_damage = int(base_damage * (1 - damage_reduction / 100.0))
	return max(1, final_damage)

# Calcular daño de habilidad
func calculate_skill_damage(attacker, target, skill_data: Dictionary) -> int:
	var base_damage = skill_data["base_damage"]
	
	# Modificar según atributos
	if attacker == player:
		# Para el jugador, usar el atributo principal según el tipo de habilidad
		var attribute_value = 0
		
		match skill_data["attribute"]:
			"strength":
				attribute_value = GameManager.player_data["attributes"]["strength"]
			"intelligence":
				attribute_value = GameManager.player_data["attributes"]["intelligence"]
			"will":
				attribute_value = GameManager.player_data["attributes"]["will"]
			_:
				# Por defecto, usar fuerza
				attribute_value = GameManager.player_data["attributes"]["strength"]
		
		base_damage += attribute_value * skill_data["attribute_scaling"]
	else:
		# Para enemigos y aliados
		base_damage = skill_data["base_damage"]
		
		# Escalar con nivel
		base_damage += attacker.get_level() * 2
	
	# Aplicar bonificaciones según el tipo de habilidad
	if attacker == player:
		match skill_data["skill_tree"]:
			"combat":
				if GameManager.has_skill("combat", "combat_mastery"):
					base_damage *= 1.2  # 20% más de daño
			"technology":
				if GameManager.has_skill("technology", "advanced_systems"):
					base_damage *= 1.15  # 15% más de daño
			"mutation":
				if GameManager.has_skill("mutation", "evolved_powers"):
					base_damage *= 1.25  # 25% más de daño
	
	# Aplicar modificadores de estado
	if attacker.has_status_effect("attack"):
		var modifier = attacker.get_status_effect_value("attack")
		base_damage = int(base_damage * (1 + modifier / 100.0))
	
	# Calcular resistencia del objetivo según el tipo de daño
	var damage_reduction = 0
	
	if target == player:
		# Resistencia del jugador según el tipo de daño
		match skill_data["damage_type"]:
			"physical":
				damage_reduction = GameManager.player_data["attributes"]["resistance"] * 0.5
			"energy":
				# Menos resistencia contra energía
				damage_reduction = GameManager.player_data["attributes"]["resistance"] * 0.3
			"toxic":
				# Resistencia contra toxinas
				if GameManager.has_skill("mutation", "toxic_adaptation"):
					damage_reduction = GameManager.player_data["attributes"]["resistance"] * 0.8
				else:
					damage_reduction = GameManager.player_data["attributes"]["resistance"] * 0.4
			"psychic":
				# La resistencia psíquica depende de la voluntad
				damage_reduction = GameManager.player_data["attributes"]["will"] * 0.6
			_:
				# Tipo de daño desconocido
				damage_reduction = GameManager.player_data["attributes"]["resistance"] * 0.3
	else:
		# Resistencia de enemigos y aliados
		damage_reduction = target.get_resistance_to_damage_type(skill_data["damage_type"])
	
	# Aplicar modificadores de estado de defensa
	if target.has_status_effect("defense"):
		var modifier = target.get_status_effect_value("defense")
		damage_reduction += modifier
	
	# Calcular daño final (mínimo 1)
	var final_damage = int(base_damage * (1 - damage_reduction / 100.0))
	return max(1, final_damage)

# Calcular cantidad de curación
func calculate_heal_amount(healer, target, skill_data: Dictionary) -> int:
	var base_heal = skill_data["base_heal"]
	
	# Modificar según atributos
	if healer == player:
		# Para el jugador, usar inteligencia o voluntad
		var attribute_value = 0
		
		match skill_data["attribute"]:
			"intelligence":
				attribute_value = GameManager.player_data["attributes"]["intelligence"]
			"will":
				attribute_value = GameManager.player_data["attributes"]["will"]
			_:
				# Por defecto, usar inteligencia
				attribute_value = GameManager.player_data["attributes"]["intelligence"]
		
		base_heal += attribute_value * skill_data["attribute_scaling"]
	else:
		# Para enemigos y aliados
		base_heal = skill_data["base_heal"]
		
		# Escalar con nivel
		base_heal += healer.get_level() * 2
	
	# Aplicar bonificaciones según el tipo de habilidad
	if healer == player:
		match skill_data["skill_tree"]:
			"technology":
				if GameManager.has_skill("technology", "medical_expertise"):
					base_heal *= 1.3  # 30% más de curación
			"mutation":
				if GameManager.has_skill("mutation", "regenerative_cells"):
					base_heal *= 1.4  # 40% más de curación
	
	# Aplicar modificadores de estado
	if healer.has_status_effect("healing_power"):
		var modifier = healer.get_status_effect_value("healing_power")
		base_heal = int(base_heal * (1 + modifier / 100.0))
	
	# Aplicar modificadores del objetivo
	if target.has_status_effect("healing_received"):
		var modifier = target.get_status_effect_value("healing_received")
		base_heal = int(base_heal * (1 + modifier / 100.0))
	
	return max(1, base_heal)

# Aplicar daño a una entidad
func apply_damage(target, amount: int, damage_type: String, attacker) -> Dictionary:
	var result = {
		"damage": amount,
		"type": damage_type,
		"critical": false
	}
	
	# Verificar si es un golpe crítico
	var is_critical = false
	if attacker != null:
		var crit_chance = 0.05  # 5% base
		
		if attacker == player:
			# Aumentar probabilidad según percepción
			crit_chance += GameManager.player_data["attributes"]["perception"] * 0.01
			
			# Bonificación por habilidades
			if GameManager.has_skill("combat", "critical_strike"):
				crit_chance += 0.1
		else:
			# Para enemigos y aliados
			crit_chance += attacker.get_crit_chance()
		
		is_critical = randf() < crit_chance
		
		if is_critical:
			# Duplicar daño en crítico
			amount *= 2
			result["damage"] = amount
			result["critical"] = true
	
	# Aplicar el daño
	if target == player:
		# Daño al jugador
		GameManager.modify_player_stat("health", -amount)
		
		# Aumentar carga mutante
		var mutant_charge_gain = int(amount * 0.2)  # 20% del daño recibido
		GameManager.modify_player_stat("mutant_charge", mutant_charge_gain)
		result["mutant_charge_gain"] = mutant_charge_gain
	else:
		# Daño a enemigos y aliados
		target.take_damage(amount)
	
	# Efectos visuales y sonoros
	# En una implementación real, esto activaría animaciones
	
	return result

# Aplicar curación a una entidad
func apply_healing(target, amount: int, healer) -> Dictionary:
	var result = {
		"heal": amount
	}
	
	# Aplicar la curación
	if target == player:
		# Curación al jugador
		GameManager.modify_player_stat("health", amount)
	else:
		# Curación a enemigos y aliados
		target.heal(amount)
	
	# Efectos visuales y sonoros
	# En una implementación real, esto activaría animaciones
	
	return result

# Aplicar una mejora a una entidad
func apply_buff(target, buff_type: String, value: int, duration: int) -> Dictionary:
	var result = {
		"buff_type": buff_type,
		"value": value,
		"duration": duration
	}
	
	# Aplicar la mejora
	if target == player:
		# Para el jugador, almacenar en GameManager
		if not GameManager.player_data.has("status_effects"):
			GameManager.player_data["status_effects"] = {}
		
		GameManager.player_data["status_effects"][buff_type] = {
			"value": value,
			"duration": duration
		}
	else:
		# Para enemigos y aliados
		target.apply_status_effect(buff_type, value, duration)
	
	# Efectos visuales
	# En una implementación real, esto activaría animaciones
	
	return result

# Aplicar una penalización a una entidad
func apply_debuff(target, debuff_type: String, value: int, duration: int) -> Dictionary:
	# Similar a apply_buff pero para efectos negativos
	return apply_buff(target, debuff_type, value, duration)

# Aplicar efectos especiales de habilidades
func apply_special_skill_effect(attacker, target, skill_data: Dictionary) -> Dictionary:
	var result = {}
	
	# Implementar efectos especiales según el ID de la habilidad
	match skill_data["id"]:
		"time_distortion":
			# Ralentizar al objetivo
			apply_debuff(target, "speed", -50, 2)  # -50% velocidad por 2 turnos
			result["effect"] = "slowed"
		"mind_control":
			# Controlar temporalmente a un enemigo
			if target.is_controllable():
				apply_buff(target, "controlled", 100, 1)  # Controlado por 1 turno
				result["effect"] = "controlled"
			else:
				# Inmune al control mental
				result["effect"] = "immune"
		"energy_drain":
			# Robar energía
			var drain_amount = skill_data["drain_amount"]
			
			# Reducir energía del objetivo
			if target == player:
				GameManager.modify_player_stat("energy", -drain_amount)
			else:
				target.modify_energy(-drain_amount)
			
			# Aumentar energía del atacante
			if attacker == player:
				GameManager.modify_player_stat("energy", drain_amount)
			else:
				attacker.modify_energy(drain_amount)
			
			result["drain_amount"] = drain_amount
		"adaptive_armor":
			# Resistencia adaptativa al tipo de daño del último ataque
			var last_damage_type = "physical"  # Por defecto
			
			# En una implementación real, esto obtendría el último tipo de daño recibido
			
			apply_buff(attacker, "resistance_" + last_damage_type, 75, 3)  # 75% resistencia por 3 turnos
			result["resistance_type"] = last_damage_type
		_:
			# Efecto desconocido
			result["effect"] = "unknown"
	
	return result

# Verificar si una entidad tiene suficiente energía
func has_enough_energy(entity, cost: int) -> bool:
	if entity == player:
		return GameManager.player_data["energy"] >= cost
	else:
		return entity.get_energy() >= cost

# Consumir energía de una entidad
func consume_energy(entity, amount: int) -> void:
	if entity == player:
		GameManager.modify_player_stat("energy", -amount)
	else:
		entity.modify_energy(-amount)

# Reducir la duración de los efectos de estado
func reduce_status_effect_durations(entity) -> void:
	if entity == player:
		# Para el jugador
		if GameManager.player_data.has("status_effects"):
			var effects_to_remove = []
			
			for effect in GameManager.player_data["status_effects"]:
				var data = GameManager.player_data["status_effects"][effect]
				
				# Reducir duración si no es permanente
				if data["duration"] > 0:
					data["duration"] -= 1
					
					# Marcar para eliminar si ha expirado
					if data["duration"] <= 0:
						effects_to_remove.append(effect)
			
			# Eliminar efectos expirados
			for effect in effects_to_remove:
				GameManager.player_data["status_effects"].erase(effect)
	else:
		# Para enemigos y aliados
		entity.reduce_status_effect_durations()

# Aplicar daño o curación por efectos de estado
func apply_status_effect_damage(entity) -> void:
	if entity == player:
		# Para el jugador
		if GameManager.player_data.has("status_effects"):
			# Efectos de daño continuo
			if GameManager.player_data["status_effects"].has("burning"):
				var damage = GameManager.player_data["status_effects"]["burning"]["value"]
				GameManager.modify_player_stat("health", -damage)
			
			if GameManager.player_data["status_effects"].has("poisoned"):
				var damage = GameManager.player_data["status_effects"]["poisoned"]["value"]
				GameManager.modify_player_stat("health", -damage)
			
			# Efectos de curación continua
			if GameManager.player_data["status_effects"].has("regeneration"):
				var heal = GameManager.player_data["status_effects"]["regeneration"]["value"]
				GameManager.modify_player_stat("health", heal)
	else:
		# Para enemigos y aliados
		entity.apply_status_effect_damage()

# Aplicar regeneración natural
func apply_natural_regeneration(entity) -> void:
	# Solo aplicar fuera de combate o con habilidades específicas
	if entity == player and GameManager.has_skill("mutation", "natural_recovery"):
		# Regenerar un pequeño porcentaje de salud
		var regen_amount = int(GameManager.player_data["max_health"] * 0.05)  # 5%
		GameManager.modify_player_stat("health", regen_amount)
		
		# Regenerar energía
		var energy_regen = int(GameManager.player_data["max_energy"] * 0.1)  # 10%
		GameManager.modify_player_stat("energy", energy_regen)

# Limpiar efectos de combate
func cleanup_combat_effects() -> void:
	# Limpiar variables de estado
	current_state = CombatState.INACTIVE
	initiative_order.clear()
	current_turn_index = 0
	current_entity = null
	enemies.clear()
	allies.clear()
	environment_effects.clear()
	
	# Eliminar efectos temporales del jugador
	if GameManager.player_data.has("status_effects"):
		var effects_to_keep = []
		
		# Mantener solo efectos permanentes
		for effect in GameManager.player_data["status_effects"]:
			var data = GameManager.player_data["status_effects"][effect]
			if data["duration"] < 0:  # Duración negativa indica efecto permanente
				effects_to_keep.append(effect)
		
		# Crear nuevo diccionario solo con efectos permanentes
		var new_effects = {}
		for effect in effects_to_keep:
			new_effects[effect] = GameManager.player_data["status_effects"][effect]
		
		GameManager.player_data["status_effects"] = new_effects

# Obtener datos de una habilidad
func get_skill_data(entity, skill_id: String) -> Dictionary:
	if entity == player:
		# Para el jugador, obtener de GameManager
		return GameManager.get_skill_data(skill_id)
	else:
		# Para enemigos y aliados
		return entity.get_skill_data(skill_id)

# Registrar una acción en el log de combate
func log_action(entity, action: String, target, result: Dictionary) -> void:
	var log_entry = {
		"turn": turn_count,
		"action": action,
		"result": result,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	if entity != null:
		if entity == player:
			log_entry["entity"] = "player"
		else:
			log_entry["entity"] = entity.get_entity_id()
	
	if target != null:
		if target == player:
			log_entry["target"] = "player"
		else:
			log_entry["target"] = target.get_entity_id()
	
	combat_log.append(log_entry)

# Manejador de cambio de estado del juego
func _on_game_state_changed(old_state: int, new_state: int) -> void:
	# Limpiar combate si salimos del estado de combate
	if old_state == GameManager.GameState.COMBAT and new_state != GameManager.GameState.COMBAT:
		cleanup_combat_effects()