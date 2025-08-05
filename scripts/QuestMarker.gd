extends Node2D

# Señales
signal marker_clicked(marker_id)

# Referencias a nodos
onready var sprite = $Sprite
onready var label = $Label
onready var animation_player = $AnimationPlayer
onready var distance_label = $DistanceLabel

# Variables
var marker_id = ""
var quest_id = ""
var objective_id = ""
var target_position = Vector2.ZERO
var is_on_screen = true
var is_tracked = false
var marker_type = "objective" # objective, location, npc, item, enemy
var marker_distance = 0.0
var player_ref = null
var update_timer = 0.0
var update_interval = 0.5 # Actualizar cada medio segundo

# Constantes
const MARKER_TEXTURES = {
	"objective": preload("res://assets/icons/marker_objective.png"),
	"location": preload("res://assets/icons/marker_location.png"),
	"npc": preload("res://assets/icons/marker_npc.png"),
	"item": preload("res://assets/icons/marker_item.png"),
	"enemy": preload("res://assets/icons/marker_enemy.png")
}

const MARKER_COLORS = {
	"objective": Color(1.0, 0.8, 0.2), # Amarillo
	"location": Color(0.4, 0.7, 1.0), # Azul
	"npc": Color(0.2, 0.8, 0.2),      # Verde
	"item": Color(0.8, 0.4, 1.0),     # Púrpura
	"enemy": Color(1.0, 0.3, 0.3)      # Rojo
}

const QUEST_TYPE_COLORS = {
	QuestManager.QuestType.MAIN: Color(0.9, 0.7, 0.2),       # Dorado
	QuestManager.QuestType.SIDE: Color(0.4, 0.6, 0.9),       # Azul
	QuestManager.QuestType.FACTION: Color(0.7, 0.3, 0.7),    # Púrpura
	QuestManager.QuestType.EXPLORATION: Color(0.3, 0.8, 0.4), # Verde
	QuestManager.QuestType.BOSS_HUNT: Color(0.9, 0.3, 0.3)    # Rojo
}

# Inicialización
func _ready():
	# Iniciar animación
	animation_player.play("pulse")
	
	# Obtener referencia al jugador
	player_ref = get_tree().get_nodes_in_group("player")[0] if get_tree().has_group("player") else null
	
	# Actualizar apariencia
	update_appearance()

# Proceso
func _process(delta):
	# Actualizar periódicamente
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_marker_state()

# Configurar el marcador
func setup(id, quest, objective, position, type = "objective", text = ""):
	marker_id = id
	quest_id = quest
	objective_id = objective
	target_position = position
	marker_type = type
	
	# Establecer posición
	global_position = target_position
	
	# Establecer texto
	if text != "":
		label.text = text
	else:
		# Obtener texto del objetivo
		var quest_data = QuestManager.get_quest_info(quest_id)
		if not quest_data.empty():
			for obj in quest_data["objectives"]:
				if obj["id"] == objective_id:
					label.text = obj["description"]
					break
	
	# Verificar si está siendo seguido
	check_if_tracked()
	
	# Actualizar apariencia
	update_appearance()

# Verificar si este marcador corresponde al objetivo seguido
func check_if_tracked():
	var tracked_data = GameManager.get_tracked_quest()
	is_tracked = (tracked_data["quest_id"] == quest_id and tracked_data["objective_id"] == objective_id)

# Actualizar apariencia del marcador
func update_appearance():
	# Establecer textura según el tipo
	if MARKER_TEXTURES.has(marker_type):
		sprite.texture = MARKER_TEXTURES[marker_type]
	
	# Establecer color según el tipo
	var base_color = MARKER_COLORS[marker_type] if MARKER_COLORS.has(marker_type) else Color.white
	
	# Si está siendo seguido, usar el color del tipo de misión
	if is_tracked:
		var quest_data = QuestManager.get_quest_info(quest_id)
		if not quest_data.empty() and QUEST_TYPE_COLORS.has(quest_data["type"]):
			base_color = QUEST_TYPE_COLORS[quest_data["type"]]
		
		# Hacer el marcador más grande
		sprite.scale = Vector2(1.5, 1.5)
		
		# Cambiar animación
		animation_player.play("tracked_pulse")
	else:
		# Tamaño normal
		sprite.scale = Vector2(1.0, 1.0)
		
		# Animación normal
		animation_player.play("pulse")
	
	# Aplicar color
	sprite.modulate = base_color
	label.modulate = base_color

# Actualizar estado del marcador
func update_marker_state():
	# Verificar si está siendo seguido
	check_if_tracked()
	
	# Calcular distancia al jugador
	if player_ref != null:
		marker_distance = global_position.distance_to(player_ref.global_position)
		distance_label.text = str(int(marker_distance)) + "m"
		
		# Mostrar distancia solo si está siendo seguido
		distance_label.visible = is_tracked
	
	# Verificar si el objetivo ha sido completado
	if QuestManager.is_quest_active(quest_id):
		var progress = QuestManager.get_objective_progress(quest_id, objective_id)
		if not progress.empty() and progress["completed"]:
			# Ocultar marcador si el objetivo está completado
			queue_free()
			return
	elif QuestManager.is_quest_completed(quest_id) or QuestManager.is_quest_failed(quest_id):
		# Ocultar marcador si la misión está completada o fallida
		queue_free()
		return

# Entrada de ratón
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# Emitir señal de clic
		emit_signal("marker_clicked", marker_id)
		
		# Si no está siendo seguido, seguir este objetivo
		if not is_tracked:
			GameManager.set_tracked_quest(quest_id, objective_id)
			check_if_tracked()
			update_appearance()

# Cuando el ratón entra en el área
func _on_Area2D_mouse_entered():
	# Aumentar tamaño
	sprite.scale *= 1.2
	
	# Mostrar etiqueta
	label.visible = true

# Cuando el ratón sale del área
func _on_Area2D_mouse_exited():
	# Restaurar tamaño
	if is_tracked:
		sprite.scale = Vector2(1.5, 1.5)
	else:
		sprite.scale = Vector2(1.0, 1.0)
	
	# Ocultar etiqueta si no está siendo seguido
	label.visible = is_tracked