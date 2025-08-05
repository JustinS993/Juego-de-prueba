extends Node

# Señales
signal marker_added(marker_id, quest_id, objective_id)
signal marker_removed(marker_id)
signal marker_clicked(marker_id)

# Referencias a escenas
const QUEST_MARKER_SCENE = preload("res://scenes/QuestMarker.tscn")

# Variables
var active_markers = {}
var marker_counter = 0

# Nodos
onready var world_markers_container = null
onready var minimap_markers_container = null

# Inicialización
func _ready():
	# Conectar señales del QuestManager
	QuestManager.connect("quest_added", self, "_on_quest_added")
	QuestManager.connect("quest_completed", self, "_on_quest_completed")
	QuestManager.connect("quest_failed", self, "_on_quest_failed")
	QuestManager.connect("objective_updated", self, "_on_objective_updated")
	
	# Esperar un frame para que otros nodos se inicialicen
	yield(get_tree(), "idle_frame")
	
	# Buscar contenedores de marcadores
	world_markers_container = get_node_or_null("/root/GameWorld/WorldMarkers")
	minimap_markers_container = get_node_or_null("/root/GameWorld/UI/Minimap/Markers")
	
	# Si no existen los contenedores, crear nodos temporales
	if world_markers_container == null:
		world_markers_container = Node2D.new()
		world_markers_container.name = "WorldMarkers"
		add_child(world_markers_container)
	
	if minimap_markers_container == null:
		minimap_markers_container = Node2D.new()
		minimap_markers_container.name = "MinimapMarkers"
		add_child(minimap_markers_container)
	
	# Inicializar marcadores para misiones activas
	initialize_active_quest_markers()

# Inicializar marcadores para todas las misiones activas
func initialize_active_quest_markers():
	var active_quests = QuestManager.get_active_quests()
	
	for quest_id in active_quests:
		_on_quest_added(quest_id)

# Añadir un marcador de misión
func add_quest_marker(quest_id, objective_id, position, marker_type = "objective", text = ""):
	# Generar ID único para el marcador
	marker_counter += 1
	var marker_id = "marker_" + str(marker_counter)
	
	# Crear instancia del marcador para el mundo
	var world_marker = QUEST_MARKER_SCENE.instance()
	world_markers_container.add_child(world_marker)
	world_marker.setup(marker_id, quest_id, objective_id, position, marker_type, text)
	
	# Conectar señal de clic
	world_marker.connect("marker_clicked", self, "_on_marker_clicked")
	
	# Crear instancia del marcador para el minimapa (versión simplificada)
	if minimap_markers_container != null:
		var minimap_marker = QUEST_MARKER_SCENE.instance()
		minimap_markers_container.add_child(minimap_marker)
		minimap_marker.setup(marker_id + "_mini", quest_id, objective_id, position, marker_type, "")
		minimap_marker.scale = Vector2(0.5, 0.5) # Más pequeño para el minimapa
		
		# Conectar señal de clic
		minimap_marker.connect("marker_clicked", self, "_on_marker_clicked")
	
	# Guardar referencia al marcador
	active_markers[marker_id] = {
		"world_marker": world_marker,
		"minimap_marker": minimap_marker if minimap_markers_container != null else null,
		"quest_id": quest_id,
		"objective_id": objective_id,
		"position": position,
		"type": marker_type
	}
	
	# Emitir señal
	emit_signal("marker_added", marker_id, quest_id, objective_id)
	
	return marker_id

# Eliminar un marcador de misión
func remove_quest_marker(marker_id):
	if active_markers.has(marker_id):
		# Eliminar marcador del mundo
		if active_markers[marker_id]["world_marker"] != null and is_instance_valid(active_markers[marker_id]["world_marker"]):
			active_markers[marker_id]["world_marker"].queue_free()
		
		# Eliminar marcador del minimapa
		if active_markers[marker_id]["minimap_marker"] != null and is_instance_valid(active_markers[marker_id]["minimap_marker"]):
			active_markers[marker_id]["minimap_marker"].queue_free()
		
		# Eliminar referencia
		active_markers.erase(marker_id)
		
		# Emitir señal
		emit_signal("marker_removed", marker_id)
		
		return true
	
	return false

# Eliminar todos los marcadores de una misión
func remove_quest_markers(quest_id):
	var markers_to_remove = []
	
	# Identificar marcadores a eliminar
	for marker_id in active_markers:
		if active_markers[marker_id]["quest_id"] == quest_id:
			markers_to_remove.append(marker_id)
	
	# Eliminar marcadores
	for marker_id in markers_to_remove:
		remove_quest_marker(marker_id)

# Eliminar marcador de un objetivo específico
func remove_objective_marker(quest_id, objective_id):
	var markers_to_remove = []
	
	# Identificar marcadores a eliminar
	for marker_id in active_markers:
		if active_markers[marker_id]["quest_id"] == quest_id and active_markers[marker_id]["objective_id"] == objective_id:
			markers_to_remove.append(marker_id)
	
	# Eliminar marcadores
	for marker_id in markers_to_remove:
		remove_quest_marker(marker_id)

# Obtener posición de un marcador
func get_marker_position(marker_id):
	if active_markers.has(marker_id):
		return active_markers[marker_id]["position"]
	
	return Vector2.ZERO

# Actualizar posición de un marcador
func update_marker_position(marker_id, new_position):
	if active_markers.has(marker_id):
		# Actualizar posición en el diccionario
		active_markers[marker_id]["position"] = new_position
		
		# Actualizar posición del marcador en el mundo
		if active_markers[marker_id]["world_marker"] != null and is_instance_valid(active_markers[marker_id]["world_marker"]):
			active_markers[marker_id]["world_marker"].global_position = new_position
		
		# Actualizar posición del marcador en el minimapa
		if active_markers[marker_id]["minimap_marker"] != null and is_instance_valid(active_markers[marker_id]["minimap_marker"]):
			active_markers[marker_id]["minimap_marker"].global_position = new_position
		
		return true
	
	return false

# Cuando se añade una misión
func _on_quest_added(quest_id):
	var quest_data = QuestManager.get_quest_info(quest_id)
	
	if quest_data.empty():
		return
	
	# Añadir marcadores para cada objetivo
	for objective in quest_data["objectives"]:
		# Verificar si el objetivo tiene una posición definida
		if objective.has("position") and objective["position"] is Vector2:
			# Determinar tipo de marcador según el objetivo
			var marker_type = "objective"
			if objective.has("type"):
				if objective["type"] == "talk":
					marker_type = "npc"
				elif objective["type"] == "collect" or objective["type"] == "find":
					marker_type = "item"
				elif objective["type"] == "kill" or objective["type"] == "defeat":
					marker_type = "enemy"
				elif objective["type"] == "explore" or objective["type"] == "reach":
					marker_type = "location"
			
			# Añadir marcador
			add_quest_marker(quest_id, objective["id"], objective["position"], marker_type, objective["description"])

# Cuando se completa una misión
func _on_quest_completed(quest_id):
	# Eliminar todos los marcadores de la misión
	remove_quest_markers(quest_id)

# Cuando falla una misión
func _on_quest_failed(quest_id):
	# Eliminar todos los marcadores de la misión
	remove_quest_markers(quest_id)

# Cuando se actualiza un objetivo
func _on_objective_updated(quest_id, objective_id, current_amount, target_amount, completed):
	# Si el objetivo se completó, eliminar su marcador
	if completed:
		remove_objective_marker(quest_id, objective_id)

# Cuando se hace clic en un marcador
func _on_marker_clicked(marker_id):
	# Emitir señal
	emit_signal("marker_clicked", marker_id)
	
	# Obtener información del marcador
	if active_markers.has(marker_id):
		var quest_id = active_markers[marker_id]["quest_id"]
		var objective_id = active_markers[marker_id]["objective_id"]
		
		# Establecer como objetivo seguido
		GameManager.set_tracked_quest(quest_id, objective_id)