extends Node2D

# Señales
signal effect_started
signal effect_finished

# Variables
var params: Dictionary = {}
var is_playing: bool = false

# Referencias a nodos
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var particles = $Particles2D if has_node("Particles2D") else null
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null
@onready var audio_player = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null

# Función de inicialización
func _ready() -> void:
	# Conectar señales de animación si existe
	if animation_player:
		animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	# Configurar para que no se reproduzca automáticamente
	if particles:
		particles.emitting = false
	
	# Ocultar sprite inicialmente
	if sprite:
		sprite.visible = false

# Establecer parámetros del efecto
func set_params(p_params: Dictionary) -> void:
	params = p_params
	
	# Aplicar parámetros específicos
	apply_params()

# Aplicar parámetros específicos (a sobrescribir en clases hijas)
func apply_params() -> void:
	pass

# Reproducir efecto
func play() -> void:
	# Marcar como reproduciendo
	is_playing = true
	
	# Mostrar sprite si existe
	if sprite:
		sprite.visible = true
	
	# Iniciar partículas si existen
	if particles:
		particles.emitting = true
	
	# Reproducir animación si existe
	if animation_player and animation_player.has_animation("play"):
		animation_player.play("play")
	
	# Reproducir sonido si existe
	if audio_player:
		audio_player.play()
	
	# Emitir señal
	emit_signal("effect_started")
	
	# Si no hay animación ni partículas, finalizar automáticamente
	if not animation_player and not particles:
		_finish_effect()

# Detener efecto
func stop() -> void:
	# Verificar si está reproduciendo
	if not is_playing:
		return
	
	# Detener animación si existe
	if animation_player:
		animation_player.stop()
	
	# Detener partículas si existen
	if particles:
		particles.emitting = false
	
	# Detener sonido si existe
	if audio_player:
		audio_player.stop()
	
	# Finalizar efecto
	_finish_effect()

# Finalizar efecto
func _finish_effect() -> void:
	# Marcar como no reproduciendo
	is_playing = false
	
	# Ocultar sprite si existe
	if sprite:
		sprite.visible = false
	
	# Emitir señal
	emit_signal("effect_finished")
	
	# Liberar memoria
	queue_free()

# Cuando finaliza la animación
func _on_animation_finished(anim_name: String) -> void:
	# Verificar si es la animación principal
	if anim_name == "play":
		# Si hay partículas, esperar a que terminen
		if particles and particles.emitting:
			# Detener emisión pero esperar a que las partículas existentes desaparezcan
			particles.emitting = false
			
			# Crear temporizador para esperar
			var timer = get_tree().create_timer(particles.lifetime)
			timer.connect("timeout", Callable(self, "_finish_effect"))
		else:
			# Finalizar efecto inmediatamente
			_finish_effect()

# Mostrar texto flotante (daño, curación, etc.)
func show_floating_text(text: String, color: Color = Color.WHITE) -> void:
	# Verificar si existe la escena de texto flotante
	var FloatingText = load("res://scenes/effects/FloatingText.tscn")
	if not FloatingText:
		return
	
	# Instanciar texto flotante
	var floating_text = FloatingText.instantiate()
	get_parent().add_child(floating_text)
	
	# Configurar texto flotante
	floating_text.global_position = global_position + Vector2(0, -20)
	floating_text.set_text(text, color)
	floating_text.play()

# Reproducir sonido específico
func play_sound(sound_path: String) -> void:
	# Verificar si existe el reproductor de audio
	if not audio_player:
		return
	
	# Cargar sonido
	var sound = load(sound_path)
	if not sound:
		return
	
	# Configurar y reproducir sonido
	audio_player.stream = sound
	audio_player.play()