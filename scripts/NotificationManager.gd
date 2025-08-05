extends CanvasLayer

# NotificationManager.gd - Sistema de notificaciones para "Cenizas del Horizonte"
# Muestra notificaciones temporales para eventos, misiones, cambios de reputación, etc.

# Señales
signal notification_shown(notification_id, notification_data)
signal notification_hidden(notification_id)

# Enumeraciones
enum NotificationType {
	INFO,      # Información general
	QUEST,     # Relacionado con misiones
	EVENT,     # Relacionado con eventos
	REPUTATION,# Cambios de reputación
	COMBAT,    # Relacionado con combate
	ITEM,      # Objetos obtenidos o perdidos
	WARNING,   # Advertencias
	ERROR      # Errores
}

# Referencias a nodos
onready var notification_container = $NotificationContainer
onready var notification_template = preload("res://scenes/NotificationItem.tscn")

# Variables
var active_notifications = {}
var notification_queue = []
var max_visible_notifications = 5
var next_notification_id = 0

# Colores para los diferentes tipos de notificaciones
var type_colors = {
	NotificationType.INFO: Color(0.0, 0.7, 1.0),       # Azul claro
	NotificationType.QUEST: Color(1.0, 0.8, 0.0),       # Amarillo
	NotificationType.EVENT: Color(0.8, 0.4, 1.0),       # Púrpura
	NotificationType.REPUTATION: Color(0.0, 0.8, 0.4),  # Verde azulado
	NotificationType.COMBAT: Color(1.0, 0.4, 0.0),      # Naranja
	NotificationType.ITEM: Color(0.4, 0.8, 0.0),        # Verde
	NotificationType.WARNING: Color(1.0, 0.6, 0.0),     # Ámbar
	NotificationType.ERROR: Color(1.0, 0.0, 0.0)        # Rojo
}

# Iconos para los diferentes tipos de notificaciones
var type_icons = {
	NotificationType.INFO: preload("res://assets/icons/notification_info.png"),
	NotificationType.QUEST: preload("res://assets/icons/notification_quest.png"),
	NotificationType.EVENT: preload("res://assets/icons/notification_event.png"),
	NotificationType.REPUTATION: preload("res://assets/icons/notification_reputation.png"),
	NotificationType.COMBAT: preload("res://assets/icons/notification_combat.png"),
	NotificationType.ITEM: preload("res://assets/icons/notification_item.png"),
	NotificationType.WARNING: preload("res://assets/icons/notification_warning.png"),
	NotificationType.ERROR: preload("res://assets/icons/notification_error.png")
}

# Función de inicialización
func _ready() -> void:
	# Asegurarse de que el contenedor esté vacío al inicio
	for child in notification_container.get_children():
		child.queue_free()

# Mostrar una notificación
func show_notification(title: String, message: String, type: int = NotificationType.INFO, 
						icon = null, duration: float = 5.0, data: Dictionary = {}) -> int:
	# Crear datos de la notificación
	var notification_id = next_notification_id
	next_notification_id += 1
	
	var notification_data = {
		"id": notification_id,
		"title": title,
		"message": message,
		"type": type,
		"icon": icon if icon != null else type_icons.get(type, null),
		"color": type_colors.get(type, Color.white),
		"duration": duration,
		"data": data,
		"time_created": OS.get_ticks_msec()
	}
	
	# Verificar si hay espacio para mostrar la notificación
	if active_notifications.size() < max_visible_notifications:
		# Mostrar la notificación inmediatamente
		_display_notification(notification_data)
	else:
		# Añadir a la cola
		notification_queue.append(notification_data)
	
	# Emitir señal
	emit_signal("notification_shown", notification_id, notification_data)
	
	return notification_id

# Mostrar notificación de misión
func show_quest_notification(title: String, message: String, quest_id: String, 
								icon = null, duration: float = 5.0) -> int:
	# Crear datos adicionales
	var data = {"quest_id": quest_id}
	
	# Mostrar notificación
	return show_notification(title, message, NotificationType.QUEST, icon, duration, data)

# Mostrar notificación de evento
func show_event_notification(title: String, message: String, event_id: String, 
								icon = null, duration: float = 5.0) -> int:
	# Crear datos adicionales
	var data = {"event_id": event_id}
	
	# Mostrar notificación
	return show_notification(title, message, NotificationType.EVENT, icon, duration, data)

# Mostrar notificación de reputación
func show_reputation_notification(faction_id: String, amount: int, 
									duration: float = 5.0) -> int:
	# Obtener referencia al gestor de facciones
	var faction_manager = get_node("/root/FactionManager")
	
	# Obtener nombre de la facción
	var faction_name = faction_manager.get_faction_name(faction_id)
	
	# Crear título y mensaje
	var title = "Reputación: " + faction_name
	var message = ""
	
	if amount > 0:
		message = "Has ganado " + str(amount) + " puntos de reputación con " + faction_name
	else:
		message = "Has perdido " + str(abs(amount)) + " puntos de reputación con " + faction_name
	
	# Obtener icono de la facción
	var icon = faction_manager.get_faction_icon(faction_id)
	
	# Crear datos adicionales
	var data = {
		"faction_id": faction_id,
		"amount": amount
	}
	
	# Mostrar notificación
	return show_notification(title, message, NotificationType.REPUTATION, icon, duration, data)

# Mostrar notificación de objeto
func show_item_notification(item_id: String, amount: int, is_gained: bool = true, 
								duration: float = 5.0) -> int:
	# Obtener referencia al gestor de inventario
	var inventory_manager = get_node("/root/InventoryManager")
	
	# Obtener datos del objeto
	var item_data = inventory_manager.get_item_data(item_id)
	
	# Crear título y mensaje
	var title = "Objeto: " + item_data["name"]
	var message = ""
	
	if is_gained:
		message = "Has obtenido " + str(amount) + "x " + item_data["name"]
	else:
		message = "Has perdido " + str(amount) + "x " + item_data["name"]
	
	# Obtener icono del objeto
	var icon = item_data["icon"]
	
	# Crear datos adicionales
	var data = {
		"item_id": item_id,
		"amount": amount,
		"is_gained": is_gained
	}
	
	# Mostrar notificación
	return show_notification(title, message, NotificationType.ITEM, icon, duration, data)

# Mostrar notificación de combate
func show_combat_notification(title: String, message: String, 
								icon = null, duration: float = 5.0) -> int:
	# Mostrar notificación
	return show_notification(title, message, NotificationType.COMBAT, icon, duration)

# Mostrar notificación de advertencia
func show_warning_notification(title: String, message: String, 
									duration: float = 5.0) -> int:
	# Mostrar notificación
	return show_notification(title, message, NotificationType.WARNING, null, duration)

# Mostrar notificación de error
func show_error_notification(title: String, message: String, 
								duration: float = 5.0) -> int:
	# Mostrar notificación
	return show_notification(title, message, NotificationType.ERROR, null, duration)

# Ocultar una notificación específica
func hide_notification(notification_id: int) -> void:
	# Verificar si la notificación está activa
	if not active_notifications.has(notification_id):
		return
	
	# Obtener instancia de la notificación
	var notification_instance = active_notifications[notification_id]["instance"]
	
	# Iniciar animación de salida
	notification_instance.hide_notification()

# Ocultar todas las notificaciones
func hide_all_notifications() -> void:
	# Ocultar cada notificación activa
	for notification_id in active_notifications.keys():
		hide_notification(notification_id)
	
	# Limpiar cola
	notification_queue.clear()

# Mostrar una notificación en la UI
func _display_notification(notification_data: Dictionary) -> void:
	# Instanciar plantilla de notificación
	var notification_instance = notification_template.instance()
	notification_container.add_child(notification_instance)
	
	# Configurar la notificación
	notification_instance.setup(
		notification_data["id"],
		notification_data["title"],
		notification_data["message"],
		notification_data["icon"],
		notification_data["color"],
		notification_data["duration"]
	)
	
	# Conectar señales
	notification_instance.connect("notification_clicked", self, "_on_notification_clicked")
	notification_instance.connect("notification_hidden", self, "_on_notification_hidden")
	
	# Añadir a notificaciones activas
	notification_data["instance"] = notification_instance
	active_notifications[notification_data["id"]] = notification_data

# Manejador de clic en notificación
func _on_notification_clicked(notification_id: int) -> void:
	# Verificar si la notificación está activa
	if not active_notifications.has(notification_id):
		return
	
	# Obtener datos de la notificación
	var notification_data = active_notifications[notification_id]
	
	# Realizar acción según el tipo de notificación
	match notification_data["type"]:
		NotificationType.QUEST:
			# Abrir detalles de la misión
			if notification_data["data"].has("quest_id"):
				open_quest_details(notification_data["data"]["quest_id"])
		
		NotificationType.EVENT:
			# Abrir detalles del evento
			if notification_data["data"].has("event_id"):
				open_event_details(notification_data["data"]["event_id"])
		
		NotificationType.REPUTATION:
			# Abrir detalles de la facción
			if notification_data["data"].has("faction_id"):
				open_faction_details(notification_data["data"]["faction_id"])
		
		NotificationType.ITEM:
			# Abrir detalles del objeto
			if notification_data["data"].has("item_id"):
				open_item_details(notification_data["data"]["item_id"])

# Manejador de notificación oculta
func _on_notification_hidden(notification_id: int) -> void:
	# Verificar si la notificación está activa
	if not active_notifications.has(notification_id):
		return
	
	# Eliminar de notificaciones activas
	active_notifications.erase(notification_id)
	
	# Emitir señal
	emit_signal("notification_hidden", notification_id)
	
	# Mostrar siguiente notificación en la cola si existe
	if not notification_queue.empty():
		var next_notification = notification_queue.pop_front()
		_display_notification(next_notification)

# Abrir detalles de misión
func open_quest_details(quest_id: String) -> void:
	# Obtener referencia al gestor de UI
	var ui_manager = get_node("/root/UIManager")
	
	# Abrir panel de misiones y mostrar detalles
	ui_manager.open_quest_panel(quest_id)

# Abrir detalles de evento
func open_event_details(event_id: String) -> void:
	# Obtener referencia al gestor de UI
	var ui_manager = get_node("/root/UIManager")
	
	# Abrir panel de eventos y mostrar detalles
	ui_manager.open_event_panel(event_id)

# Abrir detalles de facción
func open_faction_details(faction_id: String) -> void:
	# Obtener referencia al gestor de UI
	var ui_manager = get_node("/root/UIManager")
	
	# Abrir panel de facciones y mostrar detalles
	ui_manager.open_faction_panel(faction_id)

# Abrir detalles de objeto
func open_item_details(item_id: String) -> void:
	# Obtener referencia al gestor de UI
	var ui_manager = get_node("/root/UIManager")
	
	# Abrir inventario y mostrar detalles del objeto
	ui_manager.open_inventory_panel(item_id)