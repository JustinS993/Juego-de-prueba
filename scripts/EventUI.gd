extends Control

# EventUI.gd - Interfaz de usuario para el sistema de eventos de "Cenizas del Horizonte"
# Muestra eventos activos, disponibles y permite interactuar con ellos

# Referencias a nodos de la UI
onready var event_list = $MainPanel/EventList
onready var event_details_panel = $MainPanel/EventDetailsPanel
onready var event_title = $MainPanel/EventDetailsPanel/Title
onready var event_description = $MainPanel/EventDetailsPanel/Description
onready var event_location = $MainPanel/EventDetailsPanel/Location
onready var event_type_label = $MainPanel/EventDetailsPanel/TypeLabel
onready var event_status_label = $MainPanel/EventDetailsPanel/StatusLabel
onready var event_choices_container = $MainPanel/EventDetailsPanel/ChoicesContainer
onready var event_icon = $MainPanel/EventDetailsPanel/EventIcon
onready var close_button = $MainPanel/CloseButton
onready var no_events_label = $MainPanel/NoEventsLabel

# Variables
var current_event_id = ""
var event_manager = null
var location_names = {
	"ruinas_drossal": "Ruinas de Drossal",
	"desierto_carmesi": "Desierto Carmesí",
	"bosque_putrefacto": "Bosque Putrefacto",
	"sector_helios_07": "Sector Helios-07",
	"el_crater": "El Cráter"
}

# Tipos de eventos para mostrar en la UI
var event_types = {
	0: "Aleatorio",
	1: "Programado",
	2: "Historia",
	3: "Facción",
	4: "Ubicación",
	5: "Clima",
	6: "Encuentro"
}

# Estados de eventos para mostrar en la UI
var event_status = {
	0: "Inactivo",
	1: "Disponible",
	2: "Activo",
	3: "Completado",
	4: "Fallido",
	5: "Expirado"
}

# Colores para los diferentes estados de eventos
var status_colors = {
	0: Color(0.5, 0.5, 0.5),  # Inactivo - Gris
	1: Color(0.0, 0.7, 1.0),   # Disponible - Azul claro
	2: Color(1.0, 0.8, 0.0),   # Activo - Amarillo
	3: Color(0.0, 0.8, 0.0),   # Completado - Verde
	4: Color(0.8, 0.0, 0.0),   # Fallido - Rojo
	5: Color(0.5, 0.0, 0.5)    # Expirado - Púrpura
}

# Iconos para los diferentes tipos de eventos
var type_icons = {
	0: preload("res://assets/icons/event_random.png"),
	1: preload("res://assets/icons/event_scheduled.png"),
	2: preload("res://assets/icons/event_story.png"),
	3: preload("res://assets/icons/event_faction.png"),
	4: preload("res://assets/icons/event_location.png"),
	5: preload("res://assets/icons/event_weather.png"),
	6: preload("res://assets/icons/event_encounter.png")
}

# Función de inicialización
func _ready() -> void:
	# Obtener referencia al gestor de eventos
	event_manager = get_node("/root/EventManager")
	
	# Conectar señales
	event_manager.connect("event_triggered", self, "_on_event_triggered")
	event_manager.connect("event_completed", self, "_on_event_completed")
	event_manager.connect("event_failed", self, "_on_event_failed")
	event_manager.connect("world_state_changed", self, "_on_world_state_changed")
	
	# Conectar señales de la UI
	event_list.connect("item_selected", self, "_on_event_selected")
	close_button.connect("pressed", self, "_on_close_button_pressed")
	
	# Inicializar UI
	refresh_event_list()
	hide_event_details()

# Actualizar lista de eventos
func refresh_event_list() -> void:
	# Limpiar lista actual
	event_list.clear()
	
	# Obtener eventos activos y disponibles
	var active_events = event_manager.get_active_events()
	var available_events = event_manager.get_available_events()
	
	# Verificar si hay eventos para mostrar
	if active_events.empty() and available_events.empty():
		no_events_label.show()
		event_list.hide()
		return
	
	no_events_label.hide()
	event_list.show()
	
	# Añadir eventos activos
	if not active_events.empty():
		# Añadir encabezado para eventos activos
		var active_header = event_list.add_item("EVENTOS ACTIVOS", null, false)
		event_list.set_item_custom_fg_color(active_header, Color(1.0, 0.8, 0.0))
		
		# Añadir cada evento activo
		for event_id in active_events:
			var event_data = event_manager.get_event_data(event_id)
			var icon = type_icons.get(event_data["type"], null)
			
			var item_index = event_list.add_item(event_data["title"], icon)
			event_list.set_item_metadata(item_index, event_id)
			event_list.set_item_custom_fg_color(item_index, status_colors[event_data["status"]])
	
	# Añadir eventos disponibles
	if not available_events.empty():
		# Añadir encabezado para eventos disponibles
		var available_header = event_list.add_item("EVENTOS DISPONIBLES", null, false)
		event_list.set_item_custom_fg_color(available_header, Color(0.0, 0.7, 1.0))
		
		# Añadir cada evento disponible
		for event_id in available_events:
			var event_data = event_manager.get_event_data(event_id)
			var icon = type_icons.get(event_data["type"], null)
			
			var item_index = event_list.add_item(event_data["title"], icon)
			event_list.set_item_metadata(item_index, event_id)
			event_list.set_item_custom_fg_color(item_index, status_colors[event_data["status"]])

# Mostrar detalles de un evento
func show_event_details(event_id: String) -> void:
	# Guardar ID del evento actual
	current_event_id = event_id
	
	# Obtener datos del evento
	var event_data = event_manager.get_event_data(event_id)
	
	# Verificar si se obtuvieron datos
	if event_data.empty():
		hide_event_details()
		return
	
	# Mostrar panel de detalles
	event_details_panel.show()
	
	# Actualizar información
	event_title.text = event_data["title"]
	event_description.text = event_data["description"]
	
	# Mostrar ubicación
	var location_text = "Ubicación: "
	if event_data["location"] == "*":
		location_text += "Cualquier lugar"
	else:
		location_text += location_names.get(event_data["location"], event_data["location"])
	event_location.text = location_text
	
	# Mostrar tipo y estado
	event_type_label.text = "Tipo: " + event_types.get(event_data["type"], "Desconocido")
	event_status_label.text = "Estado: " + event_status.get(event_data["status"], "Desconocido")
	event_status_label.add_color_override("font_color", status_colors.get(event_data["status"], Color.white))
	
	# Mostrar icono
	event_icon.texture = type_icons.get(event_data["type"], null)
	
	# Limpiar contenedor de opciones
	for child in event_choices_container.get_children():
		child.queue_free()
	
	# Mostrar opciones si el evento está activo
	if event_data["status"] == 2:  # Activo
		show_event_choices(event_data)
	else:
		event_choices_container.hide()

# Mostrar opciones de un evento
func show_event_choices(event_data: Dictionary) -> void:
	# Verificar si hay opciones
	if not event_data.has("choices") or event_data["choices"].empty():
		event_choices_container.hide()
		return
	
	# Mostrar contenedor de opciones
	event_choices_container.show()
	
	# Añadir cada opción como un botón
	for choice in event_data["choices"]:
		var button = Button.new()
		button.text = choice["text"]
		button.connect("pressed", self, "_on_choice_selected", [choice["id"]])
		
		# Verificar si la opción está disponible según requisitos de reputación
		var is_available = event_manager.check_required_reputation(choice["required_reputation"])
		button.disabled = not is_available
		
		# Añadir tooltip si está deshabilitado
		if not is_available:
			button.hint_tooltip = "No cumples con los requisitos de reputación para esta opción"
		
		event_choices_container.add_child(button)

# Ocultar detalles de evento
func hide_event_details() -> void:
	current_event_id = ""
	event_details_panel.hide()

# Manejador de selección de evento
func _on_event_selected(index: int) -> void:
	# Verificar si el índice es válido
	if index < 0 or index >= event_list.get_item_count():
		return
	
	# Verificar si el ítem tiene metadatos (algunos pueden ser encabezados)
	var event_id = event_list.get_item_metadata(index)
	
	if event_id != null:
		show_event_details(event_id)

# Manejador de selección de opción
func _on_choice_selected(choice_id: String) -> void:
	# Verificar si hay un evento seleccionado
	if current_event_id.empty():
		return
	
	# Seleccionar opción en el gestor de eventos
	var success = event_manager.select_event_choice(current_event_id, choice_id)
	
	# Actualizar UI
	if success:
		refresh_event_list()
		hide_event_details()

# Manejador de evento activado
func _on_event_triggered(event_id: String, event_data: Dictionary) -> void:
	# Actualizar lista de eventos
	refresh_event_list()
	
	# Si es un evento importante, mostrarlo automáticamente
	if event_data["type"] == 2:  # Evento de historia
		show_event_details(event_id)
		# Mostrar la UI si está oculta
		show()

# Manejador de evento completado
func _on_event_completed(event_id: String, result: String) -> void:
	# Actualizar lista de eventos
	refresh_event_list()
	
	# Si el evento completado es el que se está mostrando, ocultar detalles
	if event_id == current_event_id:
		hide_event_details()

# Manejador de evento fallido
func _on_event_failed(event_id: String, reason: String) -> void:
	# Actualizar lista de eventos
	refresh_event_list()
	
	# Si el evento fallido es el que se está mostrando, ocultar detalles
	if event_id == current_event_id:
		hide_event_details()

# Manejador de cambio en el estado del mundo
func _on_world_state_changed(state_id: String, old_value, new_value) -> void:
	# Actualizar lista de eventos si el cambio puede afectar a eventos disponibles
	if state_id == "current_weather" or state_id.begins_with("faction_tension"):
		refresh_event_list()

# Manejador de botón de cierre
func _on_close_button_pressed() -> void:
	hide()

# Mostrar la UI
func show_ui() -> void:
	show()
	refresh_event_list()

# Función para mostrar notificación de nuevo evento
func show_event_notification(event_id: String) -> void:
	# Obtener datos del evento
	var event_data = event_manager.get_event_data(event_id)
	
	# Verificar si se obtuvieron datos
	if event_data.empty():
		return
	
	# Obtener referencia al gestor de UI
	var ui_manager = get_node("/root/UIManager")
	
	# Mostrar notificación
	ui_manager.show_notification(
		"Nuevo evento: " + event_data["title"],
		event_data["description"],
		type_icons.get(event_data["type"], null),
		5.0  # Duración en segundos
	)