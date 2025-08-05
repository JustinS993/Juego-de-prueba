extends Node

# Señales
signal skill_unlocked(skill_id)
signal skill_upgraded(skill_id, new_level)
signal skill_points_changed(current_points)
signal skill_tree_initialized()

# Enumeraciones
enum SkillTree {
	COMBAT,
	TECHNOLOGY,
	MUTATION
}

enum SkillType {
	PASSIVE,
	ACTIVE,
	ULTIMATE
}

# Variables
var skill_trees: Dictionary = {}
var player_skills: Dictionary = {}
var available_skill_points: int = 0
var total_skill_points_earned: int = 0

# Función de inicialización
func _ready() -> void:
	# Inicializar árboles de habilidades
	initialize_skill_trees()
	
	# Inicializar habilidades del jugador
	initialize_player_skills()
	
	# Emitir señal de inicialización
	emit_signal("skill_tree_initialized")

# Inicializar árboles de habilidades
func initialize_skill_trees() -> void:
	# Árbol de Combate
	skill_trees[SkillTree.COMBAT] = {
		"name": "Combate",
		"description": "Habilidades de combate físico y defensa.",
		"icon": "res://assets/sprites/icons/combat_tree.png",
		"skills": {}
	}
	
	# Árbol de Tecnología
	skill_trees[SkillTree.TECHNOLOGY] = {
		"name": "Tecnología",
		"description": "Habilidades de hackeo, fabricación y armas de energía.",
		"icon": "res://assets/sprites/icons/tech_tree.png",
		"skills": {}
	}
	
	# Árbol de Mutación
	skill_trees[SkillTree.MUTATION] = {
		"name": "Mutación",
		"description": "Habilidades mutantes que alteran el cuerpo y la realidad.",
		"icon": "res://assets/sprites/icons/mutation_tree.png",
		"skills": {}
	}
	
	# Añadir habilidades a cada árbol
	add_combat_skills()
	add_technology_skills()
	add_mutation_skills()

# Añadir habilidades de combate
func add_combat_skills() -> void:
	# Nivel 1
	add_skill({
		"id": "combat_basic_training",
		"name": "Entrenamiento Básico",
		"description": "Entrenamiento en combate básico que mejora la precisión y el daño.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "accuracy", "value": 5}, {"stat": "damage", "value": 2}],
			2: [{"stat": "accuracy", "value": 10}, {"stat": "damage", "value": 5}],
			3: [{"stat": "accuracy", "value": 15}, {"stat": "damage", "value": 8}]
		},
		"requirements": {},
		"position": Vector2(100, 100),
		"icon": "res://assets/sprites/icons/skills/basic_training.png"
	})
	
	add_skill({
		"id": "combat_defensive_stance",
		"name": "Postura Defensiva",
		"description": "Adopta una postura que aumenta la defensa a costa de movilidad.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "defense", "value": 10}, {"stat": "evasion", "value": -5}],
			2: [{"stat": "defense", "value": 20}, {"stat": "evasion", "value": -5}],
			3: [{"stat": "defense", "value": 30}, {"stat": "evasion", "value": -5}]
		},
		"energy_cost": {1: 10, 2: 8, 3: 6},
		"cooldown": {1: 3, 2: 3, 3: 2},
		"duration": {1: 2, 2: 3, 3: 3},
		"requirements": {"combat_basic_training": 1},
		"position": Vector2(250, 50),
		"icon": "res://assets/sprites/icons/skills/defensive_stance.png"
	})
	
	add_skill({
		"id": "combat_quick_strike",
		"name": "Golpe Rápido",
		"description": "Un ataque veloz que tiene mayor probabilidad de impactar primero.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "initiative", "value": 15}, {"stat": "damage", "value": 5}],
			2: [{"stat": "initiative", "value": 25}, {"stat": "damage", "value": 10}],
			3: [{"stat": "initiative", "value": 35}, {"stat": "damage", "value": 15}]
		},
		"energy_cost": {1: 8, 2: 10, 3: 12},
		"cooldown": {1: 2, 2: 2, 3: 1},
		"requirements": {"combat_basic_training": 1},
		"position": Vector2(250, 150),
		"icon": "res://assets/sprites/icons/skills/quick_strike.png"
	})
	
	# Nivel 2
	add_skill({
		"id": "combat_weapon_mastery",
		"name": "Maestría con Armas",
		"description": "Mejora el manejo de todo tipo de armas, aumentando el daño y la probabilidad de crítico.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "damage", "value": 10}, {"stat": "crit_chance", "value": 5}],
			2: [{"stat": "damage", "value": 15}, {"stat": "crit_chance", "value": 10}],
			3: [{"stat": "damage", "value": 20}, {"stat": "crit_chance", "value": 15}]
		},
		"requirements": {"combat_basic_training": 2, "player_level": 5},
		"position": Vector2(400, 100),
		"icon": "res://assets/sprites/icons/skills/weapon_mastery.png"
	})
	
	add_skill({
		"id": "combat_counter_attack",
		"name": "Contraataque",
		"description": "Permite contraatacar automáticamente cuando recibes daño.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "counter_chance", "value": 15}, {"stat": "counter_damage", "value": 30}],
			2: [{"stat": "counter_chance", "value": 25}, {"stat": "counter_damage", "value": 40}],
			3: [{"stat": "counter_chance", "value": 35}, {"stat": "counter_damage", "value": 50}]
		},
		"requirements": {"combat_defensive_stance": 2, "player_level": 7},
		"position": Vector2(400, 0),
		"icon": "res://assets/sprites/icons/skills/counter_attack.png"
	})
	
	add_skill({
		"id": "combat_flurry",
		"name": "Ráfaga de Golpes",
		"description": "Realiza una serie de ataques rápidos contra un enemigo.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "hits", "value": 2}, {"stat": "damage_per_hit", "value": 60}],
			2: [{"stat": "hits", "value": 3}, {"stat": "damage_per_hit", "value": 65}],
			3: [{"stat": "hits", "value": 4}, {"stat": "damage_per_hit", "value": 70}]
		},
		"energy_cost": {1: 15, 2: 20, 3: 25},
		"cooldown": {1: 3, 2: 3, 3: 3},
		"requirements": {"combat_quick_strike": 2, "player_level": 7},
		"position": Vector2(400, 200),
		"icon": "res://assets/sprites/icons/skills/flurry.png"
	})
	
	# Nivel 3
	add_skill({
		"id": "combat_critical_mastery",
		"name": "Maestría Crítica",
		"description": "Aumenta significativamente el daño crítico y la probabilidad de causarlo.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "crit_chance", "value": 10}, {"stat": "crit_damage", "value": 20}],
			2: [{"stat": "crit_chance", "value": 15}, {"stat": "crit_damage", "value": 35}],
			3: [{"stat": "crit_chance", "value": 20}, {"stat": "crit_damage", "value": 50}]
		},
		"requirements": {"combat_weapon_mastery": 2, "player_level": 12},
		"position": Vector2(550, 100),
		"icon": "res://assets/sprites/icons/skills/critical_mastery.png"
	})
	
	add_skill({
		"id": "combat_armor_breaker",
		"name": "Rompearmaduras",
		"description": "Un poderoso golpe que ignora parte de la defensa enemiga.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "armor_penetration", "value": 30}, {"stat": "damage", "value": 40}],
			2: [{"stat": "armor_penetration", "value": 45}, {"stat": "damage", "value": 60}],
			3: [{"stat": "armor_penetration", "value": 60}, {"stat": "damage", "value": 80}]
		},
		"energy_cost": {1: 20, 2: 25, 3: 30},
		"cooldown": {1: 4, 2: 4, 3: 3},
		"requirements": {"combat_weapon_mastery": 2, "player_level": 15},
		"position": Vector2(550, 200),
		"icon": "res://assets/sprites/icons/skills/armor_breaker.png"
	})
	
	# Nivel 4 (Ultimate)
	add_skill({
		"id": "combat_berserker_rage",
		"name": "Furia Berserker",
		"description": "Entra en un estado de furia que aumenta drásticamente el daño y la velocidad, pero reduce la defensa.",
		"tree": SkillTree.COMBAT,
		"type": SkillType.ULTIMATE,
		"max_level": 1,
		"effects": {
			1: [
				{"stat": "damage", "value": 50},
				{"stat": "attack_speed", "value": 30},
				{"stat": "defense", "value": -20}
			]
		},
		"energy_cost": {1: 40},
		"cooldown": {1: 5},
		"duration": {1: 3},
		"requirements": {"combat_critical_mastery": 2, "combat_armor_breaker": 1, "player_level": 20},
		"position": Vector2(700, 150),
		"icon": "res://assets/sprites/icons/skills/berserker_rage.png"
	})

# Añadir habilidades de tecnología
func add_technology_skills() -> void:
	# Nivel 1
	add_skill({
		"id": "tech_basic_engineering",
		"name": "Ingeniería Básica",
		"description": "Conocimientos básicos de ingeniería que permiten reparar equipamiento y fabricar objetos simples.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "crafting_quality", "value": 10}, {"stat": "repair_efficiency", "value": 15}],
			2: [{"stat": "crafting_quality", "value": 20}, {"stat": "repair_efficiency", "value": 30}],
			3: [{"stat": "crafting_quality", "value": 30}, {"stat": "repair_efficiency", "value": 45}]
		},
		"requirements": {},
		"position": Vector2(100, 400),
		"icon": "res://assets/sprites/icons/skills/basic_engineering.png"
	})
	
	add_skill({
		"id": "tech_energy_weapons",
		"name": "Armas de Energía",
		"description": "Conocimiento especializado en armas de energía, aumentando su daño y eficiencia.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "energy_weapon_damage", "value": 15}, {"stat": "energy_efficiency", "value": 10}],
			2: [{"stat": "energy_weapon_damage", "value": 25}, {"stat": "energy_efficiency", "value": 20}],
			3: [{"stat": "energy_weapon_damage", "value": 40}, {"stat": "energy_efficiency", "value": 30}]
		},
		"requirements": {"tech_basic_engineering": 1},
		"position": Vector2(250, 350),
		"icon": "res://assets/sprites/icons/skills/energy_weapons.png"
	})
	
	add_skill({
		"id": "tech_basic_hacking",
		"name": "Hackeo Básico",
		"description": "Habilidad para hackear terminales y dispositivos simples, abriendo nuevas opciones de diálogo y acceso.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "hacking_success", "value": 20}, {"stat": "hacking_speed", "value": 10}],
			2: [{"stat": "hacking_success", "value": 35}, {"stat": "hacking_speed", "value": 20}],
			3: [{"stat": "hacking_success", "value": 50}, {"stat": "hacking_speed", "value": 30}]
		},
		"energy_cost": {1: 15, 2: 12, 3: 10},
		"cooldown": {1: 3, 2: 2, 3: 2},
		"requirements": {"tech_basic_engineering": 1},
		"position": Vector2(250, 450),
		"icon": "res://assets/sprites/icons/skills/basic_hacking.png"
	})
	
	# Nivel 2
	add_skill({
		"id": "tech_energy_shield",
		"name": "Escudo de Energía",
		"description": "Genera un escudo de energía que absorbe daño.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "shield_strength", "value": 30}, {"stat": "shield_duration", "value": 2}],
			2: [{"stat": "shield_strength", "value": 50}, {"stat": "shield_duration", "value": 3}],
			3: [{"stat": "shield_strength", "value": 80}, {"stat": "shield_duration", "value": 3}]
		},
		"energy_cost": {1: 20, 2: 25, 3: 30},
		"cooldown": {1: 4, 2: 4, 3: 3},
		"requirements": {"tech_energy_weapons": 2, "player_level": 5},
		"position": Vector2(400, 350),
		"icon": "res://assets/sprites/icons/skills/energy_shield.png"
	})
	
	add_skill({
		"id": "tech_combat_drone",
		"name": "Dron de Combate",
		"description": "Despliega un dron que ataca a los enemigos automáticamente.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "drone_damage", "value": 15}, {"stat": "drone_duration", "value": 3}],
			2: [{"stat": "drone_damage", "value": 25}, {"stat": "drone_duration", "value": 4}],
			3: [{"stat": "drone_damage", "value": 40}, {"stat": "drone_duration", "value": 5}]
		},
		"energy_cost": {1: 25, 2: 30, 3: 35},
		"cooldown": {1: 5, 2: 4, 3: 4},
		"requirements": {"tech_basic_engineering": 3, "player_level": 8},
		"position": Vector2(400, 450),
		"icon": "res://assets/sprites/icons/skills/combat_drone.png"
	})
	
	add_skill({
		"id": "tech_system_override",
		"name": "Anulación de Sistema",
		"description": "Hackea enemigos robóticos para desactivarlos temporalmente o volverlos aliados.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "hack_success", "value": 40}, {"stat": "hack_duration", "value": 2}],
			2: [{"stat": "hack_success", "value": 60}, {"stat": "hack_duration", "value": 3}],
			3: [{"stat": "hack_success", "value": 80}, {"stat": "hack_duration", "value": 4}]
		},
		"energy_cost": {1: 30, 2: 35, 3: 40},
		"cooldown": {1: 4, 2: 4, 3: 3},
		"requirements": {"tech_basic_hacking": 2, "player_level": 10},
		"position": Vector2(400, 550),
		"icon": "res://assets/sprites/icons/skills/system_override.png"
	})
	
	# Nivel 3
	add_skill({
		"id": "tech_energy_overcharge",
		"name": "Sobrecarga de Energía",
		"description": "Sobrecarga tus armas de energía para un ataque devastador.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "damage", "value": 100}, {"stat": "area_effect", "value": 1}],
			2: [{"stat": "damage", "value": 150}, {"stat": "area_effect", "value": 1}],
			3: [{"stat": "damage", "value": 200}, {"stat": "area_effect", "value": 2}]
		},
		"energy_cost": {1: 35, 2: 40, 3: 45},
		"cooldown": {1: 5, 2: 5, 3: 4},
		"requirements": {"tech_energy_weapons": 3, "tech_energy_shield": 1, "player_level": 15},
		"position": Vector2(550, 350),
		"icon": "res://assets/sprites/icons/skills/energy_overcharge.png"
	})
	
	add_skill({
		"id": "tech_advanced_robotics",
		"name": "Robótica Avanzada",
		"description": "Mejora significativamente el rendimiento de drones y robots aliados.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "drone_damage", "value": 30}, {"stat": "drone_health", "value": 50}],
			2: [{"stat": "drone_damage", "value": 50}, {"stat": "drone_health", "value": 75}],
			3: [{"stat": "drone_damage", "value": 70}, {"stat": "drone_health", "value": 100}]
		},
		"requirements": {"tech_combat_drone": 2, "player_level": 15},
		"position": Vector2(550, 450),
		"icon": "res://assets/sprites/icons/skills/advanced_robotics.png"
	})
	
	# Nivel 4 (Ultimate)
	add_skill({
		"id": "tech_singularity_beam",
		"name": "Rayo de Singularidad",
		"description": "Dispara un poderoso rayo que crea una singularidad temporal, causando daño masivo en área.",
		"tree": SkillTree.TECHNOLOGY,
		"type": SkillType.ULTIMATE,
		"max_level": 1,
		"effects": {
			1: [
				{"stat": "damage", "value": 300},
				{"stat": "area_effect", "value": 3},
				{"stat": "gravity_pull", "value": 1}
			]
		},
		"energy_cost": {1: 50},
		"cooldown": {1: 6},
		"requirements": {"tech_energy_overcharge": 2, "tech_advanced_robotics": 1, "player_level": 20},
		"position": Vector2(700, 400),
		"icon": "res://assets/sprites/icons/skills/singularity_beam.png"
	})

# Añadir habilidades de mutación
func add_mutation_skills() -> void:
	# Nivel 1
	add_skill({
		"id": "mutation_adaptive_cells",
		"name": "Células Adaptativas",
		"description": "Tus células comienzan a mutar, otorgándote regeneración pasiva y resistencia a toxinas.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "health_regen", "value": 1}, {"stat": "toxic_resistance", "value": 15}],
			2: [{"stat": "health_regen", "value": 2}, {"stat": "toxic_resistance", "value": 30}],
			3: [{"stat": "health_regen", "value": 3}, {"stat": "toxic_resistance", "value": 45}]
		},
		"requirements": {},
		"position": Vector2(100, 700),
		"icon": "res://assets/sprites/icons/skills/adaptive_cells.png"
	})
	
	add_skill({
		"id": "mutation_toxic_touch",
		"name": "Toque Tóxico",
		"description": "Tus ataques cuerpo a cuerpo infligen daño tóxico adicional.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "toxic_damage", "value": 5}, {"stat": "poison_chance", "value": 10}],
			2: [{"stat": "toxic_damage", "value": 10}, {"stat": "poison_chance", "value": 20}],
			3: [{"stat": "toxic_damage", "value": 15}, {"stat": "poison_chance", "value": 30}]
		},
		"requirements": {"mutation_adaptive_cells": 1},
		"position": Vector2(250, 650),
		"icon": "res://assets/sprites/icons/skills/toxic_touch.png"
	})
	
	add_skill({
		"id": "mutation_mind_link",
		"name": "Vínculo Mental",
		"description": "Establece un vínculo psíquico con un enemigo, causando daño mental y desorientación.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "psychic_damage", "value": 20}, {"stat": "confusion_chance", "value": 30}],
			2: [{"stat": "psychic_damage", "value": 35}, {"stat": "confusion_chance", "value": 50}],
			3: [{"stat": "psychic_damage", "value": 50}, {"stat": "confusion_chance", "value": 70}]
		},
		"energy_cost": {1: 15, 2: 20, 3: 25},
		"cooldown": {1: 3, 2: 3, 3: 2},
		"requirements": {"mutation_adaptive_cells": 1},
		"position": Vector2(250, 750),
		"icon": "res://assets/sprites/icons/skills/mind_link.png"
	})
	
	# Nivel 2
	add_skill({
		"id": "mutation_toxic_cloud",
		"name": "Nube Tóxica",
		"description": "Libera una nube de toxinas que daña a los enemigos en un área.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "toxic_damage", "value": 10}, {"stat": "area_effect", "value": 2}, {"stat": "duration", "value": 2}],
			2: [{"stat": "toxic_damage", "value": 15}, {"stat": "area_effect", "value": 2}, {"stat": "duration", "value": 3}],
			3: [{"stat": "toxic_damage", "value": 20}, {"stat": "area_effect", "value": 3}, {"stat": "duration", "value": 3}]
		},
		"energy_cost": {1: 20, 2: 25, 3: 30},
		"cooldown": {1: 4, 2: 4, 3: 3},
		"requirements": {"mutation_toxic_touch": 2, "player_level": 7},
		"position": Vector2(400, 650),
		"icon": "res://assets/sprites/icons/skills/toxic_cloud.png"
	})
	
	add_skill({
		"id": "mutation_mind_control",
		"name": "Control Mental",
		"description": "Toma control temporal de un enemigo, haciéndolo luchar a tu lado.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "control_chance", "value": 40}, {"stat": "control_duration", "value": 2}],
			2: [{"stat": "control_chance", "value": 60}, {"stat": "control_duration", "value": 3}],
			3: [{"stat": "control_chance", "value": 80}, {"stat": "control_duration", "value": 4}]
		},
		"energy_cost": {1: 30, 2: 35, 3: 40},
		"cooldown": {1: 5, 2: 5, 3: 4},
		"requirements": {"mutation_mind_link": 2, "player_level": 10},
		"position": Vector2(400, 750),
		"icon": "res://assets/sprites/icons/skills/mind_control.png"
	})
	
	add_skill({
		"id": "mutation_adaptive_armor",
		"name": "Armadura Adaptativa",
		"description": "Tu piel muta para adaptarse a los ataques, aumentando la resistencia al tipo de daño recibido recientemente.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.PASSIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "adaptive_resistance", "value": 20}, {"stat": "adaptation_duration", "value": 2}],
			2: [{"stat": "adaptive_resistance", "value": 35}, {"stat": "adaptation_duration", "value": 3}],
			3: [{"stat": "adaptive_resistance", "value": 50}, {"stat": "adaptation_duration", "value": 4}]
		},
		"requirements": {"mutation_adaptive_cells": 3, "player_level": 12},
		"position": Vector2(400, 850),
		"icon": "res://assets/sprites/icons/skills/adaptive_armor.png"
	})
	
	# Nivel 3
	add_skill({
		"id": "mutation_time_dilation",
		"name": "Dilatación Temporal",
		"description": "Altera tu percepción del tiempo, permitiéndote moverte más rápido que tus enemigos.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "action_speed", "value": 50}, {"stat": "evasion", "value": 30}, {"stat": "duration", "value": 2}],
			2: [{"stat": "action_speed", "value": 75}, {"stat": "evasion", "value": 45}, {"stat": "duration", "value": 2}],
			3: [{"stat": "action_speed", "value": 100}, {"stat": "evasion", "value": 60}, {"stat": "duration", "value": 3}]
		},
		"energy_cost": {1: 35, 2: 40, 3: 45},
		"cooldown": {1: 5, 2: 5, 3: 4},
		"requirements": {"mutation_adaptive_armor": 2, "player_level": 15},
		"position": Vector2(550, 750),
		"icon": "res://assets/sprites/icons/skills/time_dilation.png"
	})
	
	add_skill({
		"id": "mutation_energy_drain",
		"name": "Drenaje de Energía",
		"description": "Drena la energía vital de los enemigos para curarte y recuperar energía.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.ACTIVE,
		"max_level": 3,
		"effects": {
			1: [{"stat": "drain_damage", "value": 30}, {"stat": "health_restored", "value": 50}, {"stat": "energy_restored", "value": 15}],
			2: [{"stat": "drain_damage", "value": 45}, {"stat": "health_restored", "value": 70}, {"stat": "energy_restored", "value": 25}],
			3: [{"stat": "drain_damage", "value": 60}, {"stat": "health_restored", "value": 90}, {"stat": "energy_restored", "value": 35}]
		},
		"energy_cost": {1: 25, 2: 30, 3: 35},
		"cooldown": {1: 4, 2: 4, 3: 3},
		"requirements": {"mutation_toxic_cloud": 2, "player_level": 15},
		"position": Vector2(550, 650),
		"icon": "res://assets/sprites/icons/skills/energy_drain.png"
	})
	
	# Nivel 4 (Ultimate)
	add_skill({
		"id": "mutation_seed_awakening",
		"name": "Despertar de la Semilla",
		"description": "Libera todo el poder de La Semilla, transformándote temporalmente en un ser de energía pura con habilidades devastadoras.",
		"tree": SkillTree.MUTATION,
		"type": SkillType.ULTIMATE,
		"max_level": 1,
		"effects": {
			1: [
				{"stat": "all_damage", "value": 100},
				{"stat": "damage_resistance", "value": 50},
				{"stat": "action_speed", "value": 50},
				{"stat": "energy_regen", "value": 20},
				{"stat": "duration", "value": 3}
			]
		},
		"energy_cost": {1: 50},
		"cooldown": {1: 6},
		"mutant_charge_cost": {1: 100},
		"requirements": {"mutation_time_dilation": 2, "mutation_energy_drain": 1, "player_level": 20},
		"position": Vector2(700, 700),
		"icon": "res://assets/sprites/icons/skills/seed_awakening.png"
	})

# Inicializar habilidades del jugador
func initialize_player_skills() -> void:
	# Inicializar estructura de habilidades del jugador
	player_skills = {}
	
	# Añadir habilidades iniciales (nivel 0 para todas)
	for tree_id in skill_trees:
		for skill_id in skill_trees[tree_id]["skills"]:
			player_skills[skill_id] = {
				"id": skill_id,
				"level": 0,
				"unlocked": false
			}
	
	# Desbloquear habilidades iniciales (una por árbol)
	unlock_skill("combat_basic_training")
	unlock_skill("tech_basic_engineering")
	unlock_skill("mutation_adaptive_cells")

# Añadir una habilidad al árbol
func add_skill(skill_data: Dictionary) -> void:
	# Verificar que la habilidad tenga un ID y un árbol
	if not skill_data.has("id") or not skill_data.has("tree"):
		return
	
	# Añadir la habilidad al árbol correspondiente
	skill_trees[skill_data["tree"]]["skills"][skill_data["id"]] = skill_data

# Desbloquear una habilidad
func unlock_skill(skill_id: String) -> bool:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return false
	
	# Verificar si ya está desbloqueada
	if player_skills[skill_id]["unlocked"]:
		return false
	
	# Desbloquear la habilidad
	player_skills[skill_id]["unlocked"] = true
	player_skills[skill_id]["level"] = 1
	
	# Emitir señal
	emit_signal("skill_unlocked", skill_id)
	return true

# Mejorar una habilidad
func upgrade_skill(skill_id: String) -> bool:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return false
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return false
	
	# Buscar datos de la habilidad
	var tree_id = -1
	var skill_data = {}
	
	# Buscar en todos los árboles
	for tree in skill_trees:
		if skill_trees[tree]["skills"].has(skill_id):
			tree_id = tree
			skill_data = skill_trees[tree]["skills"][skill_id]
			break
	
	# Verificar si se encontró la habilidad
	if tree_id == -1:
		return false
	
	# Verificar si ya está al nivel máximo
	if player_skills[skill_id]["level"] >= skill_data["max_level"]:
		return false
	
	# Verificar si hay puntos de habilidad disponibles
	if available_skill_points <= 0:
		return false
	
	# Mejorar la habilidad
	player_skills[skill_id]["level"] += 1
	
	# Reducir puntos de habilidad disponibles
	available_skill_points -= 1
	
	# Emitir señales
	emit_signal("skill_upgraded", skill_id, player_skills[skill_id]["level"])
	emit_signal("skill_points_changed", available_skill_points)
	return true

# Verificar si se cumplen los requisitos para una habilidad
func check_skill_requirements(skill_id: String) -> bool:
	# Verificar si la habilidad existe
	var tree_id = -1
	var skill_data = {}
	
	# Buscar en todos los árboles
	for tree in skill_trees:
		if skill_trees[tree]["skills"].has(skill_id):
			tree_id = tree
			skill_data = skill_trees[tree]["skills"][skill_id]
			break
	
	# Verificar si se encontró la habilidad
	if tree_id == -1:
		return false
	
	# Verificar requisitos
	if skill_data.has("requirements"):
		for req_skill_id in skill_data["requirements"]:
			# Si es requisito de nivel de jugador
			if req_skill_id == "player_level":
				var player = get_tree().get_nodes_in_group("player")[0]
				if player.level < skill_data["requirements"][req_skill_id]:
					return false
			# Si es requisito de otra habilidad
			elif not player_skills.has(req_skill_id) or player_skills[req_skill_id]["level"] < skill_data["requirements"][req_skill_id]:
				return false
	
	return true

# Añadir puntos de habilidad
func add_skill_points(amount: int) -> void:
	available_skill_points += amount
	total_skill_points_earned += amount
	emit_signal("skill_points_changed", available_skill_points)

# Obtener nivel de una habilidad
func get_skill_level(skill_id: String) -> int:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return 0
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return 0
	
	return player_skills[skill_id]["level"]

# Verificar si una habilidad está desbloqueada
func is_skill_unlocked(skill_id: String) -> bool:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return false
	
	return player_skills[skill_id]["unlocked"]

# Obtener datos de una habilidad
func get_skill_data(skill_id: String) -> Dictionary:
	# Buscar en todos los árboles
	for tree_id in skill_trees:
		if skill_trees[tree_id]["skills"].has(skill_id):
			return skill_trees[tree_id]["skills"][skill_id]
	
	return {}

# Obtener efectos de una habilidad según su nivel
func get_skill_effects(skill_id: String) -> Array:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return []
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return []
	
	# Obtener nivel actual
	var level = player_skills[skill_id]["level"]
	
	# Buscar datos de la habilidad
	var skill_data = get_skill_data(skill_id)
	
	# Verificar si tiene efectos para ese nivel
	if skill_data.has("effects") and skill_data["effects"].has(level):
		return skill_data["effects"][level]
	
	return []

# Obtener coste de energía de una habilidad según su nivel
func get_skill_energy_cost(skill_id: String) -> int:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return 0
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return 0
	
	# Obtener nivel actual
	var level = player_skills[skill_id]["level"]
	
	# Buscar datos de la habilidad
	var skill_data = get_skill_data(skill_id)
	
	# Verificar si tiene coste de energía para ese nivel
	if skill_data.has("energy_cost") and skill_data["energy_cost"].has(level):
		return skill_data["energy_cost"][level]
	
	return 0

# Obtener tiempo de recarga de una habilidad según su nivel
func get_skill_cooldown(skill_id: String) -> int:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return 0
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return 0
	
	# Obtener nivel actual
	var level = player_skills[skill_id]["level"]
	
	# Buscar datos de la habilidad
	var skill_data = get_skill_data(skill_id)
	
	# Verificar si tiene tiempo de recarga para ese nivel
	if skill_data.has("cooldown") and skill_data["cooldown"].has(level):
		return skill_data["cooldown"][level]
	
	return 0

# Obtener duración de una habilidad según su nivel
func get_skill_duration(skill_id: String) -> int:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return 0
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return 0
	
	# Obtener nivel actual
	var level = player_skills[skill_id]["level"]
	
	# Buscar datos de la habilidad
	var skill_data = get_skill_data(skill_id)
	
	# Verificar si tiene duración para ese nivel
	if skill_data.has("duration") and skill_data["duration"].has(level):
		return skill_data["duration"][level]
	
	return 0

# Obtener coste de carga mutante de una habilidad según su nivel
func get_skill_mutant_charge_cost(skill_id: String) -> int:
	# Verificar si la habilidad existe
	if not player_skills.has(skill_id):
		return 0
	
	# Verificar si está desbloqueada
	if not player_skills[skill_id]["unlocked"]:
		return 0
	
	# Obtener nivel actual
	var level = player_skills[skill_id]["level"]
	
	# Buscar datos de la habilidad
	var skill_data = get_skill_data(skill_id)
	
	# Verificar si tiene coste de carga mutante para ese nivel
	if skill_data.has("mutant_charge_cost") and skill_data["mutant_charge_cost"].has(level):
		return skill_data["mutant_charge_cost"][level]
	
	return 0

# Obtener habilidades desbloqueadas
func get_unlocked_skills() -> Array:
	var unlocked = []
	
	# Recorrer todas las habilidades
	for skill_id in player_skills:
		if player_skills[skill_id]["unlocked"]:
			unlocked.append(skill_id)
	
	return unlocked

# Obtener habilidades desbloqueadas por árbol
func get_unlocked_skills_by_tree(tree_id: int) -> Array:
	var unlocked = []
	
	# Verificar si el árbol existe
	if not skill_trees.has(tree_id):
		return unlocked
	
	# Recorrer habilidades del árbol
	for skill_id in skill_trees[tree_id]["skills"]:
		if player_skills.has(skill_id) and player_skills[skill_id]["unlocked"]:
			unlocked.append(skill_id)
	
	return unlocked

# Obtener habilidades disponibles para desbloquear
func get_available_skills() -> Array:
	var available = []
	
	# Recorrer todos los árboles
	for tree_id in skill_trees:
		# Recorrer habilidades del árbol
		for skill_id in skill_trees[tree_id]["skills"]:
			# Verificar si no está desbloqueada
			if player_skills.has(skill_id) and not player_skills[skill_id]["unlocked"]:
				# Verificar requisitos
				if check_skill_requirements(skill_id):
					available.append(skill_id)
	
	return available

# Obtener habilidades disponibles para mejorar
func get_upgradable_skills() -> Array:
	var upgradable = []
	
	# Recorrer todas las habilidades
	for skill_id in player_skills:
		# Verificar si está desbloqueada
		if player_skills[skill_id]["unlocked"]:
			# Obtener datos de la habilidad
			var skill_data = get_skill_data(skill_id)
			
			# Verificar si puede mejorarse
			if player_skills[skill_id]["level"] < skill_data["max_level"]:
				upgradable.append(skill_id)
	
	return upgradable

# Guardar datos de habilidades
func save_skills_data() -> Dictionary:
	return {
		"player_skills": player_skills,
		"available_skill_points": available_skill_points,
		"total_skill_points_earned": total_skill_points_earned
	}

# Cargar datos de habilidades
func load_skills_data(data: Dictionary) -> void:
	# Verificar si hay datos válidos
	if data.has("player_skills"):
		player_skills = data["player_skills"]
	
	if data.has("available_skill_points"):
		available_skill_points = data["available_skill_points"]
	
	if data.has("total_skill_points_earned"):
		total_skill_points_earned = data["total_skill_points_earned"]
	
	# Emitir señales
	emit_signal("skill_points_changed", available_skill_points)
	emit_signal("skill_tree_initialized")

# Resetear habilidades (para pruebas o respec)
func reset_skills() -> void:
	# Guardar puntos totales
	var total_points = total_skill_points_earned
	
	# Reiniciar habilidades del jugador
	initialize_player_skills()
	
	# Restaurar todos los puntos
	available_skill_points = total_points
	total_skill_points_earned = total_points
	
	# Emitir señales
	emit_signal("skill_points_changed", available_skill_points)
	emit_signal("skill_tree_initialized")