extends Control

# Referencias a nodos de la UI
onready var quest_title = $VBoxContainer/QuestTitle
onready var objective_text = $VBoxContainer/ObjectiveText
onready var progress_bar = $VBoxContainer/ProgressBar
onready var icon = $VBoxContainer/HBoxContainer/QuestIcon

# Variables
var tracked_quest_id = ""
var tracked_objective_id = ""
var update_timer = 0.0
var update_interval = 1.0 # Actualizar cada segundo

# Constantes
const QUEST_TYPE_COLORS = {
	QuestManager.QuestType.MAIN: Color(0.9, 0.7, 0.2),       # Dorado
	QuestManager.QuestType.SIDE: Color(0.4, 0.6, 0.9),       # Azul
	QuestManager.QuestType.FACTION: Color(0.7, 0.3, 0.7),    # Púrpura
	QuestManager.QuestType.EXPLORATION: Color(0.3, 0.8, 0.4), # Verde
	QuestManager.QuestType.BOSS_HUNT: Color(0.9, 0.3, 0.3)    # Rojo
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
	# Conectar señales
	QuestManager.connect("quest_updated", self, "_on_quest_updated")
	QuestManager.connect("quest_completed", self, "_on_quest_completed")
	QuestManager.connect("quest_failed", self, "_on_quest_failed")
	QuestManager.connect("objective_completed", self, "_on_objective_completed")
	
	# Inicializar UI
	update_tracker()

# Proceso
func _process(delta):
	# Actualizar el tracker periódicamente
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_tracker()

# Actualizar el tracker
func update_tracker():
	# Obtener la misión y objetivo seguidos actualmente
	var quest_data = GameManager.get_tracked_quest()
	tracked_quest_id = quest_data["quest_id"]
	tracked_objective_id = quest_data["objective_id"]
	
	# Si no hay misión seguida, ocultar el tracker
	if tracked_quest_id == "" or not QuestManager.is_quest_active(tracked_quest_id):
		visible = false
		return
	
	# Mostrar el tracker
	visible = true
	
	# Obtener información de la misión
	var quest = QuestManager.get_quest_info(tracked_quest_id)
	if quest.empty():
		visible = false
		return
	
	# Actualizar título de la misión
	quest_title.text = quest["title"]
	
	# Establecer color según el tipo de misión
	quest_title.modulate = QUEST_TYPE_COLORS[quest["type"]]
	
	# Establecer icono según el tipo de misión
	if QUEST_TYPE_ICONS.has(quest["type"]):
		icon.texture = QUEST_TYPE_ICONS[quest["type"]]
	
	# Buscar el objetivo seguido
	var objective_found = false
	for objective in quest["objectives"]:
		if objective["id"] == tracked_objective_id:
			objective_found = true
			
			# Actualizar texto del objetivo
			objective_text.text = objective["description"]
			
			# Actualizar barra de progreso
			var progress = QuestManager.get_objective_progress(tracked_quest_id, tracked_objective_id)
			if not progress.empty():
				progress_bar.max_value = progress["target"]
				progress_bar.value = progress["current"]
				progress_bar.visible = true
			else:
				progress_bar.visible = false
			
			break
	
	# Si no se encontró el objetivo, usar el primer objetivo no completado
	if not objective_found:
		for objective in quest["objectives"]:
			var progress = QuestManager.get_objective_progress(tracked_quest_id, objective["id"])
			if not progress["completed"]:
				tracked_objective_id = objective["id"]
				objective_text.text = objective["description"]
				
				# Actualizar barra de progreso
				progress_bar.max_value = progress["target"]
				progress_bar.value = progress["current"]
				progress_bar.visible = true
				
				# Actualizar en GameManager
				GameManager.set_tracked_quest(tracked_quest_id, tracked_objective_id)
				
				objective_found = true
				break
	
	# Si no hay objetivos no completados, ocultar el tracker
	if not objective_found:
		visible = false
		GameManager.set_tracked_quest("", "")

# Manejadores de señales
func _on_quest_updated(quest_id, status):
	if quest_id == tracked_quest_id:
		update_tracker()

func _on_quest_completed(quest_id):
	if quest_id == tracked_quest_id:
		# Dejar de seguir esta misión
		tracked_quest_id = ""
		tracked_objective_id = ""
		GameManager.set_tracked_quest("", "")
		update_tracker()

func _on_quest_failed(quest_id):
	if quest_id == tracked_quest_id:
		# Dejar de seguir esta misión
		tracked_quest_id = ""
		tracked_objective_id = ""
		GameManager.set_tracked_quest("", "")
		update_tracker()

func _on_objective_completed(quest_id, objective_id):
	if quest_id == tracked_quest_id and objective_id == tracked_objective_id:
		# Buscar el siguiente objetivo no completado
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
		
		update_tracker()