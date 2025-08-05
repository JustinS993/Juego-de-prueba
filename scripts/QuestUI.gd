extends Control

# Señales
signal quest_selected(quest_id)
signal objective_tracked(quest_id, objective_id)

# Referencias a nodos de la UI
onready var quest_list = $MainPanel/QuestList
onready var quest_details = $MainPanel/QuestDetails
onready var quest_title = $MainPanel/QuestDetails/QuestTitle
onready var quest_description = $MainPanel/QuestDetails/QuestDescription
onready var quest_location = $MainPanel/QuestDetails/QuestLocation
onready var quest_type = $MainPanel/QuestDetails/QuestType
onready var quest_status = $MainPanel/QuestDetails/QuestStatus
onready var quest_objectives = $MainPanel/QuestDetails/Objectives/ObjectivesList
onready var quest_rewards = $MainPanel/QuestDetails/Rewards/RewardsList
onready var close_button = $MainPanel/CloseButton
onready var track_button = $MainPanel/QuestDetails/TrackButton
onready var sort_dropdown = $MainPanel/SortOptions

# Variables
var current_quest_id = ""
var tracked_quest_id = ""
var tracked_objective_id = ""

# Constantes para tipos de misiones y estados
const QUEST_TYPE_COLORS = {
	QuestManager.QuestType.MAIN: Color(0.9, 0.7, 0.2),       # Dorado
	QuestManager.QuestType.SIDE: Color(0.4, 0.6, 0.9),       # Azul
	QuestManager.QuestType.FACTION: Color(0.7, 0.3, 0.7),    # Púrpura
	QuestManager.QuestType.EXPLORATION: Color(0.3, 0.8, 0.4), # Verde
	QuestManager.QuestType.BOSS_HUNT: Color(0.9, 0.3, 0.3)    # Rojo
}

const QUEST_STATUS_COLORS = {
	QuestManager.QuestStatus.INACTIVE: Color(0.5, 0.5, 0.5),  # Gris
	QuestManager.QuestStatus.ACTIVE: Color(1.0, 1.0, 1.0),    # Blanco
	QuestManager.QuestStatus.COMPLETED: Color(0.3, 0.8, 0.3), # Verde
	QuestManager.QuestStatus.FAILED: Color(0.8, 0.3, 0.3)     # Rojo
}

const QUEST_TYPE_NAMES = {
	QuestManager.QuestType.MAIN: "Principal",
	QuestManager.QuestType.SIDE: "Secundaria",
	QuestManager.QuestType.FACTION: "Facción",
	QuestManager.QuestType.EXPLORATION: "Exploración",
	QuestManager.QuestType.BOSS_HUNT: "Caza"
}

const QUEST_STATUS_NAMES = {
	QuestManager.QuestStatus.INACTIVE: "Inactiva",
	QuestManager.QuestStatus.ACTIVE: "Activa",
	QuestManager.QuestStatus.COMPLETED: "Completada",
	QuestManager.QuestStatus.FAILED: "Fallida"
}

const QUEST_TYPE_ICONS = {
	QuestManager.QuestType.MAIN: preload("res://assets/icons/quest_main.png"),
	QuestManager.QuestType.SIDE: preload("res://assets/icons/quest_side.png"),
	QuestManager.QuestType.FACTION: preload("res://assets/icons/quest_faction.png"),
	QuestManager.QuestType.EXPLORATION: preload("res://assets/icons/quest_exploration.png"),
	QuestManager.QuestType.BOSS_HUNT: preload("res://assets/icons/quest_boss.png")
}

# Inicialización
func _ready():
	# Conectar señales del QuestManager
	QuestManager.connect("quest_added", self, "_on_quest_added")
	QuestManager.connect("quest_updated", self, "_on_quest_updated")
	QuestManager.connect("quest_completed", self, "_on_quest_completed")
	QuestManager.connect("quest_failed", self, "_on_quest_failed")
	QuestManager.connect("objective_completed", self, "_on_objective_completed")
	
	# Conectar señales de la UI
	close_button.connect("pressed", self, "_on_close_button_pressed")
	track_button.connect("pressed", self, "_on_track_button_pressed")
	sort_dropdown.connect("item_selected", self, "_on_sort_option_selected")
	
	# Inicializar la UI
	refresh_quest_list()
	hide_quest_details()
	
	# Ocultar el panel al inicio
	visible = false

# Refrescar la lista de misiones
func refresh_quest_list():
	# Limpiar la lista actual
	quest_list.clear()
	
	# Añadir misiones activas
	var active_quests = QuestManager.get_active_quests()
	for quest in active_quests:
		add_quest_to_list(quest, QuestManager.QuestStatus.ACTIVE)
	
	# Añadir misiones completadas
	var completed_quests = QuestManager.get_completed_quests()
	for quest in completed_quests:
		add_quest_to_list(quest, QuestManager.QuestStatus.COMPLETED)
	
	# Añadir misiones fallidas
	var failed_quests = QuestManager.get_failed_quests()
	for quest in failed_quests:
		add_quest_to_list(quest, QuestManager.QuestStatus.FAILED)

# Añadir una misión a la lista
func add_quest_to_list(quest, status):
	# Crear el ítem para la lista
	var item = quest_list.create_item()
	item.set_text(0, quest["title"])
	item.set_metadata(0, quest["id"])
	
	# Establecer el color según el tipo de misión
	var quest_type_color = QUEST_TYPE_COLORS[quest["type"]]
	item.set_custom_color(0, quest_type_color)
	
	# Establecer el icono según el tipo de misión
	if QUEST_TYPE_ICONS.has(quest["type"]):
		item.set_icon(0, QUEST_TYPE_ICONS[quest["type"]])
	
	# Añadir indicador de seguimiento si esta misión está siendo seguida
	if quest["id"] == tracked_quest_id:
		item.set_suffix(0, " (Seguida)")
	
	# Añadir indicador de estado
	var status_text = " [" + QUEST_STATUS_NAMES[status] + "]"
	item.set_suffix(0, status_text)
	
	# Si está completada o fallida, usar un color más apagado
	if status == QuestManager.QuestStatus.COMPLETED or status == QuestManager.QuestStatus.FAILED:
		item.set_custom_color(0, QUEST_STATUS_COLORS[status])

# Mostrar detalles de una misión
func show_quest_details(quest_id):
	# Guardar la misión actual
	current_quest_id = quest_id
	
	# Obtener información de la misión
	var quest = QuestManager.get_quest_info(quest_id)
	if quest.empty():
		return
	
	# Actualizar la UI con los detalles de la misión
	quest_title.text = quest["title"]
	quest_description.text = quest["description"]
	quest_location.text = "Ubicación: " + quest["location"]
	quest_type.text = "Tipo: " + QUEST_TYPE_NAMES[quest["type"]]
	quest_type.modulate = QUEST_TYPE_COLORS[quest["type"]]
	
	# Mostrar estado
	var status = QuestManager.QuestStatus.INACTIVE
	if QuestManager.is_quest_active(quest_id):
		status = QuestManager.QuestStatus.ACTIVE
	elif QuestManager.is_quest_completed(quest_id):
		status = QuestManager.QuestStatus.COMPLETED
	elif QuestManager.is_quest_failed(quest_id):
		status = QuestManager.QuestStatus.FAILED
	
	quest_status.text = "Estado: " + QUEST_STATUS_NAMES[status]
	quest_status.modulate = QUEST_STATUS_COLORS[status]
	
	# Mostrar objetivos
	quest_objectives.clear()
	for objective in quest["objectives"]:
		var objective_item = quest_objectives.create_item()
		var progress_text = ""
		
		# Si la misión está activa, mostrar progreso
		if QuestManager.is_quest_active(quest_id):
			var progress = QuestManager.get_objective_progress(quest_id, objective["id"])
			if not progress.empty():
				progress_text = " (" + str(progress["current"]) + "/" + str(progress["target"]) + ")"
				
				# Marcar como completado si corresponde
				if progress["completed"]:
					objective_item.set_custom_color(0, QUEST_STATUS_COLORS[QuestManager.QuestStatus.COMPLETED])
					progress_text += " ✓"
			elif objective["completed"]:
				objective_item.set_custom_color(0, QUEST_STATUS_COLORS[QuestManager.QuestStatus.COMPLETED])
				progress_text += " ✓"
		
		objective_item.set_text(0, objective["description"] + progress_text)
		objective_item.set_metadata(0, objective["id"])
		
		# Marcar el objetivo seguido
		if quest_id == tracked_quest_id and objective["id"] == tracked_objective_id:
			objective_item.set_suffix(0, " (Seguido)")
	
	# Mostrar recompensas
	quest_rewards.clear()
	
	# Experiencia
	if quest["rewards"].has("experience") and quest["rewards"]["experience"] > 0:
		var xp_item = quest_rewards.create_item()
		xp_item.set_text(0, "Experiencia: " + str(quest["rewards"]["experience"]) + " XP")
	
	# Objetos
	if quest["rewards"].has("items") and not quest["rewards"]["items"].empty():
		for item in quest["rewards"]["items"]:
			var item_name = GameManager.get_item_name(item["id"])
			var reward_item = quest_rewards.create_item()
			reward_item.set_text(0, item_name + " x" + str(item["quantity"]))
	
	# Habilidades
	if quest["rewards"].has("skills") and not quest["rewards"]["skills"].empty():
		for skill in quest["rewards"]["skills"]:
			var skill_name = GameManager.get_skill_name(skill["branch"], skill["id"])
			var reward_skill = quest_rewards.create_item()
			reward_skill.set_text(0, "Habilidad: " + skill_name)
	
	# Reputación
	if quest["rewards"].has("reputation") and not quest["rewards"]["reputation"].empty():
		for rep in quest["rewards"]["reputation"]:
			var faction_name = FactionManager.get_faction_name(rep["faction"])
			var reward_rep = quest_rewards.create_item()
			var sign = "+" if rep["value"] > 0 else ""
			reward_rep.set_text(0, "Reputación: " + faction_name + " " + sign + str(rep["value"]))
	
	# Mostrar el panel de detalles
	quest_details.visible = true
	
	# Actualizar botón de seguimiento
	update_track_button()

# Ocultar detalles de misión
func hide_quest_details():
	quest_details.visible = false
	current_quest_id = ""

# Actualizar el botón de seguimiento
func update_track_button():
	if current_quest_id == "":
		track_button.visible = false
		return
	
	track_button.visible = QuestManager.is_quest_active(current_quest_id)
	
	if current_quest_id == tracked_quest_id:
		track_button.text = "Dejar de seguir"
	else:
		track_button.text = "Seguir misión"

# Seguir una misión y un objetivo específico
func track_quest(quest_id, objective_id = ""):
	# Si ya estamos siguiendo esta misión y objetivo, dejar de seguirla
	if tracked_quest_id == quest_id and (objective_id == "" or tracked_objective_id == objective_id):
		tracked_quest_id = ""
		tracked_objective_id = ""
		GameManager.set_tracked_quest("", "")
		refresh_quest_list()
		update_track_button()
		return
	
	# Verificar que la misión esté activa
	if not QuestManager.is_quest_active(quest_id):
		return
	
	# Si no se especificó un objetivo, usar el primer objetivo no completado
	if objective_id == "":
		var quest = QuestManager.get_quest_info(quest_id)
		for objective in quest["objectives"]:
			var progress = QuestManager.get_objective_progress(quest_id, objective["id"])
			if not progress["completed"]:
				objective_id = objective["id"]
				break
	
	# Actualizar seguimiento
	tracked_quest_id = quest_id
	tracked_objective_id = objective_id
	
	# Informar al GameManager
	GameManager.set_tracked_quest(quest_id, objective_id)
	
	# Actualizar UI
	refresh_quest_list()
	update_track_button()
	
	# Emitir señal
	emit_signal("objective_tracked", quest_id, objective_id)

# Mostrar el panel de misiones
func show_panel():
	visible = true
	refresh_quest_list()

# Ocultar el panel de misiones
func hide_panel():
	visible = false

# Ordenar misiones
func sort_quests(sort_type):
	# Implementar diferentes tipos de ordenamiento
	match sort_type:
		0: # Por tipo (principal primero)
			# Esta es la implementación por defecto
			pass
		1: # Por estado (activas primero)
			# Implementar ordenamiento por estado
			pass
		2: # Por nivel
			# Implementar ordenamiento por nivel
			pass
		3: # Alfabético
			# Implementar ordenamiento alfabético
			pass
	
	# Refrescar la lista después de ordenar
	refresh_quest_list()

# Manejadores de señales
func _on_quest_added(quest_id):
	refresh_quest_list()

	# Si no hay misión seleccionada, seleccionar esta
	if current_quest_id == "":
		show_quest_details(quest_id)

	# Si no hay misión seguida, seguir esta automáticamente
	if tracked_quest_id == "":
		track_quest(quest_id)

func _on_quest_updated(quest_id, status):
	refresh_quest_list()
	
	# Si esta es la misión actual, actualizar detalles
	if current_quest_id == quest_id:
		show_quest_details(quest_id)

func _on_quest_completed(quest_id):
	refresh_quest_list()
	
	# Si esta es la misión actual, actualizar detalles
	if current_quest_id == quest_id:
		show_quest_details(quest_id)
	
	# Si esta es la misión seguida, dejar de seguirla
	if tracked_quest_id == quest_id:
		tracked_quest_id = ""
		tracked_objective_id = ""
		GameManager.set_tracked_quest("", "")
		update_track_button()

func _on_quest_failed(quest_id):
	refresh_quest_list()
	
	# Si esta es la misión actual, actualizar detalles
	if current_quest_id == quest_id:
		show_quest_details(quest_id)
	
	# Si esta es la misión seguida, dejar de seguirla
	if tracked_quest_id == quest_id:
		tracked_quest_id = ""
		tracked_objective_id = ""
		GameManager.set_tracked_quest("", "")
		update_track_button()

func _on_objective_completed(quest_id, objective_id):
	# Si esta es la misión actual, actualizar detalles
	if current_quest_id == quest_id:
		show_quest_details(quest_id)
	
	# Si este es el objetivo seguido, buscar el siguiente objetivo no completado
	if tracked_quest_id == quest_id and tracked_objective_id == objective_id:
		var quest = QuestManager.get_quest_info(quest_id)
		var found_next = false
		
		for objective in quest["objectives"]:
			var progress = QuestManager.get_objective_progress(quest_id, objective["id"])
			if not progress["completed"]:
				tracked_objective_id = objective["id"]
				GameManager.set_tracked_quest(quest_id, objective["id"])
				found_next = true
				break
		
		# Si no hay más objetivos, dejar de seguir
		if not found_next:
			tracked_quest_id = ""
			tracked_objective_id = ""
			GameManager.set_tracked_quest("", "")
		
		update_track_button()
		refresh_quest_list()

func _on_close_button_pressed():
	hide_panel()

func _on_track_button_pressed():
	track_quest(current_quest_id)

func _on_sort_option_selected(index):
	sort_quests(index)

func _on_quest_list_item_selected():
	# Obtener el ítem seleccionado
	var selected_item = quest_list.get_selected()
	if selected_item:
		var quest_id = selected_item.get_metadata(0)
		show_quest_details(quest_id)
		emit_signal("quest_selected", quest_id)

func _on_objective_item_selected():
	# Obtener el ítem seleccionado
	var selected_item = quest_objectives.get_selected()
	if selected_item and QuestManager.is_quest_active(current_quest_id):
		var objective_id = selected_item.get_metadata(0)
		track_quest(current_quest_id, objective_id)