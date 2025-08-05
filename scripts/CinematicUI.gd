extends CanvasLayer

# Añadir al grupo para recibir señales del CinematicManager
func _ready():
	add_to_group("cinematic_ui")

# Referencias a nodos de la UI
onready var background = $Background
onready var text_panel = $TextPanel
onready var narration_text = $TextPanel/NarrationText
onready var character_container = $CharacterContainer
onready var choices_panel = $ChoicesPanel
onready var choices_container = $ChoicesPanel/ChoicesContainer
onready var animation_player = $AnimationPlayer
onready var camera_effects = $CameraEffects
onready var particle_container = $ParticleContainer
onready var audio_player = $AudioPlayer
onready var sfx_player = $SFXPlayer

# Variables para controlar la cinemática
var current_scene_data = null
var is_showing_choices = false
var choice_buttons = []
var scene_timer = null
var skip_requested = false

# Mostrar una escena de cinemática
func show_scene(scene_data):
	# Guardar los datos de la escena actual
	current_scene_data = scene_data
	is_showing_choices = false
	
	# Ocultar panel de opciones
	choices_panel.visible = false
	
	# Limpiar escena anterior
	clear_scene()
	
	# Configurar el fondo
	if scene_data.has("background") and scene_data["background"] != "":
		var texture = load(scene_data["background"])
		if texture:
			background.texture = texture
			background.visible = true
	
	# Configurar el texto
	if scene_data.has("text") and scene_data["text"] != "":
		narration_text.text = scene_data["text"]
		text_panel.visible = true
		
		# Ajustar estilo según si es narración o diálogo
		if scene_data.has("narration") and scene_data["narration"]:
			narration_text.add_color_override("default_color", Color(0.9, 0.9, 0.9))
			narration_text.align = RichTextLabel.ALIGN_CENTER
		else:
			narration_text.add_color_override("default_color", Color(1.0, 0.8, 0.2))
			narration_text.align = RichTextLabel.ALIGN_LEFT
	
	# Añadir personajes si existen
	if scene_data.has("characters") and scene_data["characters"].size() > 0:
		for character_data in scene_data["characters"]:
			add_character(character_data)
	
	# Reproducir música si existe
	if scene_data.has("music") and scene_data["music"] != "":
		var music_stream = load(scene_data["music"])
		if music_stream:
			audio_player.stream = music_stream
			audio_player.play()
	
	# Reproducir efectos de sonido si existen
	if scene_data.has("sound_effects") and scene_data["sound_effects"].size() > 0:
		for sfx_data in scene_data["sound_effects"]:
			play_sound_effect(sfx_data)
	
	# Aplicar efectos de cámara si existen
	if scene_data.has("camera_effects") and not scene_data["camera_effects"].empty():
		apply_camera_effect(scene_data["camera_effects"])
	
	# Aplicar efectos de partículas si existen
	if scene_data.has("particle_effects") and scene_data["particle_effects"].size() > 0:
		for particle_data in scene_data["particle_effects"]:
			add_particle_effect(particle_data)
	
	# Mostrar la escena con animación
	animation_player.play("scene_appear")
	
	# Configurar temporizador para la duración de la escena
	if scene_data.has("duration") and scene_data["duration"] > 0:
		scene_timer = Timer.new()
		scene_timer.one_shot = true
		scene_timer.wait_time = scene_data["duration"]
		scene_timer.connect("timeout", self, "_on_scene_timer_timeout")
		add_child(scene_timer)
		scene_timer.start()

# Limpiar elementos de la escena actual
func clear_scene():
	# Detener temporizador si existe
	if scene_timer:
		scene_timer.stop()
		scene_timer.queue_free()
		scene_timer = null
	
	# Limpiar personajes
	for child in character_container.get_children():
		child.queue_free()
	
	# Limpiar partículas
	for child in particle_container.get_children():
		child.queue_free()
	
	# Restablecer efectos de cámara
	camera_effects.material.set_shader_param("distortion_amount", 0.0)
	camera_effects.material.set_shader_param("blur_amount", 0.0)
	camera_effects.material.set_shader_param("aberration_amount", 0.0)

# Añadir un personaje a la escena
func add_character(character_data):
	var character = TextureRect.new()
	character_container.add_child(character)
	
	# Configurar la textura del personaje
	var texture_path = "res://assets/characters/" + character_data["name"].to_lower().replace(" ", "_")
	if character_data.has("emotion"):
		texture_path += "_" + character_data["emotion"]
	texture_path += ".png"
	
	var texture = load(texture_path)
	if texture:
		character.texture = texture
	else:
		# Cargar una textura por defecto si no se encuentra
		character.texture = load("res://assets/characters/default.png")
	
	# Configurar la posición del personaje
	if character_data.has("position"):
		match character_data["position"]:
			"left":
				character.rect_position.x = 100
			"center":
				character.rect_position.x = (get_viewport_rect().size.x - character.texture.get_width()) / 2
			"right":
				character.rect_position.x = get_viewport_rect().size.x - character.texture.get_width() - 100
	
	# Animar la aparición del personaje
	character.modulate = Color(1, 1, 1, 0)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(character, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

# Reproducir un efecto de sonido
func play_sound_effect(sfx_data):
	var sfx_path = "res://assets/sounds/" + sfx_data["name"] + ".ogg"
	var stream = load(sfx_path)
	
	if stream:
		sfx_player.stream = stream
		
		# Configurar volumen si está especificado
		if sfx_data.has("volume"):
			sfx_player.volume_db = sfx_data["volume"]
		
		# Reproducir con retraso si está especificado
		if sfx_data.has("position") and sfx_data["position"] > 0:
			yield(get_tree().create_timer(sfx_data["position"]), "timeout")
		
		sfx_player.play()

# Aplicar un efecto de cámara
func apply_camera_effect(effect_data):
	match effect_data["type"]:
		"fade_in":
			animation_player.play("fade_in")
		"fade_out":
			animation_player.play("fade_out")
		"distortion":
			camera_effects.material.set_shader_param("distortion_amount", effect_data["intensity"])
		"focus":
			animation_player.play("focus_" + effect_data["target"])
		"pulse":
			var pulse_tween = Tween.new()
			add_child(pulse_tween)
			pulse_tween.interpolate_property(camera_effects.material, "shader_param/aberration_amount", 
				0.0, 0.05, 0.5 / effect_data["frequency"], Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
			pulse_tween.interpolate_property(camera_effects.material, "shader_param/aberration_amount", 
				0.05, 0.0, 0.5 / effect_data["frequency"], Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5 / effect_data["frequency"])
			pulse_tween.set_loops(int(current_scene_data["duration"] * effect_data["frequency"]))
			pulse_tween.start()
		"split":
			animation_player.play("split_" + str(effect_data["parts"]))

# Añadir un efecto de partículas
func add_particle_effect(particle_data):
	var particles = Particles2D.new()
	particle_container.add_child(particles)
	
	# Configurar las partículas según el tipo
	match particle_data["type"]:
		"glow":
			var material = ParticlesMaterial.new()
			material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
			material.emission_sphere_radius = 50.0
			material.gravity = Vector3(0, -10, 0)
			material.initial_velocity = 5.0
			material.scale = 2.0
			material.scale_random = 0.5
			material.color = Color(particle_data["color"])
			particles.process_material = material
			
			# Posicionar en el centro de la pantalla
			particles.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
			particles.amount = int(50 * particle_data["intensity"])
			particles.lifetime = 2.0
			particles.emitting = true
		
		"particles":
			var material = ParticlesMaterial.new()
			material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
			material.emission_box_extents = Vector3(get_viewport_rect().size.x / 2, 10, 1)
			material.gravity = Vector3(0, 30, 0)
			material.initial_velocity = 20.0
			material.initial_velocity_random = 0.5
			material.scale = 3.0
			material.scale_random = 0.5
			particles.process_material = material
			
			# Posicionar en la parte superior de la pantalla
			particles.position = Vector2(get_viewport_rect().size.x / 2, 0)
			particles.amount = particle_data["amount"]
			particles.lifetime = 4.0
			particles.emitting = true

# Mostrar opciones de elección
func show_choices(choices):
	# Marcar que estamos mostrando opciones
	is_showing_choices = true
	
	# Mostrar el panel de opciones
	choices_panel.visible = true
	
	# Limpiar opciones anteriores
	clear_choices()
	
	# Añadir las nuevas opciones
	for i in range(choices.size()):
		add_choice_button(choices[i]["text"], i)
	
	# Animar la aparición del panel
	animation_player.play("choices_appear")

# Añadir un botón de opción
func add_choice_button(choice_text, choice_index):
	var button = Button.new()
	button.text = choice_text
	button.connect("pressed", self, "_on_choice_button_pressed", [choice_index])
	choices_container.add_child(button)
	choice_buttons.append(button)

# Limpiar todas las opciones
func clear_choices():
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

# Función llamada cuando se presiona un botón de opción
func _on_choice_button_pressed(choice_index):
	# Seleccionar la opción en el CinematicManager
	CinematicManager.select_cinematic_choice(choice_index)
	
	# Ocultar el panel de opciones
	animation_player.play("choices_disappear")
	yield(animation_player, "animation_finished")
	choices_panel.visible = false
	is_showing_choices = false

# Función llamada cuando expira el temporizador de la escena
func _on_scene_timer_timeout():
	# Si estamos mostrando opciones, no avanzar automáticamente
	if is_showing_choices:
		return
	
	# Animar la desaparición de la escena
	animation_player.play("scene_disappear")
	yield(animation_player, "animation_finished")
	
	# Avanzar a la siguiente escena
	CinematicManager.show_next_scene()

# Saltar la escena actual
func skip_scene():
	# Si ya se solicitó saltar, no hacer nada
	if skip_requested:
		return
	
	skip_requested = true
	
	# Detener el temporizador
	if scene_timer:
		scene_timer.stop()
	
	# Animar la desaparición de la escena
	animation_player.play("scene_disappear")
	yield(animation_player, "animation_finished")
	
	# Avanzar a la siguiente escena
	CinematicManager.show_next_scene()
	skip_requested = false

# Saltar toda la cinemática
func skip_cinematic():
	# Detener el temporizador
	if scene_timer:
		scene_timer.stop()
	
	# Animar la desaparición de la escena
	animation_player.play("scene_disappear")
	yield(animation_player, "animation_finished")
	
	# Finalizar la cinemática
	CinematicManager.end_cinematic()

# Procesar entrada de teclado
func _input(event):
	if event is InputEventKey and event.pressed:
		# Tecla Espacio o Enter para avanzar/saltar escena
		if event.scancode == KEY_SPACE or event.scancode == KEY_ENTER:
			if is_showing_choices:
				return
			skip_scene()
		
		# Tecla Escape para saltar toda la cinemática
		elif event.scancode == KEY_ESCAPE:
			skip_cinematic()