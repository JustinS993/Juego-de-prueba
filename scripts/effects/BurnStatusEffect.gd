extends "res://scripts/effects/BaseEffect.gd"

# Variables específicas para el efecto de estado de quemadura
var duration: int = 2  # Duración en turnos
var intensity: int = 1  # Intensidad de la quemadura (1-5)
var target_node: Node = null  # Nodo objetivo al que se aplica el efecto
var is_persistent: bool = true  # Si el efecto persiste entre turnos

# Colores para diferentes intensidades
const BURN_COLORS = [
	Color(1.0, 0.7, 0.2),  # Intensidad 1 - Naranja claro
	Color(1.0, 0.6, 0.1),  # Intensidad 2 - Naranja
	Color(1.0, 0.5, 0.0),  # Intensidad 3 - Naranja oscuro
	Color(0.9, 0.4, 0.0),  # Intensidad 4 - Rojo-naranja
	Color(0.8, 0.2, 0.0)   # Intensidad 5 - Rojo fuego
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
	var burn_color = BURN_COLORS[color_index]
	
	if particles:
		particles.modulate = burn_color
		
		# Ajustar cantidad de partículas según intensidad
		particles.amount = 15 + (intensity * 5)
	
	# Mostrar texto flotante con el estado
	var status_text = "¡Quemado!"
	show_floating_text(status_text, burn_color)
	
	# Si hay un nodo objetivo, aplicar efecto visual
	if target_node and target_node.has_method("apply_visual_effect"):
		target_node.apply_visual_effect("burn", burn_color, duration)

# Reproducir efecto
func play() -> void:
	# Reproducir sonido
	play_sound("res://assets/audio/effects/burn_status.wav")
	
	# Llamar a la función base
	super.play()
	
	# Si es persistente, no finalizar automáticamente
	if is_persistent:
		# Desconectar la señal de finalización de animación para evitar que se destruya
		if animation_player and animation_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			animation_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

# Aplicar daño de quemadura
func apply_burn_damage() -> void:
	# Verificar si hay un nodo objetivo
	if not target_node or not target_node.has_method("take_damage"):
		return
	
	# Calcular daño basado en la intensidad
	var damage = intensity * 8  # 8, 16, 24, 32, 40 de daño según intensidad
	
	# Aplicar daño
	target_node.take_damage(damage, "fire")
	
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
		target_node.remove_visual_effect("burn")
	
	# Mostrar texto flotante
	show_floating_text("¡Fuego extinguido!", Color(1.0, 0.7, 0.2, 0.5))
	
	# Llamar a la función base
	super._finish_effect()