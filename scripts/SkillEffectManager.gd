extends Node

# Señales
signal effect_started(effect_id, target)
signal effect_finished(effect_id)

# Enumeraciones
enum EffectType {
	DAMAGE,
	HEAL,
	BUFF,
	DEBUFF,
	STATUS,
	SPECIAL
}

# Referencias a escenas de efectos
const EFFECT_SCENES = {
	# Efectos de daño
	"physical_hit": preload("res://scenes/effects/PhysicalHitEffect.tscn"),
	"energy_blast": preload("res://scenes/effects/EnergyBlastEffect.tscn"),
	"toxic_damage": preload("res://scenes/effects/ToxicDamageEffect.tscn"),
	"psychic_damage": preload("res://scenes/effects/PsychicDamageEffect.tscn"),
	
	# Efectos de curación
	"heal_effect": preload("res://scenes/effects/HealEffect.tscn"),
	"energy_restore": preload("res://scenes/effects/EnergyRestoreEffect.tscn"),
	
	# Efectos de buff
	"strength_buff": preload("res://scenes/effects/StrengthBuffEffect.tscn"),
	"defense_buff": preload("res://scenes/effects/DefenseBuffEffect.tscn"),
	"speed_buff": preload("res://scenes/effects/SpeedBuffEffect.tscn"),
	
	# Efectos de debuff
	"weakness_debuff": preload("res://scenes/effects/WeaknessDebuffEffect.tscn"),
	"slow_debuff": preload("res://scenes/effects/SlowDebuffEffect.tscn"),
	"confusion_debuff": preload("res://scenes/effects/ConfusionDebuffEffect.tscn"),
	
	# Efectos de estado
	"poison_status": preload("res://scenes/effects/PoisonStatusEffect.tscn"),
	"burn_status": preload("res://scenes/effects/BurnStatusEffect.tscn"),
	"stun_status": preload("res://scenes/effects/StunStatusEffect.tscn"),
	
	# Efectos especiales
	"time_dilation": preload("res://scenes/effects/TimeDilationEffect.tscn"),
	"mind_control": preload("res://scenes/effects/MindControlEffect.tscn"),
	"energy_shield": preload("res://scenes/effects/EnergyShieldEffect.tscn"),
	"mutant_reaction": preload("res://scenes/effects/MutantReactionEffect.tscn"),
	"singularity_beam": preload("res://scenes/effects/SingularityBeamEffect.tscn"),
	"seed_awakening": preload("res://scenes/effects/SeedAwakeningEffect.tscn")
}

# Variables
var active_effects: Dictionary = {}
var effect_counter: int = 0

# Función de inicialización
func _ready() -> void:
	pass

# Reproducir un efecto visual
func play_effect(effect_id: String, target: Node, duration: float = 1.0, params: Dictionary = {}) -> int:
	# Verificar si el efecto existe
	if not EFFECT_SCENES.has(effect_id):
		push_error("Efecto no encontrado: " + effect_id)
		return -1
	
	# Incrementar contador de efectos
	effect_counter += 1
	var unique_id = effect_counter
	
	# Instanciar efecto
	var effect_instance = EFFECT_SCENES[effect_id].instantiate()
	
	# Añadir efecto al objetivo
	if target.has_node("EffectsContainer"):
		target.get_node("EffectsContainer").add_child(effect_instance)
	else:
		target.add_child(effect_instance)
	
	# Configurar efecto
	if effect_instance.has_method("set_params"):
		effect_instance.set_params(params)
	
	# Iniciar efecto
	if effect_instance.has_method("play"):
		effect_instance.play()
	
	# Guardar referencia al efecto
	active_effects[unique_id] = {
		"instance": effect_instance,
		"effect_id": effect_id,
		"target": target
	}
	
	# Emitir señal
	emit_signal("effect_started", effect_id, target)
	
	# Configurar temporizador para eliminar el efecto
	var timer = get_tree().create_timer(duration)
	timer.connect("timeout", Callable(self, "_on_effect_timeout").bind(unique_id))
	
	return unique_id

# Detener un efecto visual
func stop_effect(effect_unique_id: int) -> void:
	# Verificar si el efecto existe
	if not active_effects.has(effect_unique_id):
		return
	
	# Obtener datos del efecto
	var effect_data = active_effects[effect_unique_id]
	var effect_instance = effect_data["instance"]
	var effect_id = effect_data["effect_id"]
	
	# Detener efecto
	if effect_instance.has_method("stop"):
		effect_instance.stop()
	else:
		effect_instance.queue_free()
	
	# Eliminar referencia
	active_effects.erase(effect_unique_id)
	
	# Emitir señal
	emit_signal("effect_finished", effect_id)

# Cuando finaliza el temporizador de un efecto
func _on_effect_timeout(effect_unique_id: int) -> void:
	stop_effect(effect_unique_id)

# Reproducir efecto de daño
func play_damage_effect(target: Node, damage_type: String, amount: int) -> int:
	# Determinar qué efecto usar según el tipo de daño
	var effect_id = "physical_hit"
	
	match damage_type:
		"physical":
			effect_id = "physical_hit"
		"energy":
			effect_id = "energy_blast"
		"toxic":
			effect_id = "toxic_damage"
		"psychic":
			effect_id = "psychic_damage"
	
	# Configurar parámetros
	var params = {
		"amount": amount,
		"critical": amount > 50  # Simplificación para determinar si es crítico
	}
	
	# Reproducir efecto
	return play_effect(effect_id, target, 0.8, params)

# Reproducir efecto de curación
func play_heal_effect(target: Node, heal_type: String, amount: int) -> int:
	# Determinar qué efecto usar
	var effect_id = "heal_effect"
	
	if heal_type == "energy":
		effect_id = "energy_restore"
	
	# Configurar parámetros
	var params = {
		"amount": amount
	}
	
	# Reproducir efecto
	return play_effect(effect_id, target, 1.2, params)

# Reproducir efecto de buff
func play_buff_effect(target: Node, buff_type: String, duration: float) -> int:
	# Determinar qué efecto usar
	var effect_id = "strength_buff"
	
	match buff_type:
		"strength":
			effect_id = "strength_buff"
		"defense":
			effect_id = "defense_buff"
		"speed":
			effect_id = "speed_buff"
	
	# Reproducir efecto
	return play_effect(effect_id, target, duration)

# Reproducir efecto de debuff
func play_debuff_effect(target: Node, debuff_type: String, duration: float) -> int:
	# Determinar qué efecto usar
	var effect_id = "weakness_debuff"
	
	match debuff_type:
		"weakness":
			effect_id = "weakness_debuff"
		"slow":
			effect_id = "slow_debuff"
		"confusion":
			effect_id = "confusion_debuff"
	
	# Reproducir efecto
	return play_effect(effect_id, target, duration)

# Reproducir efecto de estado
func play_status_effect(target: Node, status_type: String, duration: float) -> int:
	# Determinar qué efecto usar
	var effect_id = "poison_status"
	
	match status_type:
		"poison":
			effect_id = "poison_status"
		"burn":
			effect_id = "burn_status"
		"stun":
			effect_id = "stun_status"
	
	# Reproducir efecto
	return play_effect(effect_id, target, duration)

# Reproducir efecto de habilidad especial
func play_special_skill_effect(target: Node, skill_id: String, duration: float, params: Dictionary = {}) -> int:
	# Determinar qué efecto usar según la habilidad
	var effect_id = ""
	
	match skill_id:
		"mutation_time_dilation":
			effect_id = "time_dilation"
		"mutation_mind_control":
			effect_id = "mind_control"
		"tech_energy_shield":
			effect_id = "energy_shield"
		"tech_singularity_beam":
			effect_id = "singularity_beam"
		"mutation_seed_awakening":
			effect_id = "seed_awakening"
		_:
			# Si no hay un efecto específico, usar un efecto genérico según el árbol
			if skill_id.begins_with("combat_"):
				effect_id = "physical_hit"
			elif skill_id.begins_with("tech_"):
				effect_id = "energy_blast"
			elif skill_id.begins_with("mutation_"):
				effect_id = "toxic_damage"
	
	# Si no se encontró un efecto adecuado
	if effect_id.empty():
		return -1
	
	# Reproducir efecto
	return play_effect(effect_id, target, duration, params)

# Reproducir efecto de Reacción Mutante
func play_mutant_reaction_effect(target: Node, reaction_type: String, duration: float) -> int:
	# Configurar parámetros según el tipo de reacción
	var params = {
		"reaction_type": reaction_type
	}
	
	# Reproducir efecto
	return play_effect("mutant_reaction", target, duration, params)

# Limpiar todos los efectos activos
func clear_all_effects() -> void:
	# Crear una copia de las claves para evitar problemas al modificar el diccionario durante la iteración
	var effect_ids = active_effects.keys()
	
	# Detener cada efecto
	for effect_id in effect_ids:
		stop_effect(effect_id)