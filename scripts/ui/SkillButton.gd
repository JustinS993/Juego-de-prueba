extends TextureButton

# Señales
signal skill_hovered(skill_id)
signal skill_unhovered()

# Referencias a nodos
@onready var skill_icon = $SkillIcon
@onready var skill_frame = $SkillFrame
@onready var skill_name_label = $SkillNameLabel
@onready var level_indicator = $LevelIndicator
@onready var lock_icon = $LockIcon
@onready var glow_effect = $GlowEffect

# Variables
var skill_id: String = ""
var skill_type: int = 0
var tree_color: Color = Color.WHITE

# Constantes
const PASSIVE_FRAME = preload("res://assets/sprites/ui/skill_frame_passive.png")
const ACTIVE_FRAME = preload("res://assets/sprites/ui/skill_frame_active.png")
const ULTIMATE_FRAME = preload("res://assets/sprites/ui/skill_frame_ultimate.png")
const LOCK_TEXTURE = preload("res://assets/sprites/ui/skill_lock.png")

# Función de inicialización
func _ready() -> void:
	# Conectar señales
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
	# Configurar apariencia inicial
	glow_effect.visible = false

# Establecer ID de la habilidad
func set_skill_id(id: String) -> void:
	skill_id = id

# Establecer nombre de la habilidad
func set_skill_name(name: String) -> void:
	skill_name_label.text = name

# Establecer icono de la habilidad
func set_skill_icon(icon_path: String) -> void:
	# Cargar textura del icono
	var texture = load(icon_path)
	if texture:
		skill_icon.texture = texture

# Establecer tipo de habilidad
func set_skill_type(type: int) -> void:
	skill_type = type
	
	# Actualizar marco según el tipo
	match type:
		0: # Pasiva
			skill_frame.texture = PASSIVE_FRAME
		1: # Activa
			skill_frame.texture = ACTIVE_FRAME
		2: # Definitiva
			skill_frame.texture = ULTIMATE_FRAME

# Establecer color del árbol
func set_tree_color(color: Color) -> void:
	tree_color = color
	
	# Aplicar color al marco y al efecto de brillo
	skill_frame.modulate = tree_color
	glow_effect.modulate = tree_color

# Actualizar estado de la habilidad
func update_state(is_unlocked: bool, current_level: int, max_level: int) -> void:
	# Actualizar visibilidad del icono de bloqueo
	lock_icon.visible = not is_unlocked
	
	# Actualizar indicador de nivel
	if is_unlocked:
		level_indicator.visible = true
		level_indicator.value = float(current_level) / float(max_level) * 100.0
	else:
		level_indicator.visible = false
	
	# Actualizar opacidad del icono
	if is_unlocked:
		skill_icon.modulate.a = 1.0
	else:
		skill_icon.modulate.a = 0.5

# Cuando el ratón entra en el botón
func _on_mouse_entered() -> void:
	# Mostrar efecto de brillo
	glow_effect.visible = true
	
	# Emitir señal
	emit_signal("skill_hovered", skill_id)

# Cuando el ratón sale del botón
func _on_mouse_exited() -> void:
	# Ocultar efecto de brillo
	glow_effect.visible = false
	
	# Emitir señal
	emit_signal("skill_unhovered")