extends "res://scripts/effects/BaseEffect.gd"

# Variables específicas para el efecto de Reacción Mutante
var reaction_type: String = "power"  # power, speed, defense, control, drain
var target_node: Node = null  # Nodo objetivo (generalmente el jugador)
var duration: float = 3.0  # Duración en segundos del efecto visual

# Colores para diferentes tipos de reacción
const REACTION_COLORS = {
	"power": Color(1.0, 0.2, 0.5),    # Magenta - Aumenta daño
	"speed": Color(0.2, 1.0, 0.5),    # Verde brillante - Aumenta velocidad/agilidad
	"defense": Color(0.2, 0.5, 1.0),   # Azul - Aumenta resistencia/defensa
	"control": Color(0.8, 0.2, 1.0),   # Púrpura - Control mental/tiempo
	"drain": Color(1.0, 0.5, 0.0)      # Naranja - Absorción de vida/energía
}

# Aplicar parámetros específicos
func apply_params() -> void:
	# Obtener tipo de reacción
	if params.has("reaction_type"):
		reaction_type = params["reaction_type"]
	
	# Obtener nodo objetivo
	if params.has("target_node"):
		target_node = params["target_node"]
	
	# Obtener duración
	if params.has("duration"):
		duration = params["duration"]
	
	# Aplicar color basado en el tipo de reacción
	var reaction_color = REACTION_COLORS[reaction_type] if REACTION_COLORS.has(reaction_type) else Color(1.0, 1.0, 1.0)
	
	if particles:
		particles.modulate = reaction_color
		
		# Ajustar cantidad de partículas
		particles.amount = 50
	
	# Aplicar color a la luz
	if has_node("Light"):
		get_node("Light").color = reaction_color
	
	# Mostrar texto flotante con el tipo de reacción
	var reaction_text = "¡REACCIÓN MUTANTE!"
	show_floating_text(reaction_text, reaction_color)
	
	# Si hay un nodo objetivo, aplicar efecto visual
	if target_node and target_node.has_method("apply_visual_effect"):
		target_node.apply_visual_effect("mutant_reaction", reaction_color, duration)

# Reproducir efecto
func play() -> void:
	# Reproducir sonido
	play_sound("res://assets/audio/effects/mutant_reaction.wav")
	
	# Llamar a la función base
	super.play()
	
	# Configurar temporizador para finalizar el efecto
	var timer = get_tree().create_timer(duration)
	timer.connect("timeout", Callable(self, "_finish_effect"))

# Aplicar efecto específico según el tipo de reacción
func apply_reaction_effect() -> void:
	# Verificar si hay un nodo objetivo
	if not target_node:
		return
	
	# Aplicar efecto según el tipo de reacción
	match reaction_type:
		"power":
			# Aumentar daño
			if target_node.has_method("apply_damage_modifier"):
				target_node.apply_damage_modifier(2.0, 3, "mutant_reaction")
		"speed":
			# Aumentar velocidad/agilidad
			if target_node.has_method("apply_speed_modifier"):
				target_node.apply_speed_modifier(2.0, 3, "mutant_reaction")
		"defense":
			# Aumentar resistencia/defensa
			if target_node.has_method("apply_defense_modifier"):
				target_node.apply_defense_modifier(2.0, 3, "mutant_reaction")
		"control":
			# Control mental/tiempo (afecta a todos los enemigos)
			if target_node.has_method("apply_control_effect"):
				target_node.apply_control_effect(2, "mutant_reaction")
		"drain":
			# Absorción de vida/energía
			if target_node.has_method("apply_drain_effect"):
				target_node.apply_drain_effect(3, "mutant_reaction")

# Finalizar efecto
func _finish_effect() -> void:
	# Si hay un nodo objetivo, eliminar efecto visual
	if target_node and target_node.has_method("remove_visual_effect"):
		target_node.remove_visual_effect("mutant_reaction")
	
	# Llamar a la función base
	super._finish_effect()