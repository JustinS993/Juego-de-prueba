extends "res://scripts/effects/BaseEffect.gd"

# Variables específicas para el efecto de estado de electrificación
var duration: int = 2  # Duración en turnos
var intensity: int = 1  # Intensidad de la electrificación (1-5)
var target_node: Node = null  # Nodo objetivo al que se aplica el efecto
var is_persistent: bool = true  # Si el efecto persiste entre turnos
var can_spread: bool = false  # Si el efecto puede propagarse a objetivos cercanos

# Colores para diferentes intensidades
const SHOCK_COLORS = [
	Color(0.8, 0.8, 1.0),  # Intensidad 1 - Azul eléctrico claro
	Color(0.6, 0.6, 1.0),  # Intensidad 2 - Azul eléctrico
	Color(0.4, 0.4, 1.0),  # Intensidad 3 - Azul eléctrico medio
	Color(0.3, 0.3, 1.0),  # Intensidad 4 - Azul eléctrico oscuro
	Color(0.2, 0.2, 1.0)   # Intensidad 5 - Azul eléctrico profundo
]

# Aplicar parámetros específicos
func apply_params() -> void:
	# Obtener duración
	if params.has("duration"):
		duration = params["duration"]
	
	# Obtener intensidad
	if params.has("intensity"):
		intensity = clamp(params["intensity"], 1, 5)
	
	# Obtener nodo objetivo
	if params.has("target_node"):
		target_node = params["target_node"]
	
	# Obtener si es persistente
	if params.has("is_persistent"):
		is_persistent = params["is_persistent"]
	
	# Obtener si puede propagarse
	if params.has("can_spread"):
		can_spread = params["can_spread"]
	
	# Aplicar color basado en la intensidad
	var color_index = clamp(intensity - 1, 0, 4)
	var shock_color = SHOCK_COLORS[color_index]
	
	if particles:
		particles.modulate = shock_color
		
		# Ajustar cantidad de partículas según intensidad
		particles.amount = 20 + (intensity * 5)
	
	# Mostrar texto flotante con el estado
	var status_text = "¡Electrificado!"
	show_floating_text(status_text, shock_color)
	
	# Si hay un nodo objetivo, aplicar efecto visual
	if target_node and target_node.has_method("apply_visual_effect"):
		target_node.apply_visual_effect("shock", shock_color, duration)
		
		# Aplicar penalización a la precisión si tiene la función
		if target_node.has_method("apply_accuracy_modifier"):
			# Reducir precisión según intensidad (10% a 30%)
			var accuracy_modifier = 1.0 - (0.05 * (intensity + 1))
			target_node.apply_accuracy_modifier(accuracy_modifier, duration, "shock")

# Reproducir efecto
func play() -> void:
	# Reproducir sonido
	play_sound("res://assets/audio/effects/shock_status.wav")
	
	# Llamar a la función base
	super.play()
	
	# Si es persistente, no finalizar automáticamente
	if is_persistent:
		# Desconectar la señal de finalización de animación para evitar que se destruya
		if animation_player and animation_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			animation_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

# Aplicar daño de electrificación
func apply_shock_damage() -> void:
	# Verificar si hay un nodo objetivo
	if not target_node or not target_node.has_method("take_damage"):
		return
	
	# Calcular daño basado en la intensidad
	var damage = intensity * 6  # 6, 12, 18, 24, 30 de daño según intensidad
	
	# Aplicar daño
	target_node.take_damage(damage, "electric")
	
	# Reproducir animación de daño
	if animation_player and animation_player.has_animation("damage_pulse"):
		animation_player.play("damage_pulse")
	
	# Si puede propagarse, intentar propagar a objetivos cercanos
	if can_spread and target_node.has_method("get_nearby_entities"):
		var nearby_entities = target_node.get_nearby_entities(100.0)  # Radio de 100 unidades
		
		# Limitar la propagación a máximo 2 objetivos
		var spread_count = min(nearby_entities.size(), 2)
		
		# Propagar a objetivos cercanos con intensidad reducida
		for i in range(spread_count):
			var entity = nearby_entities[i]
			
			# Verificar si la entidad puede recibir efectos de estado
			if entity.has_method("apply_status_effect"):
				# Propagar con intensidad reducida y duración reducida
				var spread_intensity = max(1, intensity - 1)
				var spread_duration = max(1, duration - 1)
				
				# Aplicar efecto de estado
				entity.apply_status_effect("shock", spread_intensity, spread_duration)

# Reducir duración
func reduce_duration() -> bool:
	# Reducir duración
	duration -= 1
	
	# Verificar si el efecto ha terminado
	if duration <= 0:
		# Finalizar efecto
		_finish_effect()
		return false
	
	# El efecto continúa
	return true

# Finalizar efecto
func _finish_effect() -> void:
	# Si hay un nodo objetivo, eliminar efecto visual
	if target_node and target_node.has_method("remove_visual_effect"):
		target_node.remove_visual_effect("shock")
		
		# Restaurar precisión normal
		if target_node.has_method("remove_accuracy_modifier"):
			target_node.remove_accuracy_modifier("shock")
	
	# Mostrar texto flotante
	show_floating_text("¡Descarga disipada!", Color(0.8, 0.8, 1.0, 0.5))
	
	# Llamar a la función base
	super._finish_effect()