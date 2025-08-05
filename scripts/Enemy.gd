extends CharacterBody2D

# Señales
signal health_changed(new_health, max_health)
signal died(self_reference)
signal status_effect_applied(effect_name, duration)

# Enumeraciones
enum EnemyType {
	HUMANOID,
	BEAST,
	ROBOT,
	MUTANT,
	SPIRIT
}

enum Faction {
	NONE,
	SCRAP_RAIDERS,
	WANDERERS,
	TECH_COLLECTIVE,
	CHILDREN_OF_ATOM,
	WILD
}

# Variables de estadísticas base
export var enemy_name: String = "Enemigo"
export var enemy_type: int = EnemyType.HUMANOID
export var faction: int = Faction.NONE
export var level: int = 1
export var base_health: int = 50
export var base_energy: int = 30
export var is_boss: bool = false
export var is_unique: bool = false
export var is_persuadable: bool = true
export var is_hackable: bool = false
export var is_mechanical: bool = false

# Variables de atributos
export var strength: int = 5
export var agility: int = 5
export var resistance: int = 5
export var perception: int = 5
export var intelligence: int = 5
export var will: int = 5
export var charisma: int = 5

# Variables de estado
var current_health: int
var max_health: int
var current_energy: int
var max_energy: int
var is_alive: bool = true
var status_effects: Dictionary = {}
var loot_table: Array = []
var combat_skills: Array = []
var dialogue_id: String = ""
var entity_id: String = ""

# Referencias a nodos
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var effects_container = $EffectsContainer

# Función de inicialización
func _ready() -> void:
	# Generar ID único
	entity_id = enemy_name.to_lower().replace(" ", "_") + "_" + str(randi())
	
	# Inicializar estadísticas
	initialize_stats()
	
	# Configurar tabla de botín según el tipo
	setup_loot_table()
	
	# Configurar habilidades de combate
	setup_combat_skills()

# Inicializar estadísticas
func initialize_stats() -> void:
	# Calcular salud y energía máximas según nivel y atributos
	max_health = base_health + (level * 5) + (resistance * 3)
	max_energy = base_energy + (level * 3) + (will * 2)
	
	# Si es un jefe, aumentar estadísticas
	if is_boss:
		max_health *= 2
		max_energy *= 1.5
		
	# Inicializar valores actuales
	current_health = max_health
	current_energy = max_energy

# Configurar tabla de botín
func setup_loot_table() -> void:
	# Botín básico según tipo
	match enemy_type:
		EnemyType.HUMANOID:
			loot_table.append({"id": "scrap_metal", "chance": 0.7, "quantity": [1, 3]})
			loot_table.append({"id": "bandages", "chance": 0.5, "quantity": [1, 2]})
			loot_table.append({"id": "old_coin", "chance": 0.3, "quantity": [5, 15]})
		EnemyType.BEAST:
			loot_table.append({"id": "raw_meat", "chance": 0.8, "quantity": [1, 3]})
			loot_table.append({"id": "hide", "chance": 0.6, "quantity": [1, 2]})
			loot_table.append({"id": "fang", "chance": 0.4, "quantity": [1, 2]})
		EnemyType.ROBOT:
			loot_table.append({"id": "circuit_board", "chance": 0.8, "quantity": [1, 2]})
			loot_table.append({"id": "energy_cell", "chance": 0.5, "quantity": [1, 3]})
			loot_table.append({"id": "processor_chip", "chance": 0.3, "quantity": [1, 1]})
		EnemyType.MUTANT:
			loot_table.append({"id": "mutant_tissue", "chance": 0.7, "quantity": [1, 3]})
			loot_table.append({"id": "toxic_gland", "chance": 0.4, "quantity": [1, 1]})
			loot_table.append({"id": "strange_crystal", "chance": 0.2, "quantity": [1, 1]})
		EnemyType.SPIRIT:
			loot_table.append({"id": "ectoplasm", "chance": 0.6, "quantity": [1, 2]})
			loot_table.append({"id": "memory_fragment", "chance": 0.4, "quantity": [1, 3]})
			loot_table.append({"id": "void_essence", "chance": 0.2, "quantity": [1, 1]})
	
	# Botín adicional según facción
	match faction:
		Faction.SCRAP_RAIDERS:
			loot_table.append({"id": "raider_emblem", "chance": 0.3, "quantity": [1, 1]})
			loot_table.append({"id": "makeshift_weapon", "chance": 0.2, "quantity": [1, 1]})
		Faction.WANDERERS:
			loot_table.append({"id": "wanderer_map", "chance": 0.3, "quantity": [1, 1]})
			loot_table.append({"id": "survival_kit", "chance": 0.2, "quantity": [1, 1]})
		Faction.TECH_COLLECTIVE:
			loot_table.append({"id": "tech_manual", "chance": 0.3, "quantity": [1, 1]})
			loot_table.append({"id": "advanced_component", "chance": 0.2, "quantity": [1, 1]})
		Faction.CHILDREN_OF_ATOM:
			loot_table.append({"id": "ritual_symbol", "chance": 0.3, "quantity": [1, 1]})
			loot_table.append({"id": "mutation_serum", "chance": 0.2, "quantity": [1, 1]})
	
	# Botín especial para jefes y enemigos únicos
	if is_boss or is_unique:
		loot_table.append({"id": "rare_component", "chance": 1.0, "quantity": [1, 1]})
		loot_table.append({"id": "blueprint_fragment", "chance": 0.8, "quantity": [1, 1]})
		
		# Moneda especial
		loot_table.append({"id": "old_coin", "chance": 1.0, "quantity": [20, 50]})

# Configurar habilidades de combate
func setup_combat_skills() -> void:
	# Habilidades básicas según tipo
	match enemy_type:
		EnemyType.HUMANOID:
			combat_skills.append({
				"id": "quick_strike",
				"name": "Golpe Rápido",
				"type": "damage",
				"damage_type": "physical",
				"base_damage": 8 + level * 2,
				"energy_cost": 5,
				"attribute": "strength",
				"attribute_scaling": 1.2,
				"is_offensive": true
			})
			combat_skills.append({
				"id": "defensive_stance",
				"name": "Postura Defensiva",
				"type": "buff",
				"buff_type": "defense",
				"buff_value": 30,
				"buff_duration": 2,
				"energy_cost": 8,
				"is_offensive": false
			})
		EnemyType.BEAST:
			combat_skills.append({
				"id": "feral_bite",
				"name": "Mordisco Salvaje",
				"type": "damage",
				"damage_type": "physical",
				"base_damage": 12 + level * 2,
				"energy_cost": 7,
				"attribute": "strength",
				"attribute_scaling": 1.5,
				"is_offensive": true
			})
			combat_skills.append({
				"id": "intimidating_roar",
				"name": "Rugido Intimidante",
				"type": "debuff",
				"debuff_type": "attack",
				"debuff_value": -20,
				"debuff_duration": 2,
				"energy_cost": 10,
				"is_offensive": true
			})
		EnemyType.ROBOT:
			combat_skills.append({
				"id": "laser_beam",
				"name": "Rayo Láser",
				"type": "damage",
				"damage_type": "energy",
				"base_damage": 15 + level * 2,
				"energy_cost": 12,
				"attribute": "intelligence",
				"attribute_scaling": 1.3,
				"is_offensive": true
			})
			combat_skills.append({
				"id": "system_repair",
				"name": "Reparación de Sistema",
				"type": "heal",
				"base_heal": 10 + level * 2,
				"energy_cost": 15,
				"attribute": "intelligence",
				"attribute_scaling": 1.0,
				"is_offensive": false
			})
		EnemyType.MUTANT:
			combat_skills.append({
				"id": "toxic_spit",
				"name": "Escupitajo Tóxico",
				"type": "damage",
				"damage_type": "toxic",
				"base_damage": 10 + level * 2,
				"energy_cost": 8,
				"attribute": "will",
				"attribute_scaling": 1.2,
				"effects": [{"type": "poisoned", "value": 3, "duration": 3}],
				"is_offensive": true
			})
			combat_skills.append({
				"id": "regenerate",
				"name": "Regeneración",
				"type": "buff",
				"buff_type": "regeneration",
				"buff_value": 5 + level,
				"buff_duration": 3,
				"energy_cost": 12,
				"is_offensive": false
			})
		EnemyType.SPIRIT:
			combat_skills.append({
				"id": "mind_blast",
				"name": "Explosión Mental",
				"type": "damage",
				"damage_type": "psychic",
				"base_damage": 14 + level * 2,
				"energy_cost": 10,
				"attribute": "will",
				"attribute_scaling": 1.4,
				"is_offensive": true
			})
			combat_skills.append({
				"id": "phase_shift",
				"name": "Cambio de Fase",
				"type": "buff",
				"buff_type": "evasion",
				"buff_value": 40,
				"buff_duration": 2,
				"energy_cost": 15,
				"is_offensive": false
			})
	
	# Habilidades adicionales para jefes y enemigos únicos
	if is_boss or is_unique:
		# Habilidad especial según tipo
		match enemy_type:
			EnemyType.HUMANOID:
				combat_skills.append({
					"id": "battle_cry",
					"name": "Grito de Batalla",
					"type": "buff",
					"buff_type": "attack",
					"buff_value": 50,
					"buff_duration": 3,
					"energy_cost": 20,
					"is_offensive": false
				})
			EnemyType.BEAST:
				combat_skills.append({
					"id": "savage_fury",
					"name": "Furia Salvaje",
					"type": "damage",
					"damage_type": "physical",
					"base_damage": 25 + level * 3,
					"energy_cost": 25,
					"attribute": "strength",
					"attribute_scaling": 2.0,
					"is_offensive": true
				})
			EnemyType.ROBOT:
				combat_skills.append({
					"id": "overcharge",
					"name": "Sobrecarga",
					"type": "damage",
					"damage_type": "energy",
					"base_damage": 30 + level * 3,
					"energy_cost": 30,
					"attribute": "intelligence",
					"attribute_scaling": 1.8,
					"is_offensive": true
				})
			EnemyType.MUTANT:
				combat_skills.append({
					"id": "mutation_surge",
					"name": "Oleada de Mutación",
					"type": "special",
					"id": "mutation_surge",
					"energy_cost": 35,
					"is_offensive": true
				})
			EnemyType.SPIRIT:
				combat_skills.append({
					"id": "reality_warp",
					"name": "Distorsión de la Realidad",
					"type": "special",
					"id": "reality_warp",
					"energy_cost": 40,
					"is_offensive": true
				})

# Recibir daño
func take_damage(amount: int) -> void:
	# Verificar si está vivo
	if not is_alive:
		return
	
	# Aplicar daño
	current_health -= amount
	
	# Emitir señal de cambio de salud
	emit_signal("health_changed", current_health, max_health)
	
	# Verificar si ha muerto
	if current_health <= 0:
		die()
	
	# Efectos visuales de daño
	show_damage_effect(amount)

# Mostrar efecto visual de daño
func show_damage_effect(amount: int) -> void:
	# Parpadeo rojo
	sprite.modulate = Color(1.5, 0.3, 0.3, 1.0)
	
	# Crear etiqueta de daño flotante
	var damage_label = Label.new()
	damage_label.text = str(amount)
	damage_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	effects_container.add_child(damage_label)
	
	# Posicionar la etiqueta
	damage_label.position = Vector2(randf_range(-20, 20), -30)
	
	# Animar la etiqueta
	var tween = create_tween()
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 40, 0.8)
	tween.parallel().tween_property(damage_label, "modulate:a", 0, 0.8)
	tween.tween_callback(Callable(damage_label, "queue_free"))
	
	# Restaurar color normal después de un breve tiempo
	var color_tween = create_tween()
	color_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.3)

# Curar al enemigo
func heal(amount: int) -> void:
	# Verificar si está vivo
	if not is_alive:
		return
	
	# Aplicar curación
	current_health += amount
	
	# Limitar a la salud máxima
	if current_health > max_health:
		current_health = max_health
	
	# Emitir señal de cambio de salud
	emit_signal("health_changed", current_health, max_health)
	
	# Efectos visuales de curación
	show_heal_effect(amount)

# Mostrar efecto visual de curación
func show_heal_effect(amount: int) -> void:
	# Parpadeo verde
	sprite.modulate = Color(0.3, 1.5, 0.3, 1.0)
	
	# Crear etiqueta de curación flotante
	var heal_label = Label.new()
	heal_label.text = "+" + str(amount)
	heal_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	effects_container.add_child(heal_label)
	
	# Posicionar la etiqueta
	heal_label.position = Vector2(randf_range(-20, 20), -30)
	
	# Animar la etiqueta
	var tween = create_tween()
	tween.tween_property(heal_label, "position:y", heal_label.position.y - 40, 0.8)
	tween.parallel().tween_property(heal_label, "modulate:a", 0, 0.8)
	tween.tween_callback(Callable(heal_label, "queue_free"))
	
	# Restaurar color normal después de un breve tiempo
	var color_tween = create_tween()
	color_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.3)

# Muerte del enemigo
func die() -> void:
	# Marcar como muerto
	is_alive = false
	current_health = 0
	
	# Emitir señal de muerte
	emit_signal("died", self)
	
	# Reproducir animación de muerte si existe
	if animation_player.has_animation("death"):
		animation_player.play("death")
	else:
		# Efecto visual simple
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0, 1.0)
		tween.tween_callback(Callable(self, "queue_free"))

# Aplicar efecto de estado
func apply_status_effect(effect_name: String, value: int, duration: int) -> void:
	# Guardar efecto
	status_effects[effect_name] = {
		"value": value,
		"duration": duration
	}
	
	# Emitir señal
	emit_signal("status_effect_applied", effect_name, duration)
	
	# Efectos visuales según el tipo
	match effect_name:
		"burning":
			# Efecto de fuego
			sprite.modulate = Color(1.5, 0.5, 0.2, 1.0)
		"poisoned":
			# Efecto de veneno
			sprite.modulate = Color(0.5, 1.5, 0.5, 1.0)
		"stunned":
			# Efecto de aturdimiento
			sprite.modulate = Color(1.0, 1.0, 0.3, 1.0)
		"frozen":
			# Efecto de congelación
			sprite.modulate = Color(0.3, 0.3, 1.5, 1.0)
		_:
			# Efecto genérico
			sprite.modulate = Color(1.2, 1.2, 1.2, 1.0)
	
	# Restaurar color después de un breve tiempo
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5)

# Reducir duración de efectos de estado
func reduce_status_effect_durations() -> void:
	var effects_to_remove = []
	
	for effect in status_effects:
		var data = status_effects[effect]
		
		# Reducir duración si no es permanente
		if data["duration"] > 0:
			data["duration"] -= 1
			
			# Marcar para eliminar si ha expirado
			if data["duration"] <= 0:
				effects_to_remove.append(effect)
	
	# Eliminar efectos expirados
	for effect in effects_to_remove:
		status_effects.erase(effect)

# Aplicar daño o curación por efectos de estado
func apply_status_effect_damage() -> void:
	# Efectos de daño continuo
	if status_effects.has("burning"):
		var damage = status_effects["burning"]["value"]
		take_damage(damage)
	
	if status_effects.has("poisoned"):
		var damage = status_effects["poisoned"]["value"]
		take_damage(damage)
	
	# Efectos de curación continua
	if status_effects.has("regeneration"):
		var heal_amount = status_effects["regeneration"]["value"]
		heal(heal_amount)

# Verificar si tiene un efecto de estado
func has_status_effect(effect_name: String) -> bool:
	return status_effects.has(effect_name)

# Obtener valor de un efecto de estado
func get_status_effect_value(effect_name: String) -> int:
	if status_effects.has(effect_name):
		return status_effects[effect_name]["value"]
	return 0

# Modificar energía
func modify_energy(amount: int) -> void:
	current_energy += amount
	
	# Limitar a los valores mínimo y máximo
	if current_energy < 0:
		current_energy = 0
	elif current_energy > max_energy:
		current_energy = max_energy

# Obtener botín al morir
func get_loot() -> Dictionary:
	var loot = {
		"items": [],
		"currency": 0
	}
	
	# Moneda base según nivel
	loot["currency"] = randi_range(level * 5, level * 10)
	
	# Determinar objetos según tabla de botín
	for item_data in loot_table:
		# Verificar probabilidad
		if randf() < item_data["chance"]:
			# Determinar cantidad
			var quantity = randi_range(item_data["quantity"][0], item_data["quantity"][1])
			
			# Añadir a la lista de botín
			loot["items"].append({
				"id": item_data["id"],
				"quantity": quantity
			})
	
	return loot

# Obtener daño de ataque básico
func get_attack_damage() -> int:
	return strength * 2 + level * 2

# Obtener defensa
func get_defense() -> int:
	return resistance * 0.5 + level

# Obtener resistencia a un tipo de daño
func get_resistance_to_damage_type(damage_type: String) -> float:
	var base_resistance = resistance * 0.5
	
	# Modificar según tipo de enemigo y daño
	match enemy_type:
		EnemyType.HUMANOID:
			# Resistencia estándar
			pass
		EnemyType.BEAST:
			# Más resistente a daño físico, débil a energía
			if damage_type == "physical":
				base_resistance *= 1.2
			elif damage_type == "energy":
				base_resistance *= 0.8
		EnemyType.ROBOT:
			# Resistente a daño físico y energía, débil a EMP
			if damage_type == "physical":
				base_resistance *= 1.3
			elif damage_type == "emp":
				base_resistance *= 0.5
		EnemyType.MUTANT:
			# Resistente a tóxico, débil a energía
			if damage_type == "toxic":
				base_resistance *= 1.5
			elif damage_type == "energy":
				base_resistance *= 0.7
		EnemyType.SPIRIT:
			# Resistente a físico y energía, débil a psíquico
			if damage_type == "physical" or damage_type == "energy":
				base_resistance *= 1.4
			elif damage_type == "psychic":
				base_resistance *= 0.6
	
	return base_resistance

# Obtener probabilidad de crítico
func get_crit_chance() -> float:
	return 0.05 + (perception * 0.01)  # 5% base + 1% por punto de percepción

# Obtener nivel
func get_level() -> int:
	return level

# Obtener facción
func get_faction() -> String:
	match faction:
		Faction.SCRAP_RAIDERS:
			return "scrap_raiders"
		Faction.WANDERERS:
			return "wanderers"
		Faction.TECH_COLLECTIVE:
			return "tech_collective"
		Faction.CHILDREN_OF_ATOM:
			return "children_of_atom"
		Faction.WILD:
			return "wild"
		_:
			return "none"

# Obtener ID de entidad
func get_entity_id() -> String:
	return entity_id

# Verificar si está vivo
func is_alive() -> bool:
	return is_alive

# Obtener porcentaje de salud
func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

# Obtener salud actual
func get_health() -> int:
	return current_health

# Obtener salud máxima
func get_max_health() -> int:
	return max_health

# Obtener energía actual
func get_energy() -> int:
	return current_energy

# Verificar si tiene habilidades de combate
func has_combat_skills() -> bool:
	return combat_skills.size() > 0

# Obtener una habilidad de combate aleatoria
func get_random_combat_skill() -> String:
	if combat_skills.size() == 0:
		return ""
	
	var skill = combat_skills[randi() % combat_skills.size()]
	return skill["id"]

# Verificar si una habilidad es ofensiva
func is_skill_offensive(skill_id: String) -> bool:
	for skill in combat_skills:
		if skill["id"] == skill_id:
			return skill["is_offensive"]
	
	return true  # Por defecto, asumir ofensiva

# Obtener datos de una habilidad
func get_skill_data(skill_id: String) -> Dictionary:
	for skill in combat_skills:
		if skill["id"] == skill_id:
			return skill
	
	return {}

# Verificar si tiene habilidad de curación
func has_healing_ability() -> bool:
	for skill in combat_skills:
		if skill["type"] == "heal":
			return true
	
	return false

# Obtener ID de habilidad de curación
func get_healing_skill_id() -> String:
	for skill in combat_skills:
		if skill["type"] == "heal":
			return skill["id"]
	
	return ""

# Verificar si es persuadible
func is_persuadable() -> bool:
	return is_persuadable

# Verificar si es hackeable
func is_hackable() -> bool:
	return is_hackable

# Verificar si es mecánico
func is_mechanical() -> bool:
	return is_mechanical

# Verificar si es controlable mentalmente
func is_controllable() -> bool:
	# Los robots y espíritus son inmunes al control mental
	return enemy_type != EnemyType.ROBOT and enemy_type != EnemyType.SPIRIT

# Obtener un stat específico
func get_stat(stat_name: String) -> int:
	match stat_name:
		"strength":
			return strength
		"agility":
			return agility
		"resistance":
			return resistance
		"perception":
			return perception
		"intelligence":
			return intelligence
		"will":
			return will
		"charisma":
			return charisma
		_:
			return 0