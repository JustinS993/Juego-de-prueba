extends Control

# Señales
signal skill_selected(skill_id)
signal skill_tree_changed(tree_id)

# Referencias a nodos
@onready var skill_tree_tabs = $SkillTreeTabs
@onready var skill_points_label = $HeaderContainer/SkillPointsLabel
@onready var skill_description_panel = $DescriptionPanel
@onready var skill_name_label = $DescriptionPanel/VBoxContainer/SkillNameLabel
@onready var skill_type_label = $DescriptionPanel/VBoxContainer/SkillTypeLabel
@onready var skill_level_label = $DescriptionPanel/VBoxContainer/SkillLevelLabel
@onready var skill_description_label = $DescriptionPanel/VBoxContainer/DescriptionLabel
@onready var skill_effects_container = $DescriptionPanel/VBoxContainer/EffectsContainer
@onready var skill_requirements_label = $DescriptionPanel/VBoxContainer/RequirementsLabel
@onready var unlock_button = $DescriptionPanel/VBoxContainer/ButtonsContainer/UnlockButton
@onready var upgrade_button = $DescriptionPanel/VBoxContainer/ButtonsContainer/UpgradeButton

# Variables
var skill_manager: Node
var current_tree_id: int = 0
var current_skill_id: String = ""
var skill_buttons: Dictionary = {}

# Constantes
const SKILL_BUTTON_SCENE = preload("res://scenes/ui/SkillButton.tscn")
const SKILL_CONNECTION_SCENE = preload("res://scenes/ui/SkillConnection.tscn")
const TREE_COLORS = {
	0: Color(0.8, 0.3, 0.3), # Combate (rojo)
	1: Color(0.3, 0.7, 0.9), # Tecnología (azul)
	2: Color(0.5, 0.9, 0.3)  # Mutación (verde)
}

# Función de inicialización
func _ready() -> void:
	# Obtener referencia al gestor de habilidades
	skill_manager = get_node("/root/SkillManager")
	
	# Conectar señales
	skill_manager.connect("skill_unlocked", Callable(self, "_on_skill_unlocked"))
	skill_manager.connect("skill_upgraded", Callable(self, "_on_skill_upgraded"))
	skill_manager.connect("skill_points_changed", Callable(self, "_on_skill_points_changed"))
	skill_manager.connect("skill_tree_initialized", Callable(self, "_on_skill_tree_initialized"))
	
	# Conectar señales de la interfaz
	skill_tree_tabs.connect("tab_changed", Callable(self, "_on_tab_changed"))
	unlock_button.connect("pressed", Callable(self, "_on_unlock_button_pressed"))
	upgrade_button.connect("pressed", Callable(self, "_on_upgrade_button_pressed"))
	
	# Inicializar interfaz
	_initialize_ui()

# Inicializar interfaz
func _initialize_ui() -> void:
	# Actualizar etiqueta de puntos de habilidad
	_update_skill_points_label()
	
	# Inicializar pestañas de árboles de habilidades
	_initialize_skill_tree_tabs()
	
	# Ocultar panel de descripción inicialmente
	skill_description_panel.visible = false

# Inicializar pestañas de árboles de habilidades
func _initialize_skill_tree_tabs() -> void:
	# Limpiar pestañas existentes
	for tab in skill_tree_tabs.get_children():
		tab.queue_free()
	
	# Crear pestañas para cada árbol de habilidades
	for tree_id in skill_manager.skill_trees:
		var tree_data = skill_manager.skill_trees[tree_id]
		
		# Crear contenedor para el árbol
		var tree_container = Control.new()
		tree_container.name = tree_data["name"]
		tree_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		# Añadir contenedor a las pestañas
		skill_tree_tabs.add_child(tree_container)
		
		# Crear conexiones entre habilidades
		_create_skill_connections(tree_container, tree_id)
		
		# Crear botones de habilidades
		_create_skill_buttons(tree_container, tree_id)

# Crear conexiones entre habilidades
func _create_skill_connections(container: Control, tree_id: int) -> void:
	# Obtener color del árbol
	var tree_color = TREE_COLORS[tree_id]
	
	# Recorrer habilidades del árbol
	for skill_id in skill_manager.skill_trees[tree_id]["skills"]:
		var skill_data = skill_manager.skill_trees[tree_id]["skills"][skill_id]
		
		# Verificar si tiene requisitos
		if skill_data.has("requirements"):
			for req_skill_id in skill_data["requirements"]:
				# Ignorar requisitos de nivel de jugador
				if req_skill_id == "player_level":
					continue
				
				# Verificar si el requisito es una habilidad del mismo árbol
				if skill_manager.skill_trees[tree_id]["skills"].has(req_skill_id):
					var req_skill_data = skill_manager.skill_trees[tree_id]["skills"][req_skill_id]
					
					# Crear conexión visual
					var connection = SKILL_CONNECTION_SCENE.instantiate()
					container.add_child(connection)
					
					# Configurar conexión
					connection.set_start_position(req_skill_data["position"])
					connection.set_end_position(skill_data["position"])
					connection.set_color(tree_color)
					connection.set_skill_ids(req_skill_id, skill_id)
					
					# Actualizar estado de la conexión
					var is_active = skill_manager.is_skill_unlocked(req_skill_id) and skill_manager.is_skill_unlocked(skill_id)
					connection.set_active(is_active)

# Crear botones de habilidades
func _create_skill_buttons(container: Control, tree_id: int) -> void:
	# Recorrer habilidades del árbol
	for skill_id in skill_manager.skill_trees[tree_id]["skills"]:
		var skill_data = skill_manager.skill_trees[tree_id]["skills"][skill_id]
		
		# Crear botón de habilidad
		var skill_button = SKILL_BUTTON_SCENE.instantiate()
		container.add_child(skill_button)
		
		# Configurar botón
		skill_button.set_position(skill_data["position"] - skill_button.get_size() / 2)
		skill_button.set_skill_id(skill_id)
		skill_button.set_skill_name(skill_data["name"])
		skill_button.set_skill_icon(skill_data["icon"])
		skill_button.set_skill_type(skill_data["type"])
		skill_button.set_tree_color(TREE_COLORS[tree_id])
		
		# Actualizar estado del botón
		var is_unlocked = skill_manager.is_skill_unlocked(skill_id)
		var level = skill_manager.get_skill_level(skill_id)
		var max_level = skill_data["max_level"]
		skill_button.update_state(is_unlocked, level, max_level)
		
		# Conectar señal de selección
		skill_button.connect("pressed", Callable(self, "_on_skill_button_pressed").bind(skill_id))
		
		# Guardar referencia al botón
		skill_buttons[skill_id] = skill_button

# Actualizar etiqueta de puntos de habilidad
func _update_skill_points_label() -> void:
	skill_points_label.text = "Puntos de Habilidad: %d" % skill_manager.available_skill_points

# Mostrar información de una habilidad
func _show_skill_info(skill_id: String) -> void:
	# Guardar habilidad actual
	current_skill_id = skill_id
	
	# Obtener datos de la habilidad
	var skill_data = skill_manager.get_skill_data(skill_id)
	
	# Verificar si se encontraron datos
	if skill_data.empty():
		return
	
	# Actualizar panel de descripción
	skill_name_label.text = skill_data["name"]
	
	# Establecer tipo de habilidad
	var type_text = ""
	match skill_data["type"]:
		skill_manager.SkillType.PASSIVE:
			type_text = "Pasiva"
		skill_manager.SkillType.ACTIVE:
			type_text = "Activa"
		skill_manager.SkillType.ULTIMATE:
			type_text = "Definitiva"
	skill_type_label.text = "Tipo: %s" % type_text
	
	# Establecer nivel actual y máximo
	var current_level = skill_manager.get_skill_level(skill_id)
	var max_level = skill_data["max_level"]
	skill_level_label.text = "Nivel: %d/%d" % [current_level, max_level]
	
	# Establecer descripción
	skill_description_label.text = skill_data["description"]
	
	# Limpiar contenedor de efectos
	for child in skill_effects_container.get_children():
		child.queue_free()
	
	# Mostrar efectos actuales o del siguiente nivel
	var effects_level = current_level
	if effects_level == 0:
		effects_level = 1
	
	# Verificar si tiene efectos para ese nivel
	if skill_data.has("effects") and skill_data["effects"].has(effects_level):
		# Crear etiqueta de título
		var title_label = Label.new()
		title_label.text = "Efectos:"
		skill_effects_container.add_child(title_label)
		
		# Mostrar cada efecto
		for effect in skill_data["effects"][effects_level]:
			var effect_label = Label.new()
			effect_label.text = "• %s: %s%s" % [effect["stat"].capitalize(), "+" if effect["value"] > 0 else "", effect["value"]]
			skill_effects_container.add_child(effect_label)
	
	# Mostrar coste de energía si es una habilidad activa
	if skill_data["type"] == skill_manager.SkillType.ACTIVE or skill_data["type"] == skill_manager.SkillType.ULTIMATE:
		if skill_data.has("energy_cost") and skill_data["energy_cost"].has(effects_level):
			var energy_label = Label.new()
			energy_label.text = "Coste de Energía: %d" % skill_data["energy_cost"][effects_level]
			skill_effects_container.add_child(energy_label)
		
		if skill_data.has("cooldown") and skill_data["cooldown"].has(effects_level):
			var cooldown_label = Label.new()
			cooldown_label.text = "Enfriamiento: %d turnos" % skill_data["cooldown"][effects_level]
			skill_effects_container.add_child(cooldown_label)
		
		if skill_data.has("duration") and skill_data["duration"].has(effects_level):
			var duration_label = Label.new()
			duration_label.text = "Duración: %d turnos" % skill_data["duration"][effects_level]
			skill_effects_container.add_child(duration_label)
	
	# Mostrar coste de carga mutante si es una habilidad definitiva de mutación
	if skill_data["type"] == skill_manager.SkillType.ULTIMATE and skill_data["tree"] == skill_manager.SkillTree.MUTATION:
		if skill_data.has("mutant_charge_cost") and skill_data["mutant_charge_cost"].has(effects_level):
			var charge_label = Label.new()
			charge_label.text = "Coste de Carga Mutante: %d" % skill_data["mutant_charge_cost"][effects_level]
			skill_effects_container.add_child(charge_label)
	
	# Mostrar requisitos
	var req_text = "Requisitos: "
	var has_requirements = false
	
	if skill_data.has("requirements"):
		for req_skill_id in skill_data["requirements"]:
			if req_skill_id == "player_level":
				req_text += "Nivel de Jugador %d, " % skill_data["requirements"][req_skill_id]
				has_requirements = true
			else:
				var req_skill_data = skill_manager.get_skill_data(req_skill_id)
				if not req_skill_data.empty():
					req_text += "%s (Nivel %d), " % [req_skill_data["name"], skill_data["requirements"][req_skill_id]]
					has_requirements = true
	
	if has_requirements:
		# Eliminar última coma y espacio
		req_text = req_text.substr(0, req_text.length() - 2)
	else:
		req_text += "Ninguno"
	
	skill_requirements_label.text = req_text
	
	# Actualizar botones
	_update_skill_buttons(skill_id)
	
	# Mostrar panel
	skill_description_panel.visible = true

# Actualizar botones de habilidad
func _update_skill_buttons(skill_id: String) -> void:
	# Obtener estado actual de la habilidad
	var is_unlocked = skill_manager.is_skill_unlocked(skill_id)
	var current_level = skill_manager.get_skill_level(skill_id)
	var skill_data = skill_manager.get_skill_data(skill_id)
	var max_level = skill_data["max_level"]
	var can_unlock = not is_unlocked and skill_manager.check_skill_requirements(skill_id) and skill_manager.available_skill_points > 0
	var can_upgrade = is_unlocked and current_level < max_level and skill_manager.available_skill_points > 0
	
	# Actualizar botón de desbloqueo
	unlock_button.visible = not is_unlocked
	unlock_button.disabled = not can_unlock
	
	# Actualizar botón de mejora
	upgrade_button.visible = is_unlocked and current_level < max_level
	upgrade_button.disabled = not can_upgrade

# Manejadores de señales
func _on_skill_tree_initialized() -> void:
	# Reinicializar interfaz
	_initialize_ui()

# Cuando cambian los puntos de habilidad
func _on_skill_points_changed(current_points: int) -> void:
	# Actualizar etiqueta
	_update_skill_points_label()
	
	# Actualizar botones si hay una habilidad seleccionada
	if not current_skill_id.empty():
		_update_skill_buttons(current_skill_id)

# Cuando se desbloquea una habilidad
func _on_skill_unlocked(skill_id: String) -> void:
	# Actualizar botón de habilidad
	if skill_buttons.has(skill_id):
		var skill_data = skill_manager.get_skill_data(skill_id)
		var level = skill_manager.get_skill_level(skill_id)
		var max_level = skill_data["max_level"]
		skill_buttons[skill_id].update_state(true, level, max_level)
		
		# Actualizar conexiones
		_update_skill_connections(skill_id)
	
	# Actualizar panel de descripción si es la habilidad actual
	if skill_id == current_skill_id:
		_show_skill_info(skill_id)

# Cuando se mejora una habilidad
func _on_skill_upgraded(skill_id: String, new_level: int) -> void:
	# Actualizar botón de habilidad
	if skill_buttons.has(skill_id):
		var skill_data = skill_manager.get_skill_data(skill_id)
		var max_level = skill_data["max_level"]
		skill_buttons[skill_id].update_state(true, new_level, max_level)
	
	# Actualizar panel de descripción si es la habilidad actual
	if skill_id == current_skill_id:
		_show_skill_info(skill_id)

# Actualizar conexiones de una habilidad
func _update_skill_connections(skill_id: String) -> void:
	# Obtener contenedor actual
	var container = skill_tree_tabs.get_current_tab_control()
	
	# Recorrer conexiones
	for child in container.get_children():
		if child.has_method("get_skill_ids"):
			var ids = child.get_skill_ids()
			
			# Verificar si la conexión involucra la habilidad
			if ids[0] == skill_id or ids[1] == skill_id:
				# Actualizar estado de la conexión
				var is_active = skill_manager.is_skill_unlocked(ids[0]) and skill_manager.is_skill_unlocked(ids[1])
				child.set_active(is_active)

# Cuando se cambia de pestaña
func _on_tab_changed(tab_idx: int) -> void:
	# Actualizar árbol actual
	current_tree_id = tab_idx
	
	# Emitir señal
	emit_signal("skill_tree_changed", current_tree_id)
	
	# Ocultar panel de descripción
	skill_description_panel.visible = false
	current_skill_id = ""

# Cuando se presiona un botón de habilidad
func _on_skill_button_pressed(skill_id: String) -> void:
	# Mostrar información de la habilidad
	_show_skill_info(skill_id)
	
	# Emitir señal
	emit_signal("skill_selected", skill_id)

# Cuando se presiona el botón de desbloqueo
func _on_unlock_button_pressed() -> void:
	# Verificar si hay una habilidad seleccionada
	if current_skill_id.empty():
		return
	
	# Intentar desbloquear la habilidad
	skill_manager.unlock_skill(current_skill_id)

# Cuando se presiona el botón de mejora
func _on_upgrade_button_pressed() -> void:
	# Verificar si hay una habilidad seleccionada
	if current_skill_id.empty():
		return
	
	# Intentar mejorar la habilidad
	skill_manager.upgrade_skill(current_skill_id)