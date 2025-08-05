extends Node

# FactionData.gd - Centraliza los datos de las facciones del juego "Cenizas del Horizonte"
# Contiene información sobre todas las facciones, sus líderes, territorios, ideologías y relaciones

# Función para inicializar y registrar todas las facciones en el FactionManager
func register_all_factions() -> void:
	# Obtener referencia al gestor de facciones
	var faction_manager = get_node("/root/FactionManager")
	
	# Registrar facciones principales
	register_main_factions(faction_manager)
	
	# Registrar facciones menores
	register_minor_factions(faction_manager)
	
	# Registrar relaciones iniciales entre facciones
	register_faction_relationships(faction_manager)

# Registrar las facciones principales del juego
func register_main_factions(faction_manager) -> void:
	# La Hegemonía
	faction_manager.register_faction({
		"id": "hegemonia",
		"name": "La Hegemonía",
		"description": "Antigua fuerza militar que busca restaurar el orden mediante control estricto. Creen que la humanidad necesita ser gobernada con mano firme para evitar otro cataclismo.",
		"leader": "Comandante Voss",
		"headquarters": "Fortaleza Adamant (Sector Helios-07)",
		"ideology": "Orden, control, restauración de la civilización bajo un mando centralizado.",
		"discovered": false,
		"reputation": 0,
		"color": Color(0.7, 0.1, 0.1, 1.0), # Rojo oscuro
		"icon": "res://assets/icons/factions/hegemonia_icon.png",
		"territories": ["sector_helios_07", "fortaleza_adamant", "puesto_avanzado_norte"],
		"enemies": ["nihil", "errantes"],
		"allies": [],
		"quests": ["orden_y_progreso", "purga_tecnologica", "reclutamiento_forzoso"]
	})
	
	# Los Errantes
	faction_manager.register_faction({
		"id": "errantes",
		"name": "Los Errantes",
		"description": "Nómadas del desierto que han aprendido a adaptarse al nuevo mundo. Creen en la evolución y adaptación de la humanidad en lugar de intentar restaurar el pasado.",
		"leader": "Sira",
		"headquarters": "Campamento Móvil (Desierto Carmesí)",
		"ideology": "Adaptación, libertad, supervivencia a través del cambio constante.",
		"discovered": true, # Conocidos desde el principio
		"reputation": 10, # Ligeramente positiva al inicio
		"color": Color(0.9, 0.7, 0.2, 1.0), # Ámbar
		"icon": "res://assets/icons/factions/errantes_icon.png",
		"territories": ["desierto_carmesi", "oasis_susurros", "rutas_comerciales"],
		"enemies": ["hegemonia"],
		"allies": [],
		"quests": ["nomadas_desierto", "caravana_perdida", "secretos_arena"]
	})
	
	# Los Restauradores
	faction_manager.register_faction({
		"id": "restauradores",
		"name": "Los Restauradores",
		"description": "Científicos y técnicos que buscan recuperar la tecnología perdida para reconstruir la civilización tal como era antes del colapso.",
		"leader": "Directora Elara",
		"headquarters": "Archivo Central (Ruinas de Drossal)",
		"ideology": "Preservación del conocimiento, restauración tecnológica, progreso científico.",
		"discovered": false,
		"reputation": 0,
		"color": Color(0.2, 0.6, 0.9, 1.0), # Azul
		"icon": "res://assets/icons/factions/restauradores_icon.png",
		"territories": ["archivo_central", "laboratorio_alfa", "torre_transmision"],
		"enemies": ["nihil"],
		"allies": [],
		"quests": ["datos_perdidos", "energia_estable", "prototipo_alfa"]
	})
	
	# Los Nihil
	faction_manager.register_faction({
		"id": "nihil",
		"name": "Los Nihil",
		"description": "Culto que venera el vacío y cree que la humanidad debe ser borrada para que el mundo sane. Buscan usar La Semilla para acabar con toda vida consciente.",
		"leader": "El Oráculo",
		"headquarters": "El Cráter (Oculto)",
		"ideology": "Extinción como salvación, purificación a través del vacío, fin de la consciencia.",
		"discovered": false,
		"reputation": -25, # Negativa al inicio
		"color": Color(0.4, 0.1, 0.6, 1.0), # Púrpura
		"icon": "res://assets/icons/factions/nihil_icon.png",
		"territories": ["el_crater", "templo_vacio", "cavernas_eco"],
		"enemies": ["hegemonia", "restauradores"],
		"allies": [],
		"quests": ["llamada_vacio", "sacrificio_final", "semilla_oscura"]
	})
	
	# Hijos del Átomo
	faction_manager.register_faction({
		"id": "hijos_atomo",
		"name": "Hijos del Átomo",
		"description": "Culto que venera la radiación y las mutaciones como el siguiente paso evolutivo. Habitan en el Bosque Putrefacto bajo el liderazgo de Greta la Ciega.",
		"leader": "Greta la Ciega",
		"headquarters": "Templo de la Mutación (Bosque Putrefacto)",
		"ideology": "Evolución forzada, mutación como divinidad, trascendencia física.",
		"discovered": false,
		"reputation": 0,
		"color": Color(0.5, 0.8, 0.3, 1.0), # Verde tóxico
		"icon": "res://assets/icons/factions/hijos_atomo_icon.png",
		"territories": ["bosque_putrefacto", "templo_mutacion", "lago_radiactivo"],
		"enemies": [],
		"allies": [],
		"quests": ["comunion_radiante", "evolucion_forzada", "vision_interior"]
	})

# Registrar facciones menores
func register_minor_factions(faction_manager) -> void:
	# Supervivientes de Drossal
	faction_manager.register_faction({
		"id": "drossal_survivors",
		"name": "Supervivientes de Drossal",
		"description": "Habitantes de las ruinas que luchan por sobrevivir día a día. No tienen grandes ambiciones más allá de proteger a los suyos.",
		"leader": "Consejo de Ancianos",
		"headquarters": "Mercado de las Ruinas (Drossal)",
		"ideology": "Supervivencia comunitaria, ayuda mutua, pragmatismo.",
		"discovered": true, # Conocidos desde el principio
		"reputation": 10, # Ligeramente positiva al inicio
		"color": Color(0.5, 0.5, 0.5, 1.0), # Gris
		"icon": "res://assets/icons/factions/drossal_icon.png",
		"territories": ["ruinas_drossal", "mercado_ruinas", "refugio_este"],
		"enemies": [],
		"allies": [],
		"quests": ["agua_limpia", "medicinas_escasas", "defensa_comunal"]
	})
	
	# Saqueadores de Chatarra
	faction_manager.register_faction({
		"id": "scrap_raiders",
		"name": "Saqueadores de Chatarra",
		"description": "Bandas de supervivientes que saquean las ruinas en busca de tecnología y recursos. Violentos pero organizados bajo el liderazgo de Raak.",
		"leader": "Raak",
		"headquarters": "Fortaleza de Hierro (Ruinas de Drossal)",
		"ideology": "Supervivencia del más fuerte, tomar lo que necesitas por la fuerza.",
		"discovered": true, # Conocidos desde el principio
		"reputation": -20, # Negativa al inicio
		"color": Color(0.8, 0.2, 0.2, 1.0), # Rojo
		"icon": "res://assets/icons/factions/scrap_raiders_icon.png",
		"territories": ["fortaleza_hierro", "zona_chatarra", "minas_abandonadas"],
		"enemies": ["drossal_survivors"],
		"allies": [],
		"quests": ["tributo_forzoso", "armamento_superior", "dominio_ruinas"]
	})
	
	# Colectivo Tecnológico
	faction_manager.register_faction({
		"id": "tech_collective",
		"name": "Colectivo Tecnológico",
		"description": "Científicos e ingenieros que buscan preservar y desarrollar tecnología. Habitan en el Sector Helios-07 bajo el liderazgo de Kovak el Hacedor.",
		"leader": "Kovak el Hacedor",
		"headquarters": "Cúpula de Helios (Sector Helios-07)",
		"ideology": "Progreso tecnológico, conocimiento compartido, innovación constante.",
		"discovered": false,
		"reputation": 0,
		"color": Color(0.2, 0.6, 0.8, 1.0), # Azul claro
		"icon": "res://assets/icons/factions/tech_collective_icon.png",
		"territories": ["cupula_helios", "talleres_kovak", "centro_investigacion"],
		"enemies": [],
		"allies": [],
		"quests": ["componentes_raros", "energia_perpetua", "inteligencia_artificial"]
	})

# Registrar relaciones iniciales entre facciones
func register_faction_relationships(faction_manager) -> void:
	# Relaciones de La Hegemonía
	faction_manager.set_faction_relationship("hegemonia", "errantes", -60) # Hostiles
	faction_manager.set_faction_relationship("hegemonia", "restauradores", 30) # Amistosos
	faction_manager.set_faction_relationship("hegemonia", "nihil", -90) # Enemigos mortales
	faction_manager.set_faction_relationship("hegemonia", "hijos_atomo", -40) # Desconfiados
	faction_manager.set_faction_relationship("hegemonia", "drossal_survivors", -20) # Ligeramente hostiles
	faction_manager.set_faction_relationship("hegemonia", "scrap_raiders", -50) # Hostiles
	faction_manager.set_faction_relationship("hegemonia", "tech_collective", 20) # Ligeramente amistosos
	
	# Relaciones de Los Errantes
	faction_manager.set_faction_relationship("errantes", "restauradores", 20) # Ligeramente amistosos
	faction_manager.set_faction_relationship("errantes", "nihil", -70) # Muy hostiles
	faction_manager.set_faction_relationship("errantes", "hijos_atomo", -10) # Ligeramente desconfiados
	faction_manager.set_faction_relationship("errantes", "drossal_survivors", 50) # Amistosos
	faction_manager.set_faction_relationship("errantes", "scrap_raiders", -30) # Desconfiados
	faction_manager.set_faction_relationship("errantes", "tech_collective", 40) # Amistosos
	
	# Relaciones de Los Restauradores
	faction_manager.set_faction_relationship("restauradores", "nihil", -80) # Muy hostiles
	faction_manager.set_faction_relationship("restauradores", "hijos_atomo", -30) # Desconfiados
	faction_manager.set_faction_relationship("restauradores", "drossal_survivors", 40) # Amistosos
	faction_manager.set_faction_relationship("restauradores", "scrap_raiders", -60) # Hostiles
	faction_manager.set_faction_relationship("restauradores", "tech_collective", 70) # Muy amistosos
	
	# Relaciones de Los Nihil
	faction_manager.set_faction_relationship("nihil", "hijos_atomo", 20) # Ligeramente amistosos
	faction_manager.set_faction_relationship("nihil", "drossal_survivors", -60) # Hostiles
	faction_manager.set_faction_relationship("nihil", "scrap_raiders", -20) # Ligeramente hostiles
	faction_manager.set_faction_relationship("nihil", "tech_collective", -70) # Muy hostiles
	
	# Relaciones de Hijos del Átomo
	faction_manager.set_faction_relationship("hijos_atomo", "drossal_survivors", -40) # Desconfiados
	faction_manager.set_faction_relationship("hijos_atomo", "scrap_raiders", -30) # Desconfiados
	faction_manager.set_faction_relationship("hijos_atomo", "tech_collective", -10) # Ligeramente desconfiados
	
	# Relaciones de Supervivientes de Drossal
	faction_manager.set_faction_relationship("drossal_survivors", "scrap_raiders", -70) # Muy hostiles
	faction_manager.set_faction_relationship("drossal_survivors", "tech_collective", 30) # Amistosos
	
	# Relaciones de Saqueadores de Chatarra
	faction_manager.set_faction_relationship("scrap_raiders", "tech_collective", -40) # Desconfiados

# Cargar datos de misiones de facciones
func load_faction_quests() -> Dictionary:
	var faction_quests = {}
	
	# Misiones de La Hegemonía
	faction_quests["orden_y_progreso"] = {
		"id": "orden_y_progreso",
		"title": "Orden y Progreso",
		"description": "El Comandante Voss busca establecer un puesto de control en las ruinas para extender la influencia de La Hegemonía.",
		"giver": "comandante_voss",
		"faction": "hegemonia",
		"type": 2, # Facción
		"level_required": 5,
		"reputation_required": 0,
		"objectives": [
			{"type": "clear_area", "target": "ruinas_este", "amount": 1, "completed": false},
			{"type": "collect", "target": "componentes_comunicacion", "amount": 5, "completed": false},
			{"type": "talk", "target": "teniente_mira", "amount": 1, "completed": false}
		],
		"rewards": {
			"experience": 500,
			"items": [{"id": "rifle_hegemonico", "amount": 1}],
			"reputation": {"hegemonia": 20, "drossal_survivors": -10},
			"currency": 200
		},
		"next_quest": "purga_tecnologica"
	}
	
	# Misiones de Los Errantes
	faction_quests["nomadas_desierto"] = {
		"id": "nomadas_desierto",
		"title": "Nómadas del Desierto",
		"description": "Sira necesita ayuda para encontrar una caravana perdida en el Desierto Carmesí durante una tormenta de arena.",
		"giver": "sira",
		"faction": "errantes",
		"type": 2, # Facción
		"level_required": 3,
		"reputation_required": 0,
		"objectives": [
			{"type": "explore", "target": "ruta_caravanas", "amount": 1, "completed": false},
			{"type": "find", "target": "caravana_perdida", "amount": 1, "completed": false},
			{"type": "escort", "target": "supervivientes", "amount": 1, "completed": false}
		],
		"rewards": {
			"experience": 350,
			"items": [{"id": "mapa_desierto", "amount": 1}, {"id": "cantimplora_errante", "amount": 1}],
			"reputation": {"errantes": 15},
			"currency": 150
		},
		"next_quest": "secretos_arena"
	}
	
	return faction_quests