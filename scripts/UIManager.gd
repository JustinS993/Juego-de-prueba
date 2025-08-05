extends Node

# UIManager.gd - Sistema de gestión de interfaces de usuario para "Cenizas del Horizonte"
# Coordina todas las interfaces y paneles del juego

# Señales
signal ui_opened(ui_name)
signal ui_closed(ui_name)
signal game_paused(is_paused)

# Enumeraciones
enum UILayer {
	BASE,       # Capa base (HUD, barras de estado)
	MID,        # Capa media (inventario, misiones, facciones)
	TOP,        # Capa superior (diálogos, eventos)
	OVERLAY,    # Capa de superposición (notificaciones, tooltips)
	MODAL       # Capa modal (menú de pausa, configuración)
}

# Referencias a escenas de UI
var ui_scenes = {
	"hud": preload("res://scenes/HUD.tscn"),
	"inventory": preload("res://scenes/InventoryUI.tscn"),
	"quest": preload("res://scenes/QuestUI.tscn"),
	"faction": preload("res://scenes/FactionUI.tscn"),
	"event": preload("res://scenes/EventUI.tscn"),
	"dialogue": preload("res://scenes/DialogueUI.tscn"),
	"pause_menu": preload("res://scenes/PauseMenu.tscn"),
	"settings": preload("res://scenes/SettingsUI.tscn"),
	"character": preload("res://scenes/CharacterUI.tscn"),
	"map": preload("res://scenes/MapUI.tscn"),
	"crafting": preload("res://scenes/CraftingUI.tscn"),
	"shop": preload("res://scenes/ShopUI.tscn"),
	"skill_tree": preload("res://scenes/SkillTreeUI.tscn")
}

# Variables
var active_uis = {}
var ui_stack = []
var is_game_paused = false
var notification_manager = null

# Función de inicialización
func _ready() -> void:
	# Inicializar gestor de notificaciones
	notification_manager = load("res://scenes/NotificationManager.tscn").instance()
	add_child(notification_manager)
	
	# Inicializar HUD
	open_ui("hud", UILayer.BASE)
	
	# Conectar señal de entrada
	set_process_input(true)

# Procesar entrada
func _input(event: InputEvent) -> void:
	# Verificar tecla de escape para menú de pausa
	if event.is_action_pressed("ui_cancel"):
		# Si hay UI modales abiertas, cerrar la última
		if not ui_stack.empty() and active_uis.has(ui_stack.back()):
			var top_ui = active_uis[ui_stack.back()]
			
			# Si es el menú de pausa, cerrarlo y reanudar el juego
			if ui_stack.back() == "pause_menu":
				close_ui("pause_menu")
				set_game_paused(false)
			# Si es otra UI, cerrarla
			elif top_ui["layer"] == UILayer.MODAL or top_ui["layer"] == UILayer.TOP:
				close_ui(ui_stack.back())
		# Si no hay UI modales, abrir menú de pausa
		else:
			open_ui("pause_menu", UILayer.MODAL)
			set_game_paused(true)
		
		# Consumir evento
		get_tree().set_input_as_handled()

# Abrir una interfaz de usuario
func open_ui(ui_name: String, layer: int = UILayer.MID, data: Dictionary = {}) -> void:
	# Verificar si la UI ya está abierta
	if active_uis.has(ui_name):
		# Traer al frente
		bring_ui_to_front(ui_name)
		
		# Actualizar datos si es necesario
		if not data.empty() and active_uis[ui_name]["instance"].has_method("update_data"):
			active_uis[ui_name]["instance"].update_data(data)
		
		return
	
	# Verificar si la escena existe
	if not ui_scenes.has(ui_name):
		push_error("UI no encontrada: " + ui_name)
		return
	
	# Instanciar escena
	var ui_instance = ui_scenes[ui_name].instance()
	add_child(ui_instance)
	
	# Configurar capa
	if ui_instance is CanvasLayer:
		ui_instance.layer = layer
	
	# Inicializar con datos si es necesario
	if not data.empty() and ui_instance.has_method("initialize_data"):
		ui_instance.initialize_data(data)
	
	# Añadir a UIs activas
	active_uis[ui_name] = {
		"instance": ui_instance,
		"layer": layer
	}
	
	# Añadir a la pila si es modal o top
	if layer == UILayer.MODAL or layer == UILayer.TOP:
		ui_stack.append(ui_name)
	
	# Pausar el juego si es modal
	if layer == UILayer.MODAL and not is_game_paused:
		set_game_paused(true)
	
	# Emitir señal
	emit_signal("ui_opened", ui_name)

# Cerrar una interfaz de usuario
func close_ui(ui_name: String) -> void:
	# Verificar si la UI está abierta
	if not active_uis.has(ui_name):
		return
	
	# Obtener instancia
	var ui_instance = active_uis[ui_name]["instance"]
	
	# Eliminar de la pila si está presente
	var stack_index = ui_stack.find(ui_name)
	if stack_index >= 0:
		ui_stack.remove(stack_index)
	
	# Eliminar de UIs activas
	active_uis.erase(ui_name)
	
	# Eliminar instancia
	ui_instance.queue_free()
	
	# Emitir señal
	emit_signal("ui_closed", ui_name)
	
	# Si era la última UI modal, reanudar el juego
	if is_game_paused and ui_stack.empty():
		set_game_paused(false)

# Traer una UI al frente
func bring_ui_to_front(ui_name: String) -> void:
	# Verificar si la UI está abierta
	if not active_uis.has(ui_name):
		return
	
	# Eliminar de la pila si está presente
	var stack_index = ui_stack.find(ui_name)
	if stack_index >= 0:
		ui_stack.remove(stack_index)
		
		# Añadir al final de la pila
		ui_stack.append(ui_name)
	
	# Mover nodo al final de la lista de hijos
	var ui_instance = active_uis[ui_name]["instance"]
	move_child(ui_instance, get_child_count() - 1)

# Verificar si una UI está abierta
func is_ui_open(ui_name: String) -> bool:
	return active_uis.has(ui_name)

# Establecer estado de pausa del juego
func set_game_paused(paused: bool) -> void:
	# Actualizar estado
	is_game_paused = paused
	
	# Pausar árbol de escena
	get_tree().paused = paused
	
	# Emitir señal
	emit_signal("game_paused", paused)

# Mostrar notificación
func show_notification(title: String, message: String, type: int = 0, 
						icon = null, duration: float = 5.0, data: Dictionary = {}) -> int:
	return notification_manager.show_notification(title, message, type, icon, duration, data)

# Mostrar notificación de misión
func show_quest_notification(title: String, message: String, quest_id: String, 
								icon = null, duration: float = 5.0) -> int:
	return notification_manager.show_quest_notification(title, message, quest_id, icon, duration)

# Mostrar notificación de evento
func show_event_notification(title: String, message: String, event_id: String, 
								icon = null, duration: float = 5.0) -> int:
	return notification_manager.show_event_notification(title, message, event_id, icon, duration)

# Mostrar notificación de reputación
func show_reputation_notification(faction_id: String, amount: int, 
									duration: float = 5.0) -> int:
	return notification_manager.show_reputation_notification(faction_id, amount, duration)

# Mostrar notificación de objeto
func show_item_notification(item_id: String, amount: int, is_gained: bool = true, 
								duration: float = 5.0) -> int:
	return notification_manager.show_item_notification(item_id, amount, is_gained, duration)

# Abrir panel de misiones
func open_quest_panel(quest_id: String = "") -> void:
	# Preparar datos
	var data = {}
	if not quest_id.empty():
		data["selected_quest"] = quest_id
	
	# Abrir UI
	open_ui("quest", UILayer.MID, data)

# Abrir panel de eventos
func open_event_panel(event_id: String = "") -> void:
	# Preparar datos
	var data = {}
	if not event_id.empty():
		data["selected_event"] = event_id
	
	# Abrir UI
	open_ui("event", UILayer.MID, data)

# Abrir panel de facciones
func open_faction_panel(faction_id: String = "") -> void:
	# Preparar datos
	var data = {}
	if not faction_id.empty():
		data["selected_faction"] = faction_id
	
	# Abrir UI
	open_ui("faction", UILayer.MID, data)

# Abrir panel de inventario
func open_inventory_panel(item_id: String = "") -> void:
	# Preparar datos
	var data = {}
	if not item_id.empty():
		data["selected_item"] = item_id
	
	# Abrir UI
	open_ui("inventory", UILayer.MID, data)

# Abrir panel de diálogo
func open_dialogue_panel(dialogue_id: String) -> void:
	# Preparar datos
	var data = {"dialogue_id": dialogue_id}
	
	# Abrir UI
	open_ui("dialogue", UILayer.TOP, data)

# Abrir panel de mapa
func open_map_panel(location: String = "") -> void:
	# Preparar datos
	var data = {}
	if not location.empty():
		data["selected_location"] = location
	
	# Abrir UI
	open_ui("map", UILayer.MID, data)

# Abrir panel de personaje
func open_character_panel(tab: String = "") -> void:
	# Preparar datos
	var data = {}
	if not tab.empty():
		data["selected_tab"] = tab
	
	# Abrir UI
	open_ui("character", UILayer.MID, data)

# Abrir panel de árbol de habilidades
func open_skill_tree_panel(branch: String = "") -> void:
	# Preparar datos
	var data = {}
	if not branch.empty():
		data["selected_branch"] = branch
	
	# Abrir UI
	open_ui("skill_tree", UILayer.MID, data)

# Mostrar visión (escena cinemática)
func show_vision(vision_id: String) -> void:
	# Obtener referencia al gestor de visiones
	var vision_manager = get_node("/root/VisionManager")
	
	# Mostrar visión
	vision_manager.show_vision(vision_id)

# Mostrar mensaje de tutorial
func show_tutorial(tutorial_id: String) -> void:
	# Obtener referencia al gestor de tutoriales
	var tutorial_manager = get_node("/root/TutorialManager")
	
	# Mostrar tutorial
	tutorial_manager.show_tutorial(tutorial_id)