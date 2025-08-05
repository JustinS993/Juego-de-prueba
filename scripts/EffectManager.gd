extends Node

# Señales
signal effect_started(effect_name, effect_node)
signal effect_finished(effect_name)

# Enumeraciones
enum EffectType {
	DAMAGE,
	HEAL,
	BUFF,
	DEBUFF,
	STATUS,
	SPECIAL
}

# Rutas a las escenas de efectos
const EFFECT_SCENES = {
	# Efectos de daño
	"physical_hit": "res://scenes/effects/PhysicalHitEffect.tscn",
	"energy_hit": "res://scenes/effects/EnergyHitEffect.tscn",
	"fire_hit": "res://scenes/effects/FireHitEffect.tscn",
	"ice_hit": "res://scenes/effects/IceHitEffect.tscn",
	"electric_hit": "res://scenes/effects/ElectricHitEffect.tscn",
	"toxic_hit": "res://scenes/effects/ToxicHitEffect.tscn",
	
	# Efectos de curación
	"heal": "res://scenes/effects/HealEffect.tscn",
	"regen": "res://scenes/effects/RegenEffect.tscn",
	
	# Efectos de estado
	"poison": "res://scenes/effects/PoisonStatusEffect.tscn",
	"burn": "res://scenes/effects/BurnStatusEffect.tscn",
	"freeze": "res://scenes/effects/FreezeStatusEffect.tscn",
	"shock": "res://scenes/effects/ShockStatusEffect.tscn",
	"stun": "res://scenes/effects/StunStatusEffect.tscn",
	"bleed": "res://scenes/effects/BleedStatusEffect.tscn",
	
	# Efectos de buff/debuff
	"strength_buff": "res://scenes/effects/StrengthBuffEffect.tscn",
	"agility_buff": "res://scenes/effects/AgilityBuffEffect.tscn",
	"defense_buff": "res://scenes/effects/DefenseBuffEffect.tscn",
	"weakness_debuff": "res://scenes/effects/WeaknessDebuffEffect.tscn",
	"slow_debuff": "res://scenes/effects/SlowDebuffEffect.tscn",
	"vulnerable_debuff": "res://scenes/effects/VulnerableDebuffEffect.tscn",
	
	# Efectos especiales
	"mutant_reaction": "res://scenes/effects/MutantReactionEffect.tscn",
	"time_distortion": "res://scenes/effects/TimeDistortionEffect.tscn",
	"energy_shield": "res://scenes/effects/EnergyShieldEffect.tscn",
	"teleport": "res://scenes/effects/TeleportEffect.tscn",
	"hack": "res://scenes/effects/HackEffect.tscn",
	"drone_deploy": "res://scenes/effects/DroneDeployEffect.tscn"
}

# Variables
var active_effects = {}  # Diccionario para rastrear efectos activos

# Función para reproducir un efecto
func play_effect(effect_name: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Verificar si el efecto existe
	if not EFFECT_SCENES.has(effect_name) or not ResourceLoader.exists(EFFECT_SCENES[effect_name]):
		push_error("Efecto no encontrado: " + effect_name)
		return null
	
	# Cargar escena del efecto
	var effect_scene = load(EFFECT_SCENES[effect_name])
	if not effect_scene:
		push_error("No se pudo cargar la escena del efecto: " + effect_name)
		return null
	
	# Instanciar efecto
	var effect_instance = effect_scene.instantiate()
	if not effect_instance:
		push_error("No se pudo instanciar el efecto: " + effect_name)
		return null
	
	# Configurar posición
	effect_instance.global_position = position
	
	# Configurar parámetros
	if effect_instance.has_method("set_params"):
		effect_instance.set_params(params)
	
	# Conectar señales
	if effect_instance.has_signal("effect_started"):
		effect_instance.connect("effect_started", Callable(self, "_on_effect_started").bind(effect_name, effect_instance))
	
	if effect_instance.has_signal("effect_finished"):
		effect_instance.connect("effect_finished", Callable(self, "_on_effect_finished").bind(effect_name, effect_instance))
	
	# Añadir al árbol de escena
	add_child(effect_instance)
	
	# Reproducir efecto
	if effect_instance.has_method("play"):
		effect_instance.play()
	
	# Registrar efecto activo
	if not active_effects.has(effect_name):
		active_effects[effect_name] = []
	
	active_effects[effect_name].append(effect_instance)
	
	return effect_instance

# Función para detener un efecto específico
func stop_effect(effect_name: String) -> void:
	# Verificar si hay efectos activos con ese nombre
	if not active_effects.has(effect_name) or active_effects[effect_name].is_empty():
		return
	
	# Detener todos los efectos con ese nombre
	for effect in active_effects[effect_name]:
		if is_instance_valid(effect) and effect.has_method("stop"):
			effect.stop()
	
	# Limpiar lista
	active_effects[effect_name].clear()

# Función para detener todos los efectos
func stop_all_effects() -> void:
	# Recorrer todos los efectos activos
	for effect_name in active_effects.keys():
		stop_effect(effect_name)

# Función para reproducir un efecto de daño
func play_damage_effect(damage_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Mapear tipo de daño a efecto
	var effect_name = "physical_hit"  # Por defecto
	
	match damage_type:
		"physical":
			effect_name = "physical_hit"
		"energy":
			effect_name = "energy_hit"
		"fire":
			effect_name = "fire_hit"
		"ice":
			effect_name = "ice_hit"
		"electric":
			effect_name = "electric_hit"
		"toxic":
			effect_name = "toxic_hit"
		_:
			effect_name = "physical_hit"
	
	# Reproducir efecto
	return play_effect(effect_name, position, params)

# Función para reproducir un efecto de curación
func play_heal_effect(heal_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Mapear tipo de curación a efecto
	var effect_name = "heal"  # Por defecto
	
	match heal_type:
		"instant":
			effect_name = "heal"
		"regen":
			effect_name = "regen"
		_:
			effect_name = "heal"
	
	# Reproducir efecto
	return play_effect(effect_name, position, params)

# Función para reproducir un efecto de estado
func play_status_effect(status_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Verificar si el efecto existe
	if not EFFECT_SCENES.has(status_type):
		push_error("Efecto de estado no encontrado: " + status_type)
		return null
	
	# Reproducir efecto
	return play_effect(status_type, position, params)

# Función para reproducir un efecto de buff
func play_buff_effect(buff_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Mapear tipo de buff a efecto
	var effect_name = buff_type + "_buff"  # Por ejemplo, "strength_buff"
	
	# Verificar si el efecto existe
	if not EFFECT_SCENES.has(effect_name):
		push_error("Efecto de buff no encontrado: " + effect_name)
		return null
	
	# Reproducir efecto
	return play_effect(effect_name, position, params)

# Función para reproducir un efecto de debuff
func play_debuff_effect(debuff_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Mapear tipo de debuff a efecto
	var effect_name = debuff_type + "_debuff"  # Por ejemplo, "weakness_debuff"
	
	# Verificar si el efecto existe
	if not EFFECT_SCENES.has(effect_name):
		push_error("Efecto de debuff no encontrado: " + effect_name)
		return null
	
	# Reproducir efecto
	return play_effect(effect_name, position, params)

# Función para reproducir un efecto especial
func play_special_effect(special_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Verificar si el efecto existe
	if not EFFECT_SCENES.has(special_type):
		push_error("Efecto especial no encontrado: " + special_type)
		return null
	
	# Reproducir efecto
	return play_effect(special_type, position, params)

# Función para reproducir un efecto de Reacción Mutante
func play_mutant_reaction_effect(reaction_type: String, position: Vector2, params: Dictionary = {}) -> Node:
	# Configurar parámetros
	var reaction_params = params.duplicate()
	reaction_params["reaction_type"] = reaction_type
	
	# Reproducir efecto
	return play_effect("mutant_reaction", position, reaction_params)

# Callback cuando un efecto comienza
func _on_effect_started(effect_name: String, effect_node: Node) -> void:
	# Emitir señal
	emit_signal("effect_started", effect_name, effect_node)

# Callback cuando un efecto finaliza
func _on_effect_finished(effect_name: String, effect_node: Node) -> void:
	# Emitir señal
	emit_signal("effect_finished", effect_name)
	
	# Eliminar de la lista de efectos activos
	if active_effects.has(effect_name) and active_effects[effect_name].has(effect_node):
		active_effects[effect_name].erase(effect_node)