extends "res://scripts/effects/BaseEffect.gd"

# Variables específicas para el efecto de curación
var heal_amount: int = 0
var heal_type: String = "normal"  # normal, critical, minor

# Colores para diferentes tipos de curación
const NORMAL_COLOR = Color(0.2, 1.0, 0.4)  # Verde
const CRITICAL_COLOR = Color(0.0, 1.0, 0.8)  # Turquesa
const MINOR_COLOR = Color(0.5, 0.8, 0.5)  # Verde pálido

# Aplicar parámetros específicos
func apply_params() -> void:
	# Obtener cantidad de curación
	if params.has("heal_amount"):
		heal_amount = params["heal_amount"]
	
	# Obtener tipo de curación
	if params.has("heal_type"):
		heal_type = params["heal_type"]
	
	# Aplicar color basado en el tipo
	if particles:
		match heal_type:
			"critical":
				particles.modulate = CRITICAL_COLOR
			"minor":
				particles.modulate = MINOR_COLOR
			_:
				particles.modulate = NORMAL_COLOR
	
	# Aplicar escala basada en la cantidad de curación
	var scale_factor = clamp(float(heal_amount) / 50.0, 0.5, 2.0)
	scale = Vector2(scale_factor, scale_factor)
	
	# Aplicar velocidad de animación basada en el tipo
	if animation_player:
		match heal_type:
			"critical":
				animation_player.speed_scale = 1.5
			"minor":
				animation_player.speed_scale = 0.8
			_:
				animation_player.speed_scale = 1.0
	
	# Mostrar texto flotante con la curación
	if heal_amount > 0:
		var heal_text = "+" + str(heal_amount)
		var text_color = NORMAL_COLOR
		var is_critical = false
		
		# Determinar color y si es crítico
		match heal_type:
			"critical":
				text_color = CRITICAL_COLOR
				is_critical = true
			"minor":
				text_color = MINOR_COLOR
			_:
				text_color = NORMAL_COLOR
		
		# Mostrar texto flotante
		show_floating_text(heal_text, text_color)
		
		# Si es crítico, configurar el texto flotante como crítico
		if is_critical:
			var floating_texts = get_tree().get_nodes_in_group("floating_text")
			for text_node in floating_texts:
				if text_node.text == heal_text and text_node.text_color == text_color:
					text_node.set_critical(true)
					break

# Reproducir sonido específico según el tipo de curación
func play() -> void:
	# Reproducir sonido según el tipo
	var sound_path = "res://assets/audio/effects/heal_normal.wav"
	
	match heal_type:
		"critical":
			sound_path = "res://assets/audio/effects/heal_critical.wav"
		"minor":
			sound_path = "res://assets/audio/effects/heal_minor.wav"
		_:
			sound_path = "res://assets/audio/effects/heal_normal.wav"
	
	# Reproducir sonido
	play_sound(sound_path)
	
	# Llamar a la función base
	super.play()