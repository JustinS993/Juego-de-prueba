extends Node

# Señales
signal game_saved(slot)
signal game_loaded(slot)
signal save_failed(error)
signal load_failed(error)

# Constantes
const SAVE_FOLDER = "user://saves/"
const SAVE_NAME_TEMPLATE = "save_%d.json"
const MAX_SAVE_SLOTS = 5

# Variables
var save_data_cache = {}

# Función de inicialización
func _ready() -> void:
	# Asegurarse de que el directorio de guardado existe
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

# Guardar el juego en un slot específico
func save_game(data: Dictionary, slot: int = 1) -> bool:
	# Validar el slot
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		emit_signal("save_failed", "Slot de guardado inválido: " + str(slot))
		return false
	
	# Añadir metadatos al guardado
	var save_data = data.duplicate(true)
	save_data["save_date"] = Time.get_datetime_string_from_system()
	save_data["save_slot"] = slot
	save_data["game_version"] = ProjectSettings.get_setting("application/config/version", "0.1")
	
	# Convertir a JSON
	var json_string = JSON.stringify(save_data)
	
	# Guardar el archivo
	var save_path = SAVE_FOLDER + SAVE_NAME_TEMPLATE % slot
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file == null:
		var error = FileAccess.get_open_error()
		emit_signal("save_failed", "Error al abrir el archivo: " + str(error))
		return false
	
	file.store_string(json_string)
	file.close()
	
	# Actualizar caché
	save_data_cache[slot] = save_data
	
	# Emitir señal
	emit_signal("game_saved", slot)
	
	return true

# Cargar el juego desde un slot específico
func load_game(slot: int = 1) -> Dictionary:
	# Validar el slot
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		emit_signal("load_failed", "Slot de guardado inválido: " + str(slot))
		return {}
	
	# Verificar si el guardado está en caché
	if save_data_cache.has(slot):
		emit_signal("game_loaded", slot)
		return save_data_cache[slot]
	
	# Verificar si el archivo existe
	var save_path = SAVE_FOLDER + SAVE_NAME_TEMPLATE % slot
	if not FileAccess.file_exists(save_path):
		emit_signal("load_failed", "Archivo de guardado no encontrado: " + save_path)
		return {}
	
	# Abrir el archivo
	var file = FileAccess.open(save_path, FileAccess.READ)
	
	if file == null:
		var error = FileAccess.get_open_error()
		emit_signal("load_failed", "Error al abrir el archivo: " + str(error))
		return {}
	
	# Leer el contenido
	var json_string = file.get_as_text()
	file.close()
	
	# Parsear el JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		emit_signal("load_failed", "Error al parsear JSON: " + str(error) + " en línea " + str(json.get_error_line()))
		return {}
	
	var save_data = json.get_data()
	
	# Verificar versión del juego
	var current_version = ProjectSettings.get_setting("application/config/version", "0.1")
	if save_data.has("game_version") and save_data["game_version"] != current_version:
		print("Advertencia: La versión del guardado (%s) no coincide con la versión actual del juego (%s)" % [save_data["game_version"], current_version])
	
	# Actualizar caché
	save_data_cache[slot] = save_data
	
	# Emitir señal
	emit_signal("game_loaded", slot)
	
	return save_data

# Obtener información de todos los guardados disponibles
func get_all_saves() -> Array:
	var saves = []
	
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		var save_info = get_save_info(slot)
		if not save_info.is_empty():
			saves.append(save_info)
	
	return saves

# Obtener información de un guardado específico sin cargarlo completamente
func get_save_info(slot: int) -> Dictionary:
	# Validar el slot
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return {}
	
	# Verificar si el guardado está en caché
	if save_data_cache.has(slot):
		var data = save_data_cache[slot]
		return {
			"slot": slot,
			"date": data["save_date"],
			"player_name": data["player"]["name"],
			"player_level": data["player"]["level"],
			"location": data["current_location"],
			"game_time": data["game_time"],
			"version": data["game_version"]
		}
	
	# Verificar si el archivo existe
	var save_path = SAVE_FOLDER + SAVE_NAME_TEMPLATE % slot
	if not FileAccess.file_exists(save_path):
		return {}
	
	# Abrir el archivo
	var file = FileAccess.open(save_path, FileAccess.READ)
	
	if file == null:
		return {}
	
	# Leer el contenido
	var json_string = file.get_as_text()
	file.close()
	
	# Parsear el JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		return {}
	
	var save_data = json.get_data()
	
	# Extraer información básica
	return {
		"slot": slot,
		"date": save_data["save_date"],
		"player_name": save_data["player"]["name"],
		"player_level": save_data["player"]["level"],
		"location": save_data["current_location"],
		"game_time": save_data["game_time"],
		"version": save_data["game_version"]
	}

# Eliminar un guardado
func delete_save(slot: int) -> bool:
	# Validar el slot
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return false
	
	# Verificar si el archivo existe
	var save_path = SAVE_FOLDER + SAVE_NAME_TEMPLATE % slot
	if not FileAccess.file_exists(save_path):
		return false
	
	# Eliminar el archivo
	var dir = DirAccess.open(SAVE_FOLDER)
	var result = dir.remove(SAVE_NAME_TEMPLATE % slot)
	
	# Eliminar de la caché
	if save_data_cache.has(slot):
		save_data_cache.erase(slot)
	
	return result == OK

# Verificar si existe un guardado en un slot específico
func has_save(slot: int) -> bool:
	# Validar el slot
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return false
	
	# Verificar si el archivo existe
	var save_path = SAVE_FOLDER + SAVE_NAME_TEMPLATE % slot
	return FileAccess.file_exists(save_path)

# Crear un guardado rápido (usa el último slot usado o el primero disponible)
func quick_save(data: Dictionary) -> bool:
	# Buscar el último slot usado
	var last_slot = 1
	for slot in range(MAX_SAVE_SLOTS, 0, -1):
		if has_save(slot):
			last_slot = slot
			break
	
	return save_game(data, last_slot)

# Cargar el guardado más reciente
func quick_load() -> Dictionary:
	# Buscar el guardado más reciente
	var latest_slot = 0
	var latest_time = 0
	
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		var save_info = get_save_info(slot)
		if not save_info.is_empty():
			# Convertir la fecha a timestamp para comparar
			var date_dict = Time.get_datetime_dict_from_datetime_string(save_info["date"], false)
			var timestamp = Time.get_unix_time_from_datetime_dict(date_dict)
			
			if timestamp > latest_time:
				latest_time = timestamp
				latest_slot = slot
	
	if latest_slot > 0:
		return load_game(latest_slot)
	else:
		emit_signal("load_failed", "No se encontraron guardados")
		return {}

# Exportar un guardado a un archivo externo
func export_save(slot: int, export_path: String) -> bool:
	# Cargar el guardado
	var save_data = load_game(slot)
	if save_data.is_empty():
		return false
	
	# Convertir a JSON
	var json_string = JSON.stringify(save_data)
	
	# Guardar en la ubicación especificada
	var file = FileAccess.open(export_path, FileAccess.WRITE)
	
	if file == null:
		return false
	
	file.store_string(json_string)
	file.close()
	
	return true

# Importar un guardado desde un archivo externo
func import_save(import_path: String, slot: int) -> bool:
	# Verificar si el archivo existe
	if not FileAccess.file_exists(import_path):
		return false
	
	# Abrir el archivo
	var file = FileAccess.open(import_path, FileAccess.READ)
	
	if file == null:
		return false
	
	# Leer el contenido
	var json_string = file.get_as_text()
	file.close()
	
	# Parsear el JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		return false
	
	var save_data = json.get_data()
	
	# Validar que es un guardado válido
	if not save_data.has("player") or not save_data.has("game_time"):
		return false
	
	# Guardar en el slot especificado
	return save_game(save_data, slot)

# Limpiar la caché de guardados
func clear_cache() -> void:
	save_data_cache.clear()