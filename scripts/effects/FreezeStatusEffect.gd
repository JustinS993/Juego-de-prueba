extends "res://scripts/effects/BaseEffect.gd"

# Variables específicas para el efecto de estado de congelación
var duration: int = 2  # Duración en turnos
var intensity: int = 1  # Intensidad de la congelación (1-5)
var target_node: Node = null  # Nodo objetivo al que se aplica el efecto
var is_persistent: bool = true  # Si el efecto persiste entre turnos

# Colores para diferentes intensidades
const FREEZE_COLORS = [
	Color(0.7, 0.8, 1.0),  # Intensidad 1 - Azul claro
	Color(0.5, 0.7, 1.0),  # Intensidad 2 - Azul
	Color(0.3, 0.6, 0.9),  # Intensidad 3 - Azul medio
	Color(0.2, 0.5, 0.8),  # Intensidad 4 - Azul oscuro
	Color(0.1, 0.4, 0.7)   # Intensidad 5 - Azul profundo
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
	
	# Aplicar color basado en la intensidad
	var color_index = clamp(intensity - 1, 0, 4)
	var freeze_color = FREEZE_COLORS[color_index]
	
	if particles:
		particles.modulate = freeze_color
		
		# Ajustar cantidad de partículas según intensidad
		particles.amount = 15 + (intensity * 5)
	
	# Mostrar texto flotante con el estado
	var status_text = "¡Congelado!"
	show_floating_text(status_text, freeze_color)
	
	# Si hay un nodo objetivo, aplicar efecto visual
	if target_node and target_node.has_method("apply_visual_effect"):
		target_node.apply_visual_effect("freeze", freeze_color, duration)
		
		# Aplicar ralentización al objetivo si tiene la función
		if target_node.has_method("apply_speed_modifier"):
			# Reducir velocidad según intensidad (20% a 60%)
			var speed_modifier = 1.0 - (0.1 * (intensity + 1))
			target_node.apply_speed_modifier(speed_modifier, duration, "freeze")

# Reproducir efecto
func play() -> void:
	# Reproducir sonido
	play_sound("res://assets/audio/effects/freeze_status.wav")
	
	# Llamar a la función base
	super.play()
	
	# Si es persistente, no finalizar automáticamente
	if is_persistent:
		# Desconectar la señal de finalización de animación para evitar que se destruya
		if animation_player and animation_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			animation_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

# Aplicar daño de congelación
func apply_freeze_damage() -> void:
	# Verificar si hay un nodo objetivo
	if not target_node or not target_node.has_method("take_damage"):
		return
	
	# Calcular daño basado en la intensidad
	var damage = intensity * 3  # 3, 6, 9, 12, 15 de daño según intensidad
	
	# Aplicar daño
	target_node.take_damage(damage, "ice")
	
	# Reproducir animación de daño
	if animation_player and animation_player.has_animation("damage_pulse"):
		animation_player.play("damage_pulse")

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
		target_node.remove_visual_effect("freeze")
		
		# Restaurar velocidad normal
		if target_node.has_method("remove_speed_modifier"):
			target_node.remove_speed_modifier("freeze")
	
	# Mostrar texto flotante
	show_floating_text("¡Descongelado!", Color(0.7, 0.8, 1.0, 0.5))
	
	# Llamar a la función base
	super._finish_effect()