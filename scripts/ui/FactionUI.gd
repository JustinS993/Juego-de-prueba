extends Control

# FactionUI.gd - Interfaz de usuario para el sistema de facciones
# Muestra información sobre las facciones, reputación y estado de relaciones

# Referencias a nodos
onready var faction_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/FactionList
onready var faction_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/NameLabel
onready var faction_description_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/DescriptionLabel
onready var faction_status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/StatusContainer/StatusLabel
onready var reputation_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/ReputationContainer/ReputationBar
onready var reputation_value_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/ReputationContainer/ValueLabel
onready var faction_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/IconContainer/FactionIcon
onready var leader_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/LeaderContainer/LeaderLabel
onready var headquarters_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/HeadquartersContainer/HeadquartersLabel
onready var quests_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/QuestsContainer/QuestsList
onready var details_panel: PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/DetailsPanel

# Referencias a otros sistemas
var faction_manager: Node
var quest_manager: Node

# Variables
var selected_faction: String = ""
var faction_icons: Dictionary = {}

# Constantes
const MAX_REPUTATION: int = 100
const MIN_REPUTATION: int = -100

# Colores para los diferentes niveles de reputación
const COLOR_HOSTILE: Color = Color(0.8, 0.2, 0.2, 1.0)  # Rojo
const COLOR_SUSPICIOUS: Color = Color(0.8, 0.4, 0.0, 1.0)  # Naranja
const COLOR_NEUTRAL: Color = Color(0.7, 0.7, 0.7, 1.0)  # Gris
const COLOR_FRIENDLY: Color = Color(0.2, 0.7, 0.2, 1.0)  # Verde
const COLOR_ALLIED: Color = Color(0.2, 0.5, 0.9, 1.0)  # Azul

func _ready() -> void:
	# Obtener referencias a los sistemas necesarios
	faction_manager = get_node("/root/FactionManager")
	quest_manager = get_node("/root/QuestManager")
	
	# Conectar señales
	faction_list.connect("item_selected", self, "_on_faction_selected")
	faction_manager.connect("reputation_changed", self, "_on_reputation_changed")
	faction_manager.connect("faction_status_changed", self, "_on_faction_status_changed")
	faction_manager.connect("faction_discovered", self, "_on_faction_discovered")
	
	# Cargar íconos de facciones
	load_faction_icons()
	
	# Inicializar la lista de facciones
	populate_faction_list()
	
	# Ocultar panel de detalles hasta que se seleccione una facción
	details_panel.visible = false

# Cargar íconos de facciones
func load_faction_icons() -> void:
	var faction_ids = faction_manager.factions.keys()
	
	for faction_id in faction_ids:
		if faction_manager.factions[faction_id].has("icon"):
			var icon_path = faction_manager.factions[faction_id]["icon"]
			if ResourceLoader.exists(icon_path):
				faction_icons[faction_id] = load(icon_path)
			else:
				# Usar un ícono por defecto si no se encuentra
				faction_icons[faction_id] = load("res://assets/icons/factions/default_faction_icon.png")
		else:
			# Usar un ícono por defecto si no se especifica
			faction_icons[faction_id] = load("res://assets/icons/factions/default_faction_icon.png")

# Poblar la lista de facciones
func populate_faction_list() -> void:
	# Limpiar lista actual
	faction_list.clear()
	
	# Obtener facciones descubiertas
	var discovered_factions = faction_manager.get_discovered_factions()
	
	# Añadir cada facción descubierta a la lista
	for faction_id in discovered_factions:
		var faction_data = faction_manager.get_faction_data(faction_id)
		var faction_name = faction_data["name"]
		
		# Añadir ícono si está disponible
		if faction_icons.has(faction_id):
			faction_list.add_item(faction_name, faction_icons[faction_id])
		else:
			faction_list.add_item(faction_name)
		
		# Guardar el ID de la facción como metadatos del ítem
		var item_index = faction_list.get_item_count() - 1
		faction_list.set_item_metadata(item_index, faction_id)
		
		# Colorear según el estado de la facción
		var status = faction_manager.get_faction_status(faction_id)
		var color = get_status_color(status)
		faction_list.set_item_custom_fg_color(item_index, color)

# Actualizar detalles de la facción seleccionada
func update_faction_details(faction_id: String) -> void:
	# Verificar si la facción existe
	if not faction_manager.factions.has(faction_id):
		return
	
	# Obtener datos de la facción
	var faction_data = faction_manager.get_faction_data(faction_id)
	
	# Actualizar nombre
	faction_name_label.text = faction_data["name"]
	
	# Actualizar descripción
	faction_description_label.bbcode_text = faction_data["description"]
	
	# Actualizar ícono
	if faction_icons.has(faction_id):
		faction_icon.texture = faction_icons[faction_id]
	
	# Actualizar estado
	var status = faction_manager.get_faction_status(faction_id)
	var status_text = faction_manager.get_faction_status_name(status)
	faction_status_label.text = status_text
	faction_status_label.modulate = get_status_color(status)
	
	# Actualizar reputación
	var reputation = faction_manager.get_reputation(faction_id)
	var normalized_reputation = float(reputation - MIN_REPUTATION) / float(MAX_REPUTATION - MIN_REPUTATION)
	reputation_bar.value = normalized_reputation * 100
	reputation_value_label.text = str(reputation)
	
	# Colorear barra de reputación
	reputation_bar.modulate = get_status_color(status)
	
	# Actualizar líder
	var leader_id = faction_manager.get_faction_leader(faction_id)
	if leader_id.empty():
		leader_label.text = "Desconocido"
	else:
		leader_label.text = leader_id.capitalize()
	
	# Actualizar sede
	if faction_data.has("headquarters"):
		headquarters_label.text = faction_data["headquarters"]
	else:
		headquarters_label.text = "Desconocida"
	
	# Actualizar misiones
	update_faction_quests(faction_id)
	
	# Mostrar panel de detalles
	details_panel.visible = true

# Actualizar lista de misiones de la facción
func update_faction_quests(faction_id: String) -> void:
	# Limpiar lista actual
	for child in quests_container.get_children():
		child.queue_free()
	
	# Obtener misiones de la facción
	var faction_quests = faction_manager.get_faction_quests(faction_id)
	
	# Si no hay misiones, mostrar mensaje
	if faction_quests.empty():
		var label = Label.new()
		label.text = "No hay misiones disponibles"
		quests_container.add_child(label)
		return
	
	# Añadir cada misión a la lista
	for quest_id in faction_quests:
		var quest_data = quest_manager.get_quest_data(quest_id)
		
		# Verificar si la misión existe
		if quest_data.empty():
			continue
		
		# Crear contenedor para la misión
		var quest_container = HBoxContainer.new()
		
		# Crear etiqueta para el nombre de la misión
		var quest_label = Label.new()
		quest_label.text = quest_data["title"]
		quest_container.add_child(quest_label)
		
		# Crear etiqueta para el estado de la misión
		var status_label = Label.new()
		var quest_status = quest_manager.get_quest_status(quest_id)
		status_label.text = quest_manager.get_quest_status_text(quest_status)
		quest_container.add_child(status_label)
		
		# Añadir a la lista
		quests_container.add_child(quest_container)

# Obtener color según el estado de la facción
func get_status_color(status: int) -> Color:
	match status:
		faction_manager.FactionStatus.HOSTILE, faction_manager.FactionStatus.ENEMY:
			return COLOR_HOSTILE
		faction_manager.FactionStatus.SUSPICIOUS:
			return COLOR_SUSPICIOUS
		faction_manager.FactionStatus.NEUTRAL:
			return COLOR_NEUTRAL
		faction_manager.FactionStatus.FRIENDLY:
			return COLOR_FRIENDLY
		faction_manager.FactionStatus.ALLIED:
			return COLOR_ALLIED
		_:
			return COLOR_NEUTRAL

# Manejadores de señales

# Cuando se selecciona una facción de la lista
func _on_faction_selected(index: int) -> void:
	# Obtener ID de la facción seleccionada
	selected_faction = faction_list.get_item_metadata(index)
	
	# Actualizar detalles
	update_faction_details(selected_faction)

# Cuando cambia la reputación con una facción
func _on_reputation_changed(faction_id: String, old_value: int, new_value: int) -> void:
	# Si es la facción seleccionada, actualizar detalles
	if faction_id == selected_faction:
		update_faction_details(faction_id)

# Cuando cambia el estado de una facción
func _on_faction_status_changed(faction_id: String, old_status: int, new_status: int) -> void:
	# Actualizar color en la lista
	for i in range(faction_list.get_item_count()):
		if faction_list.get_item_metadata(i) == faction_id:
			faction_list.set_item_custom_fg_color(i, get_status_color(new_status))
			break
	
	# Si es la facción seleccionada, actualizar detalles
	if faction_id == selected_faction:
		update_faction_details(faction_id)

# Cuando se descubre una nueva facción
func _on_faction_discovered(faction_id: String) -> void:
	# Actualizar lista de facciones
	populate_faction_list()

# Actualizar la interfaz
func update_ui() -> void:
	# Actualizar lista de facciones
	populate_faction_list()
	
	# Si hay una facción seleccionada, actualizar sus detalles
	if not selected_faction.empty():
		update_faction_details(selected_faction)

# Mostrar la interfaz
func show_ui() -> void:
	visible = true
	update_ui()

# Ocultar la interfaz
func hide_ui() -> void:
	visible = false