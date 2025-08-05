extends Node

# QuestData.gd - Biblioteca de misiones para "Cenizas del Horizonte"
# Este script contiene todas las definiciones de misiones del juego
# y proporciona métodos para cargarlas en el QuestManager

# Referencia al QuestManager
onready var quest_manager = get_node("/root/GameManager/QuestManager")

# Enumeraciones importadas del QuestManager
onready var QuestStatus = quest_manager.QuestStatus
onready var QuestType = quest_manager.QuestType

# Función de inicialización
func _ready() -> void:
	# Esperar un frame para asegurarse de que QuestManager esté listo
	yield(get_tree(), "idle_frame")
	# Cargar todas las misiones en el QuestManager
	load_all_quests()

# Cargar todas las misiones en el QuestManager
func load_all_quests() -> void:
	# Misiones principales
	load_main_quests()
	
	# Misiones por zona
	load_drossal_quests()
	load_desierto_carmesi_quests()
	load_bosque_putrefacto_quests()
	load_sector_helios_quests()
	load_crater_quests()
	
	# Misiones de facción
	load_hegemonia_quests()
	load_errantes_quests()
	load_restauradores_quests()
	load_nihil_quests()
	
	# Misiones de caza de jefes
	load_boss_quests()

# Cargar misiones principales
func load_main_quests() -> void:
	# Misión 1: Despertar
	var awakening = {
		"id": "main_awakening",
		"title": "Despertar en la oscuridad",
		"description": "Has despertado en una instalación abandonada sin recuerdos. Descubre quién eres y qué te ha sucedido.",
		"type": QuestType.MAIN,
		"giver": "auto",
		"location": "Complejo Génesis",
		"level_requirement": 1,
		"prerequisites": [],
		"objectives": [
			{
				"id": "explore_facility",
				"description": "Explora la instalación",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "find_exit",
				"description": "Encuentra una salida",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "reach_drossal",
				"description": "Llega a las Ruinas de Drossal",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 100,
			"items": [
				{"id": "old_journal", "quantity": 1}
			],
			"skills": [],
			"reputation": [],
			"story_flags": [
				{"flag": "prologue_completed", "value": true}
			]
		},
		"next_quest": "main_the_mark",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Misión 2: La Marca
	var the_mark = {
		"id": "main_the_mark",
		"title": "La Marca",
		"description": "La extraña marca en tu piel parece ser un fragmento de algo llamado 'La Semilla'. Descubre su significado y por qué te eligió.",
		"type": QuestType.MAIN,
		"giver": "Greta la Ciega",
		"location": "Ruinas de Drossal",
		"level_requirement": 2,
		"prerequisites": ["main_awakening"],
		"objectives": [
			{
				"id": "meet_factions",
				"description": "Conoce a representantes de las principales facciones",
				"target_amount": 2,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "find_seed_info",
				"description": "Busca información sobre La Semilla",
				"target_amount": 3,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "activate_mark",
				"description": "Aprende a activar el poder de la marca",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 200,
			"items": [],
			"skills": [
				{"branch": "mutation", "id": "mutant_reaction_basic"}
			],
			"reputation": [],
			"story_flags": [
				{"flag": "knows_seed_purpose", "value": true}
			]
		},
		"next_quest": "main_desert_journey",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Misión 3: Viaje por el Desierto
	var desert_journey = {
		"id": "main_desert_journey",
		"title": "A través del Desierto Carmesí",
		"description": "Debes atravesar el peligroso Desierto Carmesí para llegar al Bosque Putrefacto, donde se rumorea que existe un fragmento mayor de La Semilla.",
		"type": QuestType.MAIN,
		"giver": "Sira",
		"location": "Desierto Carmesí",
		"level_requirement": 4,
		"prerequisites": ["main_the_mark"],
		"objectives": [
			{
				"id": "survive_storm",
				"description": "Sobrevive a una tormenta del desierto",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "find_oasis",
				"description": "Encuentra el Oasis Escondido",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "reach_forest",
				"description": "Llega al borde del Bosque Putrefacto",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 300,
			"items": [
				{"id": "desert_survivor_cloak", "quantity": 1}
			],
			"skills": [],
			"reputation": [
				{"faction": "errantes", "value": 20}
			],
			"story_flags": [
				{"flag": "desert_crossed", "value": true}
			]
		},
		"next_quest": "main_forest_fragment",
		"failure_conditions": [
			{"type": "item_missing", "item_id": "water_canteen"}
		],
		"time_limit": 0
	}
	
	# Misión 4: El Fragmento del Bosque
	var forest_fragment = {
		"id": "main_forest_fragment",
		"title": "Ecos del Bosque",
		"description": "El Bosque Putrefacto oculta un fragmento importante de La Semilla. Encuéntralo antes que las otras facciones y descubre sus secretos.",
		"type": QuestType.MAIN,
		"giver": "auto",
		"location": "Bosque Putrefacto",
		"level_requirement": 6,
		"prerequisites": ["main_desert_journey"],
		"objectives": [
			{
				"id": "navigate_forest",
				"description": "Navega a través del Bosque Putrefacto",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "defeat_guardians",
				"description": "Derrota a los guardianes fúngicos",
				"target_amount": 3,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "retrieve_fragment",
				"description": "Recupera el fragmento de La Semilla",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "escape_forest",
				"description": "Escapa del bosque con el fragmento",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 400,
			"items": [
				{"id": "seed_fragment_forest", "quantity": 1},
				{"id": "fungal_remedy", "quantity": 3}
			],
			"skills": [
				{"branch": "mutation", "id": "spore_resistance"}
			],
			"reputation": [],
			"story_flags": [
				{"flag": "forest_fragment_obtained", "value": true}
			]
		},
		"next_quest": "main_helios_secrets",
		"failure_conditions": [
			{"type": "player_infected", "infection_type": "fungal"}
		],
		"time_limit": 0
	}
	
	# Registrar misiones en el QuestManager
	register_quest(awakening)
	register_quest(the_mark)
	register_quest(desert_journey)
	register_quest(forest_fragment)

# Cargar misiones de las Ruinas de Drossal
func load_drossal_quests() -> void:
	# Misión secundaria - Memorias perdidas
	var lost_memories = {
		"id": "drossal_lost_memories",
		"title": "Memorias perdidas",
		"description": "Un anciano en las ruinas de Drossal busca objetos personales que quedaron dispersos durante la evacuación de la ciudad.",
		"type": QuestType.SIDE,
		"giver": "Anciano Morten",
		"location": "Ruinas de Drossal",
		"level_requirement": 1,
		"prerequisites": [],
		"objectives": [
			{
				"id": "find_locket",
				"description": "Encuentra el medallón familiar",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "find_diary",
				"description": "Recupera el diario personal",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "find_music_box",
				"description": "Localiza la caja de música",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 100,
			"items": [
				{"id": "old_key", "quantity": 1}
			],
			"skills": [],
			"reputation": [
				{"faction": "drossal_survivors", "value": 15}
			],
			"story_flags": [
				{"flag": "helped_morten", "value": true}
			]
		},
		"next_quest": "",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Misión secundaria - Agua contaminada
	var tainted_water = {
		"id": "drossal_tainted_water",
		"title": "Agua contaminada",
		"description": "El suministro de agua de los supervivientes de Drossal ha sido contaminado. Descubre la fuente y purifica el agua.",
		"type": QuestType.SIDE,
		"giver": "Médico Elara",
		"location": "Ruinas de Drossal",
		"level_requirement": 2,
		"prerequisites": [],
		"objectives": [
			{
				"id": "investigate_source",
				"description": "Investiga la fuente de agua",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "find_contaminant",
				"description": "Identifica el contaminante",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "purify_water",
				"description": "Purifica el suministro de agua",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 150,
			"items": [
				{"id": "purification_tablets", "quantity": 5}
			],
			"skills": [],
			"reputation": [
				{"faction": "drossal_survivors", "value": 20}
			],
			"story_flags": [
				{"flag": "water_purified", "value": true}
			]
		},
		"next_quest": "",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Registrar misiones en el QuestManager
	register_quest(lost_memories)
	register_quest(tainted_water)

# Cargar misiones del Desierto Carmesí
func load_desierto_carmesi_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones del Bosque Putrefacto
func load_bosque_putrefacto_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones del Sector Helios-07
func load_sector_helios_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones de El Cráter
func load_crater_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones de la Hegemonía
func load_hegemonia_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones de los Errantes
func load_errantes_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones de los Restauradores
func load_restauradores_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones de los Nihil
func load_nihil_quests() -> void:
	# Implementar según sea necesario
	pass

# Cargar misiones de caza de jefes
func load_boss_quests() -> void:
	# Misión de caza de jefe - Raak
	var hunt_raak = {
		"id": "hunt_raak",
		"title": "El Devorador del Bosque",
		"description": "Una criatura monstruosa conocida como Raak está aterrorizando a los exploradores en el Bosque Putrefacto. Los Restauradores han puesto precio a su cabeza.",
		"type": QuestType.BOSS_HUNT,
		"giver": "Tablón de Misiones de los Restauradores",
		"location": "Bosque Putrefacto",
		"level_requirement": 5,
		"prerequisites": [],
		"objectives": [
			{
				"id": "find_raak_lair",
				"description": "Localiza la guarida de Raak siguiendo los rastros de destrucción",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "collect_samples",
				"description": "Recoge muestras de la sustancia tóxica que Raak secreta",
				"target_amount": 3,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "defeat_raak",
				"description": "Derrota a Raak, el Devorador",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			},
			{
				"id": "return_proof",
				"description": "Regresa con prueba de la muerte de Raak",
				"target_amount": 1,
				"current_amount": 0,
				"completed": false
			}
		],
		"rewards": {
			"experience": 500,
			"items": [
				{"id": "raak_toxin_vial", "quantity": 1},
				{"id": "technofragments", "quantity": 50}
			],
			"skills": [
				{"branch": "mutation", "id": "toxic_adaptation"}
			],
			"reputation": [
				{"faction": "restauradores", "value": 20}
			],
			"story_flags": [
				{"flag": "raak_defeated", "value": true}
			]
		},
		"next_quest": "",
		"failure_conditions": [],
		"time_limit": 0
	}
	
	# Registrar misiones en el QuestManager
	register_quest(hunt_raak)

# Función auxiliar para registrar una misión en el QuestManager
func register_quest(quest_data: Dictionary) -> void:
	# Verificar si la misión ya existe en el QuestManager
	if not quest_manager.quest_library.has(quest_data["id"]):
		# Añadir la misión a la biblioteca del QuestManager
		quest_manager.quest_library[quest_data["id"]] = quest_data
		print("Misión registrada: " + quest_data["id"])
	else:
		print("La misión ya existe: " + quest_data["id"])