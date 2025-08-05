extends "res://scripts/effects/BaseEffect.gd"

# Variables específicas para el efecto de golpe físico
var hit_strength: float = 1.0  # Intensidad del golpe (afecta tamaño y velocidad)
var hit_type: String = "normal"  # normal, critical, weak

# Colores para diferentes tipos de golpes
const NORMAL_COLOR = Color(1.0, 0.7, 0.2)  # Naranja
const CRITICAL_COLOR = Color(1.0, 0.2, 0.2)  # Rojo
const WEAK_COLOR = Color(0.7, 0.7, 0.7)  # Gris

# Aplicar parámetros específicos
func apply_params() -> void:
	# Obtener intensidad del golpe
	if params.has("hit_strength"):
		hit_strength = params["hit_strength"]
	
	# Obtener tipo de golpe
	if params.has("hit_type"):
		hit_type = params["hit_type"]
	
	# Aplicar escala basada en la intensidad
	scale = Vector2(hit_strength, hit_strength).clamp(Vector2(0.5, 0.5), Vector2(2.0, 2.0))
	
	# Aplicar color basado en el tipo
	if sprite:
		match hit_type:
			"critical":
				sprite.modulate = CRITICAL_COLOR
			"weak":
				sprite.modulate = WEAK_COLOR
			_:
				sprite.modulate = NORMAL_COLOR
	
	# Aplicar velocidad de animación basada en la intensidad
	if animation_player:
		animation_player.speed_scale = 1.0 + (hit_strength - 1.0) * 0.5
	
	# Mostrar texto flotante con el daño
	if params.has("damage"):
		var damage_text = str(params["damage"])
		var text_color = NORMAL_COLOR
		var is_critical = false
		
		# Determinar color y si es crítico
		match hit_type:
			"critical":
				text_color = CRITICAL_COLOR
				is_critical = true
			"weak":
				text_color = WEAK_COLOR
			_:
				text_color = NORMAL_COLOR
		
		# Mostrar texto flotante
		show_floating_text(damage_text, text_color)
		
		# Si es crítico, configurar el texto flotante como crítico
		if is_critical:
			var floating_texts = get_tree().get_nodes_in_group("floating_text")
			for text_node in floating_texts:
				if text_node.text == damage_text and text_node.text_color == text_color:
					text_node.set_critical(true)
					break

# Reproducir sonido específico según el tipo de golpe
func play() -> void:
	# Reproducir sonido según el tipo
	var sound_path = "res://assets/audio/effects/hit_normal.wav"
	
	match hit_type:
		"critical":
			sound_path = "res://assets/audio/effects/hit_critical.wav"
		"weak":
			sound_path = "res://assets/audio/effects/hit_weak.wav"
		_:
			sound_path = "res://assets/audio/effects/hit_normal.wav"
	
	# Reproducir sonido
	play_sound(sound_path)
	
	# Llamar a la función base
	super.play()