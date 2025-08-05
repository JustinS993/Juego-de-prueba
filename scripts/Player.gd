extends CharacterBody2D

# Señales
signal health_changed(new_health, max_health)
signal energy_changed(new_energy, max_energy)
signal mutant_charge_changed(new_charge, max_charge)
signal level_up(new_level)
signal interaction_available(object)
signal interaction_unavailable()

# Constantes de movimiento
const SPEED = 100.0
const SPRINT_MULTIPLIER = 1.5
const INTERACTION_DISTANCE = 50.0

# Variables de estado
var is_sprinting: bool = false
var is_interacting: bool = false
var current_interaction_object = null
var is_in_combat: bool = false
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0

# Referencias a nodos
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var interaction_area = $InteractionArea
@onready var effects_container = $EffectsContainer

# Función de inicialización
func _ready() -> void:
	# Conectar señales
	interaction_area.connect("area_entered", Callable(self, "_on_interaction_area_entered"))
	interaction_area.connect("area_exited", Callable(self, "_on_interaction_area_exited"))
	
	# Inicializar estadísticas del jugador desde el GameManager
	_update_stats_from_game_manager()
	
	# Conectar señales del GameManager
	GameManager.connect("player_stats_changed", Callable(self, "_on_player_stats_changed"))
	
	# Configurar el área de interacción
	interaction_area.monitoring = true
	interaction_area.monitorable = true

# Función llamada cada frame para procesar la entrada del jugador
func _process(delta: float) -> void:
	# Procesar interacción
	if Input.is_action_just_pressed("interact") and current_interaction_object and not is_in_combat:
		interact_with_object(current_interaction_object)
	
	# Actualizar temporizador de invulnerabilidad
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0:
			is_invulnerable = false
			# Restaurar opacidad normal
			sprite.modulate.a = 1.0

# Función llamada cada frame para la física
func _physics_process(delta: float) -> void:
	# Solo permitir movimiento si no está en combate
	if is_in_combat:
		return
	
	# Obtener dirección de entrada
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	# Normalizar para evitar movimiento más rápido en diagonal
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	# Verificar si está corriendo
	is_sprinting = Input.is_action_pressed("sprint") and GameManager.player_data["energy"] > 0
	
	# Calcular velocidad
	var current_speed = SPEED
	if is_sprinting:
		current_speed *= SPRINT_MULTIPLIER
		# Consumir energía al correr
		GameManager.modify_player_stat("energy", -delta * 5)
	
	# Aplicar movimiento
	velocity = direction * current_speed
	move_and_slide()
	
	# Actualizar animación
	update_animation(direction)

# Actualizar la animación según la dirección
func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		if animation_player.is_playing():
			animation_player.stop()
		return
	
	# Determinar la dirección para la animación
	var anim_name = "idle"
	
	if abs(direction.x) > abs(direction.y):
		# Movimiento horizontal
		if direction.x > 0:
			anim_name = "walk_right"
			sprite.flip_h = false
		else:
			anim_name = "walk_right"
			sprite.flip_h = true
	else:
		# Movimiento vertical
		if direction.y > 0:
			anim_name = "walk_down"
		else:
			anim_name = "walk_up"
	
	# Añadir sufijo de sprint si está corriendo
	if is_sprinting:
		anim_name += "_sprint"
	
	# Reproducir la animación
	if animation_player.has_animation(anim_name) and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

# Interactuar con un objeto
func interact_with_object(object) -> void:
	is_interacting = true
	
	# Verificar el tipo de objeto
	if object.has_method("interact"):
		object.interact(self)
	
	is_interacting = false

# Recibir daño
func take_damage(amount: int, damage_type: String = "physical") -> void:
	# Verificar invulnerabilidad
	if is_invulnerable:
		return
	
	# Calcular daño real según resistencias
	var actual_damage = calculate_damage_reduction(amount, damage_type)
	
	# Aplicar daño
	GameManager.modify_player_stat("health", -actual_damage)
	
	# Efectos visuales de daño
	show_damage_effect(actual_damage)
	
	# Período breve de invulnerabilidad
	set_invulnerable(0.5)
	
	# Verificar si el jugador ha muerto
	if GameManager.player_data["health"] <= 0:
		die()

# Calcular reducción de daño basada en atributos y equipo
func calculate_damage_reduction(amount: int, damage_type: String) -> int:
	var reduction = 0
	
	# Reducción basada en atributos
	var resistance = GameManager.player_data["attributes"]["resistance"]
	reduction += resistance * 0.5  # 0.5% de reducción por punto de resistencia
	
	# Reducción basada en equipo (implementación básica)
	if GameManager.player_data["equipment"]["armor"] != null:
		# En una implementación real, esto verificaría las propiedades de la armadura
		reduction += 10  # Valor de ejemplo
	
	# Ajustar según tipo de daño
	match damage_type:
		"physical":
			# La reducción ya está calculada para daño físico
			pass
		"energy":
			# Menos reducción contra daño de energía
			reduction *= 0.7
		"toxic":
			# Verificar si tiene la habilidad de adaptación tóxica
			if GameManager.has_skill("mutation", "toxic_adaptation"):
				reduction *= 1.5
		"psychic":
			# La resistencia psíquica depende más de la voluntad
			reduction = GameManager.player_data["attributes"]["will"] * 0.8
	
	# Calcular daño final (mínimo 1)
	var reduced_amount = amount * (1.0 - (reduction / 100.0))
	return max(1, int(reduced_amount))

# Mostrar efecto visual de daño
func show_damage_effect(amount: int) -> void:
	# Parpadeo rojo
	sprite.modulate = Color(1.5, 0.3, 0.3, 1.0)
	
	# Crear etiqueta de daño flotante
	var damage_label = Label.new()
	damage_label.text = str(amount)
	damage_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	effects_container.add_child(damage_label)
	
	# Posicionar la etiqueta
	damage_label.position = Vector2(randf_range(-20, 20), -30)
	
	# Animar la etiqueta
	var tween = create_tween()
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 40, 0.8)
	tween.parallel().tween_property(damage_label, "modulate:a", 0, 0.8)
	tween.tween_callback(Callable(damage_label, "queue_free"))
	
	# Restaurar color normal después de un breve tiempo
	var color_tween = create_tween()
	color_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.3)

# Establecer invulnerabilidad temporal
func set_invulnerable(duration: float) -> void:
	is_invulnerable = true
	invulnerability_timer = duration
	
	# Efecto visual de invulnerabilidad (parpadeo)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)

# Muerte del jugador
func die() -> void:
	# Detener movimiento y animaciones
	velocity = Vector2.ZERO
	animation_player.stop()
	
	# Reproducir animación de muerte si existe
	if animation_player.has_animation("death"):
		animation_player.play("death")
	
	# Desactivar colisiones e interacciones
	set_physics_process(false)
	set_process_input(false)
	interaction_area.monitoring = false
	
	# Cambiar al estado de game over
	await get_tree().create_timer(2.0).timeout
	GameManager.change_game_state(GameManager.GameState.GAME_OVER)

# Ganar experiencia
func gain_experience(amount: int) -> void:
	# Actualizar experiencia
	GameManager.player_data["experience"] += amount
	
	# Verificar si sube de nivel
	var exp_for_next_level = calculate_exp_for_level(GameManager.player_data["level"] + 1)
	
	if GameManager.player_data["experience"] >= exp_for_next_level:
		level_up()

# Subir de nivel
func level_up() -> void:
	# Incrementar nivel
	GameManager.player_data["level"] += 1
	
	# Aumentar estadísticas base
	GameManager.player_data["max_health"] += 10
	GameManager.player_data["health"] = GameManager.player_data["max_health"]
	GameManager.player_data["max_energy"] += 5
	GameManager.player_data["energy"] = GameManager.player_data["max_energy"]
	
	# Otorgar puntos de atributo
	# En una implementación real, esto se manejaría en una pantalla de nivel
	
	# Emitir señal
	emit_signal("level_up", GameManager.player_data["level"])

# Calcular experiencia necesaria para un nivel
func calculate_exp_for_level(level: int) -> int:
	# Fórmula simple: cada nivel requiere un 20% más que el anterior
	# Nivel 1: 100 XP
	# Nivel 2: 120 XP
	# Nivel 3: 144 XP
	# etc.
	return int(100 * pow(1.2, level - 1))

# Actualizar estadísticas desde el GameManager
func _update_stats_from_game_manager() -> void:
	# Emitir señales para actualizar la UI
	emit_signal("health_changed", GameManager.player_data["health"], GameManager.player_data["max_health"])
	emit_signal("energy_changed", GameManager.player_data["energy"], GameManager.player_data["max_energy"])
	emit_signal("mutant_charge_changed", GameManager.player_data["mutant_charge"], GameManager.player_data["max_mutant_charge"])

# Manejador de cambio de estadísticas del jugador
func _on_player_stats_changed(stat_name: String, new_value: int) -> void:
	match stat_name:
		"health":
			emit_signal("health_changed", new_value, GameManager.player_data["max_health"])
		"max_health":
			emit_signal("health_changed", GameManager.player_data["health"], new_value)
		"energy":
			emit_signal("energy_changed", new_value, GameManager.player_data["max_energy"])
		"max_energy":
			emit_signal("energy_changed", GameManager.player_data["energy"], new_value)
		"mutant_charge":
			emit_signal("mutant_charge_changed", new_value, GameManager.player_data["max_mutant_charge"])
		"max_mutant_charge":
			emit_signal("mutant_charge_changed", GameManager.player_data["mutant_charge"], new_value)

# Manejador de entrada en área de interacción
func _on_interaction_area_entered(area: Area2D) -> void:
	# Verificar si el área es interactuable
	if area.get_parent().has_method("interact"):
		current_interaction_object = area.get_parent()
		emit_signal("interaction_available", current_interaction_object)

# Manejador de salida de área de interacción
func _on_interaction_area_exited(area: Area2D) -> void:
	if current_interaction_object and area.get_parent() == current_interaction_object:
		current_interaction_object = null
		emit_signal("interaction_unavailable")

# Usar un objeto del inventario
func use_item(item_id: String) -> bool:
	# Buscar el objeto en el inventario
	var item_found = false
	var item_index = -1
	
	for i in range(GameManager.player_data["inventory"].size()):
		var item = GameManager.player_data["inventory"][i]
		if item["id"] == item_id and item["quantity"] > 0:
			item_found = true
			item_index = i
			break
	
	if not item_found:
		return false
	
	# Aplicar efectos según el tipo de objeto
	# En una implementación real, esto se manejaría con un sistema de datos de objetos
	match item_id:
		"basic_medkit":
			GameManager.modify_player_stat("health", 30)
		"military_stimpack":
			GameManager.modify_player_stat("health", 20)
			GameManager.modify_player_stat("energy", 40)
		"water_purifier":
			# Efecto específico de misión o exploración
			GameManager.set_story_flag("has_clean_water", true)
		"raak_toxin_vial":
			# Podría ser un objeto de misión o tener efectos especiales
			pass
		_:
			# Objeto desconocido
			return false
	
	# Reducir la cantidad del objeto
	GameManager.player_data["inventory"][item_index]["quantity"] -= 1
	
	# Eliminar el objeto si la cantidad llega a 0
	if GameManager.player_data["inventory"][item_index]["quantity"] <= 0:
		GameManager.player_data["inventory"].remove_at(item_index)
	
	return true

# Equipar un objeto
func equip_item(item_id: String, slot: String) -> bool:
	# Verificar si el slot es válido
	if not GameManager.player_data["equipment"].has(slot):
		return false
	
	# Buscar el objeto en el inventario
	var item_found = false
	var item_index = -1
	
	for i in range(GameManager.player_data["inventory"].size()):
		var item = GameManager.player_data["inventory"][i]
		if item["id"] == item_id and item["quantity"] > 0:
			item_found = true
			item_index = i
			break
	
	if not item_found:
		return false
	
	# Desequipar el objeto actual si existe
	if GameManager.player_data["equipment"][slot] != null:
		# Devolver el objeto actual al inventario
		GameManager.add_to_inventory(GameManager.player_data["equipment"][slot], 1)
	
	# Equipar el nuevo objeto
	GameManager.player_data["equipment"][slot] = item_id
	
	# Reducir la cantidad del objeto en el inventario
	GameManager.player_data["inventory"][item_index]["quantity"] -= 1
	
	# Eliminar el objeto si la cantidad llega a 0
	if GameManager.player_data["inventory"][item_index]["quantity"] <= 0:
		GameManager.player_data["inventory"].remove_at(item_index)
	
	return true

# Desequipar un objeto
func unequip_item(slot: String) -> bool:
	# Verificar si el slot es válido y tiene un objeto equipado
	if not GameManager.player_data["equipment"].has(slot) or GameManager.player_data["equipment"][slot] == null:
		return false
	
	# Devolver el objeto al inventario
	GameManager.add_to_inventory(GameManager.player_data["equipment"][slot], 1)
	
	# Vaciar el slot
	GameManager.player_data["equipment"][slot] = null
	
	return true