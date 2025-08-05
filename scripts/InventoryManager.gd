extends Node

# Señales
signal item_added(item_id, quantity)
signal item_removed(item_id, quantity)
signal item_used(item_id)
signal item_equipped(item_id, slot)
signal item_unequipped(item_id, slot)
signal currency_changed(new_amount)
signal inventory_updated()
signal weight_changed(current_weight, max_weight)

# Enumeraciones
enum ItemType {
	CONSUMABLE,
	WEAPON,
	ARMOR,
	AMMUNITION,
	COMPONENT,
	QUEST,
	BLUEPRINT,
	MISCELLANEOUS
}

enum EquipSlot {
	HEAD,
	BODY,
	HANDS,
	LEGS,
	FEET,
	WEAPON_MAIN,
	WEAPON_SECONDARY,
	ACCESSORY_1,
	ACCESSORY_2
}

# Variables
var inventory: Dictionary = {}
var equipped_items: Dictionary = {}
var currency: int = 0
var max_weight: float = 50.0
var current_weight: float = 0.0
var item_database: Dictionary = {}

# Función de inicialización
func _ready() -> void:
	# Inicializar slots de equipamiento
	for slot in range(EquipSlot.size()):
		equipped_items[slot] = ""
	
	# Cargar base de datos de objetos
	load_item_database()
	
	# Añadir objetos iniciales para pruebas
	add_starting_items()

# Cargar base de datos de objetos
func load_item_database() -> void:
	# Consumibles
	item_database["medkit_small"] = {
		"id": "medkit_small",
		"name": "Botiquín Pequeño",
		"description": "Un pequeño kit médico que restaura 30 puntos de salud.",
		"type": ItemType.CONSUMABLE,
		"weight": 0.5,
		"value": 25,
		"stackable": true,
		"max_stack": 10,
		"effects": [{"type": "heal", "value": 30}],
		"icon": "res://assets/sprites/items/medkit_small.png"
	}
	
	item_database["energy_drink"] = {
		"id": "energy_drink",
		"name": "Bebida Energética",
		"description": "Restaura 20 puntos de energía.",
		"type": ItemType.CONSUMABLE,
		"weight": 0.3,
		"value": 15,
		"stackable": true,
		"max_stack": 10,
		"effects": [{"type": "energy", "value": 20}],
		"icon": "res://assets/sprites/items/energy_drink.png"
	}
	
	item_database["mutagen_vial"] = {
		"id": "mutagen_vial",
		"name": "Vial de Mutágeno",
		"description": "Aumenta la carga mutante en 25 puntos.",
		"type": ItemType.CONSUMABLE,
		"weight": 0.2,
		"value": 40,
		"stackable": true,
		"max_stack": 5,
		"effects": [{"type": "mutant_charge", "value": 25}],
		"icon": "res://assets/sprites/items/mutagen_vial.png"
	}
	
	item_database["antidote"] = {
		"id": "antidote",
		"name": "Antídoto",
		"description": "Cura el envenenamiento y reduce la radiación.",
		"type": ItemType.CONSUMABLE,
		"weight": 0.3,
		"value": 30,
		"stackable": true,
		"max_stack": 5,
		"effects": [
			{"type": "remove_status", "status": "poisoned"},
			{"type": "radiation", "value": -10}
		],
		"icon": "res://assets/sprites/items/antidote.png"
	}
	
	# Armas
	item_database["rusty_pipe"] = {
		"id": "rusty_pipe",
		"name": "Tubería Oxidada",
		"description": "Un arma cuerpo a cuerpo improvisada.",
		"type": ItemType.WEAPON,
		"weight": 2.0,
		"value": 10,
		"stackable": false,
		"equip_slot": EquipSlot.WEAPON_MAIN,
		"damage": 8,
		"damage_type": "physical",
		"durability": 50,
		"max_durability": 50,
		"attributes": {"strength": 1},
		"icon": "res://assets/sprites/items/rusty_pipe.png"
	}
	
	item_database["scrap_pistol"] = {
		"id": "scrap_pistol",
		"name": "Pistola de Chatarra",
		"description": "Una pistola improvisada con piezas de chatarra.",
		"type": ItemType.WEAPON,
		"weight": 1.5,
		"value": 45,
		"stackable": false,
		"equip_slot": EquipSlot.WEAPON_MAIN,
		"damage": 12,
		"damage_type": "physical",
		"durability": 40,
		"max_durability": 40,
		"ammo_type": "scrap_bullets",
		"attributes": {"perception": 1},
		"icon": "res://assets/sprites/items/scrap_pistol.png"
	}
	
	item_database["energy_dagger"] = {
		"id": "energy_dagger",
		"name": "Daga de Energía",
		"description": "Una daga que emite una hoja de energía pura.",
		"type": ItemType.WEAPON,
		"weight": 0.8,
		"value": 120,
		"stackable": false,
		"equip_slot": EquipSlot.WEAPON_SECONDARY,
		"damage": 15,
		"damage_type": "energy",
		"durability": 60,
		"max_durability": 60,
		"attributes": {"agility": 2},
		"icon": "res://assets/sprites/items/energy_dagger.png"
	}
	
	# Armaduras
	item_database["scrap_helmet"] = {
		"id": "scrap_helmet",
		"name": "Casco de Chatarra",
		"description": "Un casco improvisado con piezas de metal.",
		"type": ItemType.ARMOR,
		"weight": 1.5,
		"value": 30,
		"stackable": false,
		"equip_slot": EquipSlot.HEAD,
		"defense": 5,
		"durability": 40,
		"max_durability": 40,
		"resistances": {"physical": 5, "energy": 2},
		"attributes": {"perception": -1, "resistance": 1},
		"icon": "res://assets/sprites/items/scrap_helmet.png"
	}
	
	item_database["leather_jacket"] = {
		"id": "leather_jacket",
		"name": "Chaqueta de Cuero",
		"description": "Una chaqueta de cuero resistente.",
		"type": ItemType.ARMOR,
		"weight": 3.0,
		"value": 50,
		"stackable": false,
		"equip_slot": EquipSlot.BODY,
		"defense": 8,
		"durability": 60,
		"max_durability": 60,
		"resistances": {"physical": 8, "toxic": 5},
		"attributes": {"resistance": 1},
		"icon": "res://assets/sprites/items/leather_jacket.png"
	}
	
	item_database["tech_gloves"] = {
		"id": "tech_gloves",
		"name": "Guantes Tecnológicos",
		"description": "Guantes con circuitos integrados que mejoran la destreza.",
		"type": ItemType.ARMOR,
		"weight": 0.8,
		"value": 75,
		"stackable": false,
		"equip_slot": EquipSlot.HANDS,
		"defense": 3,
		"durability": 50,
		"max_durability": 50,
		"resistances": {"energy": 10},
		"attributes": {"agility": 2, "intelligence": 1},
		"icon": "res://assets/sprites/items/tech_gloves.png"
	}
	
	# Munición
	item_database["scrap_bullets"] = {
		"id": "scrap_bullets",
		"name": "Balas de Chatarra",
		"description": "Munición improvisada para armas de fuego.",
		"type": ItemType.AMMUNITION,
		"weight": 0.1,
		"value": 2,
		"stackable": true,
		"max_stack": 50,
		"ammo_type": "scrap_bullets",
		"icon": "res://assets/sprites/items/scrap_bullets.png"
	}
	
	item_database["energy_cell"] = {
		"id": "energy_cell",
		"name": "Celda de Energía",
		"description": "Munición para armas de energía.",
		"type": ItemType.AMMUNITION,
		"weight": 0.2,
		"value": 5,
		"stackable": true,
		"max_stack": 30,
		"ammo_type": "energy_cell",
		"icon": "res://assets/sprites/items/energy_cell.png"
	}
	
	# Componentes
	item_database["scrap_metal"] = {
		"id": "scrap_metal",
		"name": "Metal de Chatarra",
		"description": "Fragmentos de metal útiles para fabricación.",
		"type": ItemType.COMPONENT,
		"weight": 0.5,
		"value": 5,
		"stackable": true,
		"max_stack": 50,
		"crafting_category": "metal",
		"icon": "res://assets/sprites/items/scrap_metal.png"
	}
	
	item_database["circuit_board"] = {
		"id": "circuit_board",
		"name": "Placa de Circuito",
		"description": "Componente electrónico para dispositivos avanzados.",
		"type": ItemType.COMPONENT,
		"weight": 0.3,
		"value": 15,
		"stackable": true,
		"max_stack": 20,
		"crafting_category": "electronics",
		"icon": "res://assets/sprites/items/circuit_board.png"
	}
	
	item_database["mutant_tissue"] = {
		"id": "mutant_tissue",
		"name": "Tejido Mutante",
		"description": "Tejido orgánico con propiedades extrañas.",
		"type": ItemType.COMPONENT,
		"weight": 0.2,
		"value": 20,
		"stackable": true,
		"max_stack": 15,
		"crafting_category": "biological",
		"icon": "res://assets/sprites/items/mutant_tissue.png"
	}
	
	# Objetos de misión
	item_database["memory_fragment"] = {
		"id": "memory_fragment",
		"name": "Fragmento de Memoria",
		"description": "Un fragmento de datos que contiene recuerdos perdidos.",
		"type": ItemType.QUEST,
		"weight": 0.0,
		"value": 0,
		"stackable": true,
		"max_stack": 10,
		"quest_id": "lost_memories",
		"icon": "res://assets/sprites/items/memory_fragment.png"
	}
	
	item_database["seed_core"] = {
		"id": "seed_core",
		"name": "Núcleo de La Semilla",
		"description": "Un fragmento del núcleo de La Semilla. Emite una energía extraña.",
		"type": ItemType.QUEST,
		"weight": 0.5,
		"value": 0,
		"stackable": false,
		"quest_id": "main_quest",
		"icon": "res://assets/sprites/items/seed_core.png"
	}
	
	# Planos
	item_database["blueprint_energy_rifle"] = {
		"id": "blueprint_energy_rifle",
		"name": "Plano: Rifle de Energía",
		"description": "Planos para fabricar un rifle de energía avanzado.",
		"type": ItemType.BLUEPRINT,
		"weight": 0.1,
		"value": 200,
		"stackable": false,
		"crafting_result": "energy_rifle",
		"crafting_requirements": [
			{"id": "circuit_board", "quantity": 3},
			{"id": "scrap_metal", "quantity": 10},
			{"id": "energy_cell", "quantity": 5}
		],
		"skill_requirements": {"technology": 3},
		"icon": "res://assets/sprites/items/blueprint_energy_rifle.png"
	}
	
	# Misceláneos
	item_database["old_coin"] = {
		"id": "old_coin",
		"name": "Moneda Antigua",
		"description": "Una moneda de antes del colapso. Usada como moneda de cambio.",
		"type": ItemType.MISCELLANEOUS,
		"weight": 0.01,
		"value": 1,
		"stackable": true,
		"max_stack": 999,
		"icon": "res://assets/sprites/items/old_coin.png"
	}
	
	item_database["strange_artifact"] = {
		"id": "strange_artifact",
		"name": "Artefacto Extraño",
		"description": "Un objeto de origen desconocido. Emite un débil resplandor.",
		"type": ItemType.MISCELLANEOUS,
		"weight": 0.5,
		"value": 100,
		"stackable": false,
		"icon": "res://assets/sprites/items/strange_artifact.png"
	}

# Añadir objetos iniciales para pruebas
func add_starting_items() -> void:
	# Añadir algunos objetos básicos al inicio del juego
	add_item("rusty_pipe", 1)
	add_item("medkit_small", 3)
	add_item("scrap_metal", 10)
	add_item("old_coin", 25)

# Añadir un objeto al inventario
func add_item(item_id: String, quantity: int = 1) -> bool:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		print("Error: Item ID '" + item_id + "' no encontrado en la base de datos.")
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si excede el peso máximo
	var new_weight = current_weight + (item_data["weight"] * quantity)
	if new_weight > max_weight:
		print("No se puede añadir el objeto. Excede el peso máximo.")
		return false
	
	# Si el objeto es apilable y ya existe en el inventario
	if item_data["stackable"] and inventory.has(item_id):
		# Verificar si excede la pila máxima
		var new_quantity = inventory[item_id]["quantity"] + quantity
		if new_quantity > item_data["max_stack"]:
			# Añadir lo que se pueda a la pila existente
			var can_add = item_data["max_stack"] - inventory[item_id]["quantity"]
			if can_add > 0:
				inventory[item_id]["quantity"] += can_add
				# Actualizar peso
				current_weight += item_data["weight"] * can_add
				# Emitir señales
				emit_signal("item_added", item_id, can_add)
				emit_signal("inventory_updated")
				emit_signal("weight_changed", current_weight, max_weight)
				# Intentar añadir el resto en una nueva pila
				return add_item(item_id, quantity - can_add)
			else:
				return false
		else:
			# Añadir a la pila existente
			inventory[item_id]["quantity"] = new_quantity
			# Actualizar peso
			current_weight = new_weight
			# Emitir señales
			emit_signal("item_added", item_id, quantity)
			emit_signal("inventory_updated")
			emit_signal("weight_changed", current_weight, max_weight)
			return true
	else:
		# Crear nueva entrada en el inventario
		var item_entry = {
			"id": item_id,
			"quantity": quantity
		}
		
		# Si no es apilable o no existe en el inventario
		if not item_data["stackable"]:
			# Generar un ID único para objetos no apilables
			var unique_id = item_id + "_" + str(randi())
			inventory[unique_id] = item_entry
		else:
			inventory[item_id] = item_entry
		
		# Actualizar peso
		current_weight = new_weight
		
		# Emitir señales
		emit_signal("item_added", item_id, quantity)
		emit_signal("inventory_updated")
		emit_signal("weight_changed", current_weight, max_weight)
		return true

# Eliminar un objeto del inventario
func remove_item(inventory_id: String, quantity: int = 1) -> bool:
	# Verificar si el objeto existe en el inventario
	if not inventory.has(inventory_id):
		print("Error: Item ID '" + inventory_id + "' no encontrado en el inventario.")
		return false
	
	# Obtener el ID real del objeto (sin el sufijo único)
	var item_id = inventory_id
	if "_" in inventory_id:
		item_id = inventory_id.split("_")[0]
	
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		print("Error: Item ID '" + item_id + "' no encontrado en la base de datos.")
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si hay suficiente cantidad
	if inventory[inventory_id]["quantity"] < quantity:
		print("Error: No hay suficiente cantidad del objeto para eliminar.")
		return false
	
	# Actualizar cantidad
	inventory[inventory_id]["quantity"] -= quantity
	
	# Actualizar peso
	current_weight -= item_data["weight"] * quantity
	
	# Si la cantidad llega a 0, eliminar la entrada
	if inventory[inventory_id]["quantity"] <= 0:
		inventory.erase(inventory_id)
	
	# Emitir señales
	emit_signal("item_removed", item_id, quantity)
	emit_signal("inventory_updated")
	emit_signal("weight_changed", current_weight, max_weight)
	return true

# Usar un objeto
func use_item(inventory_id: String) -> bool:
	# Verificar si el objeto existe en el inventario
	if not inventory.has(inventory_id):
		print("Error: Item ID '" + inventory_id + "' no encontrado en el inventario.")
		return false
	
	# Obtener el ID real del objeto (sin el sufijo único)
	var item_id = inventory_id
	if "_" in inventory_id:
		item_id = inventory_id.split("_")[0]
	
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		print("Error: Item ID '" + item_id + "' no encontrado en la base de datos.")
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si el objeto es usable (consumible)
	if item_data["type"] != ItemType.CONSUMABLE:
		print("Error: El objeto no es consumible.")
		return false
	
	# Emitir señal de uso
	emit_signal("item_used", item_id)
	
	# Aplicar efectos del objeto
	for effect in item_data["effects"]:
		apply_item_effect(effect)
	
	# Eliminar una unidad del objeto
	return remove_item(inventory_id, 1)

# Aplicar efecto de un objeto
func apply_item_effect(effect: Dictionary) -> void:
	# Obtener referencia al jugador
	var player = get_tree().get_nodes_in_group("player")[0]
	
	# Aplicar efecto según el tipo
	match effect["type"]:
		"heal":
			# Curar al jugador
			player.heal(effect["value"])
		"energy":
			# Restaurar energía
			player.modify_energy(effect["value"])
		"mutant_charge":
			# Aumentar carga mutante
			player.modify_mutant_charge(effect["value"])
		"remove_status":
			# Eliminar efecto de estado
			player.remove_status_effect(effect["status"])
		"radiation":
			# Modificar nivel de radiación
			player.modify_radiation(effect["value"])
		"buff":
			# Aplicar mejora temporal
			player.apply_buff(effect["buff_type"], effect["value"], effect["duration"])

# Equipar un objeto
func equip_item(inventory_id: String) -> bool:
	# Verificar si el objeto existe en el inventario
	if not inventory.has(inventory_id):
		print("Error: Item ID '" + inventory_id + "' no encontrado en el inventario.")
		return false
	
	# Obtener el ID real del objeto (sin el sufijo único)
	var item_id = inventory_id
	if "_" in inventory_id:
		item_id = inventory_id.split("_")[0]
	
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		print("Error: Item ID '" + item_id + "' no encontrado en la base de datos.")
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si el objeto es equipable
	if item_data["type"] != ItemType.WEAPON and item_data["type"] != ItemType.ARMOR:
		print("Error: El objeto no es equipable.")
		return false
	
	# Obtener slot de equipamiento
	var equip_slot = item_data["equip_slot"]
	
	# Desequipar objeto actual en ese slot si existe
	if equipped_items[equip_slot] != "":
		unequip_item(equip_slot)
	
	# Equipar nuevo objeto
	equipped_items[equip_slot] = inventory_id
	
	# Aplicar atributos del objeto equipado
	apply_equipped_item_attributes(item_data, true)
	
	# Emitir señal
	emit_signal("item_equipped", item_id, equip_slot)
	return true

# Desequipar un objeto
func unequip_item(equip_slot: int) -> bool:
	# Verificar si hay un objeto equipado en ese slot
	if equipped_items[equip_slot] == "":
		return false
	
	# Obtener ID del inventario
	var inventory_id = equipped_items[equip_slot]
	
	# Obtener el ID real del objeto (sin el sufijo único)
	var item_id = inventory_id
	if "_" in inventory_id:
		item_id = inventory_id.split("_")[0]
	
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		print("Error: Item ID '" + item_id + "' no encontrado en la base de datos.")
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Eliminar atributos del objeto equipado
	apply_equipped_item_attributes(item_data, false)
	
	# Desequipar objeto
	equipped_items[equip_slot] = ""
	
	# Emitir señal
	emit_signal("item_unequipped", item_id, equip_slot)
	return true

# Aplicar o eliminar atributos de un objeto equipado
func apply_equipped_item_attributes(item_data: Dictionary, apply: bool) -> void:
	# Obtener referencia al jugador
	var player = get_tree().get_nodes_in_group("player")[0]
	
	# Verificar si el objeto tiene atributos
	if item_data.has("attributes"):
		# Recorrer atributos
		for attribute in item_data["attributes"]:
			var value = item_data["attributes"][attribute]
			
			# Aplicar o eliminar según el parámetro
			if apply:
				# Aplicar atributo
				player.modify_attribute(attribute, value)
			else:
				# Eliminar atributo
				player.modify_attribute(attribute, -value)

# Modificar moneda
func modify_currency(amount: int) -> void:
	currency += amount
	
	# Asegurar que no sea negativo
	if currency < 0:
		currency = 0
	
	# Emitir señal
	emit_signal("currency_changed", currency)

# Obtener cantidad de un objeto
func get_item_quantity(item_id: String) -> int:
	var total_quantity = 0
	
	# Buscar en todas las entradas del inventario
	for inventory_id in inventory:
		# Verificar si es el objeto buscado
		if inventory_id == item_id or inventory_id.begins_with(item_id + "_"):
			total_quantity += inventory[inventory_id]["quantity"]
	
	return total_quantity

# Verificar si tiene suficiente cantidad de un objeto
func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_quantity(item_id) >= quantity

# Obtener objeto equipado en un slot
func get_equipped_item(slot: int) -> String:
	if equipped_items.has(slot) and equipped_items[slot] != "":
		var inventory_id = equipped_items[slot]
		
		# Obtener el ID real del objeto (sin el sufijo único)
		var item_id = inventory_id
		if "_" in inventory_id:
			item_id = inventory_id.split("_")[0]
		
		return item_id
	
	return ""

# Verificar si un objeto está equipado
func is_item_equipped(item_id: String) -> bool:
	# Buscar en todos los slots de equipamiento
	for slot in equipped_items:
		var equipped_id = get_equipped_item(slot)
		if equipped_id == item_id:
			return true
	
	return false

# Obtener datos de un objeto
func get_item_data(item_id: String) -> Dictionary:
	if item_database.has(item_id):
		return item_database[item_id]
	
	return {}

# Obtener peso actual
func get_current_weight() -> float:
	return current_weight

# Obtener peso máximo
func get_max_weight() -> float:
	return max_weight

# Modificar peso máximo
func modify_max_weight(amount: float) -> void:
	max_weight += amount
	
	# Emitir señal
	emit_signal("weight_changed", current_weight, max_weight)

# Obtener moneda actual
func get_currency() -> int:
	return currency

# Obtener lista de objetos en el inventario
func get_inventory_items() -> Array:
	var items = []
	
	# Recorrer inventario
	for inventory_id in inventory:
		# Obtener el ID real del objeto (sin el sufijo único)
		var item_id = inventory_id
		if "_" in inventory_id:
			item_id = inventory_id.split("_")[0]
		
		# Añadir a la lista
		items.append({
			"inventory_id": inventory_id,
			"item_id": item_id,
			"quantity": inventory[inventory_id]["quantity"],
			"data": item_database[item_id]
		})
	
	return items

# Verificar si el inventario está lleno (por peso)
func is_inventory_full() -> bool:
	return current_weight >= max_weight

# Verificar si puede añadir un objeto (por peso)
func can_add_item(item_id: String, quantity: int = 1) -> bool:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Calcular nuevo peso
	var new_weight = current_weight + (item_data["weight"] * quantity)
	
	# Verificar si excede el peso máximo
	return new_weight <= max_weight

# Ordenar inventario por tipo
func sort_inventory_by_type() -> void:
	# Crear una lista temporal con todos los objetos
	var all_items = []
	
	# Extraer todos los objetos del inventario
	for inventory_id in inventory:
		var item_id = inventory_id
		if "_" in inventory_id:
			item_id = inventory_id.split("_")[0]
		
		all_items.append({
			"inventory_id": inventory_id,
			"item_id": item_id,
			"quantity": inventory[inventory_id]["quantity"],
			"type": item_database[item_id]["type"]
		})
	
	# Limpiar inventario actual
	inventory.clear()
	current_weight = 0.0
	
	# Ordenar por tipo
	all_items.sort_custom(Callable(self, "_sort_by_type"))
	
	# Volver a añadir los objetos al inventario
	for item in all_items:
		add_item(item["item_id"], item["quantity"])
	
	# Emitir señal
	emit_signal("inventory_updated")

# Función de comparación para ordenar por tipo
func _sort_by_type(a, b) -> bool:
	return a["type"] < b["type"]

# Ordenar inventario por nombre
func sort_inventory_by_name() -> void:
	# Crear una lista temporal con todos los objetos
	var all_items = []
	
	# Extraer todos los objetos del inventario
	for inventory_id in inventory:
		var item_id = inventory_id
		if "_" in inventory_id:
			item_id = inventory_id.split("_")[0]
		
		all_items.append({
			"inventory_id": inventory_id,
			"item_id": item_id,
			"quantity": inventory[inventory_id]["quantity"],
			"name": item_database[item_id]["name"]
		})
	
	# Limpiar inventario actual
	inventory.clear()
	current_weight = 0.0
	
	# Ordenar por nombre
	all_items.sort_custom(Callable(self, "_sort_by_name"))
	
	# Volver a añadir los objetos al inventario
	for item in all_items:
		add_item(item["item_id"], item["quantity"])
	
	# Emitir señal
	emit_signal("inventory_updated")

# Función de comparación para ordenar por nombre
func _sort_by_name(a, b) -> bool:
	return a["name"] < b["name"]

# Verificar si un objeto es usable
func is_item_usable(item_id: String) -> bool:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si es consumible
	return item_data["type"] == ItemType.CONSUMABLE

# Verificar si un objeto es equipable
func is_item_equippable(item_id: String) -> bool:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si es arma o armadura
	return item_data["type"] == ItemType.WEAPON or item_data["type"] == ItemType.ARMOR

# Obtener slot de equipamiento de un objeto
func get_item_equip_slot(item_id: String) -> int:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		return -1
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si es equipable
	if item_data["type"] == ItemType.WEAPON or item_data["type"] == ItemType.ARMOR:
		return item_data["equip_slot"]
	
	return -1

# Verificar si un objeto es un plano
func is_item_blueprint(item_id: String) -> bool:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(item_id):
		return false
	
	# Obtener datos del objeto
	var item_data = item_database[item_id]
	
	# Verificar si es un plano
	return item_data["type"] == ItemType.BLUEPRINT

# Verificar si se pueden cumplir los requisitos de un plano
func can_craft_from_blueprint(blueprint_id: String) -> bool:
	# Verificar si el objeto existe en la base de datos
	if not item_database.has(blueprint_id):
		return false
	
	# Obtener datos del objeto
	var blueprint_data = item_database[blueprint_id]
	
	# Verificar si es un plano
	if blueprint_data["type"] != ItemType.BLUEPRINT:
		return false
	
	# Verificar requisitos de habilidad
	if blueprint_data.has("skill_requirements"):
		var player = get_tree().get_nodes_in_group("player")[0]
		
		for skill in blueprint_data["skill_requirements"]:
			var required_level = blueprint_data["skill_requirements"][skill]
			var player_level = player.get_skill_level(skill)
			
			if player_level < required_level:
				return false
	
	# Verificar requisitos de materiales
	for requirement in blueprint_data["crafting_requirements"]:
		var required_id = requirement["id"]
		var required_quantity = requirement["quantity"]
		
		if not has_item(required_id, required_quantity):
			return false
	
	return true

# Fabricar objeto a partir de un plano
func craft_from_blueprint(blueprint_id: String) -> bool:
	# Verificar si se pueden cumplir los requisitos
	if not can_craft_from_blueprint(blueprint_id):
		return false
	
	# Obtener datos del plano
	var blueprint_data = item_database[blueprint_id]
	
	# Consumir materiales
	for requirement in blueprint_data["crafting_requirements"]:
		var required_id = requirement["id"]
		var required_quantity = requirement["quantity"]
		
		# Buscar y eliminar la cantidad requerida
		var remaining = required_quantity
		
		# Buscar en todas las entradas del inventario
		for inventory_id in inventory.duplicate():
			# Verificar si es el objeto requerido
			if inventory_id == required_id or inventory_id.begins_with(required_id + "_"):
				# Calcular cuánto se puede eliminar de esta entrada
				var to_remove = min(remaining, inventory[inventory_id]["quantity"])
				
				# Eliminar la cantidad
				remove_item(inventory_id, to_remove)
				
				# Actualizar cantidad restante
				remaining -= to_remove
				
				# Salir si ya se eliminó todo lo necesario
				if remaining <= 0:
					break
	
	# Añadir objeto fabricado
	var crafted_item_id = blueprint_data["crafting_result"]
	add_item(crafted_item_id, 1)
	
	return true

# Guardar datos del inventario
func save_inventory_data() -> Dictionary:
	return {
		"inventory": inventory,
		"equipped_items": equipped_items,
		"currency": currency,
		"max_weight": max_weight,
		"current_weight": current_weight
	}

# Cargar datos del inventario
func load_inventory_data(data: Dictionary) -> void:
	# Limpiar inventario actual
	inventory.clear()
	
	# Cargar datos
	inventory = data["inventory"]
	equipped_items = data["equipped_items"]
	currency = data["currency"]
	max_weight = data["max_weight"]
	current_weight = data["current_weight"]
	
	# Emitir señales
	emit_signal("inventory_updated")
	emit_signal("currency_changed", currency)
	emit_signal("weight_changed", current_weight, max_weight)