extends Node

# Este script contiene los datos de diálogo para el juego "Cenizas del Horizonte"
# Almacena diálogos predefinidos y proporciona métodos para cargarlos y manipularlos

# Estructura para almacenar todos los diálogos del juego
var dialogue_library = {}

# Función de inicialización
func _ready() -> void:
	# Cargar todos los diálogos predefinidos
	load_all_dialogues()

# Función para cargar todos los diálogos
func load_all_dialogues() -> void:
	# Cargar diálogos de personajes principales
	load_kaelen_dialogues()
	load_sira_dialogues()
	load_greta_dialogues()
	load_kovak_dialogues()
	load_ghost_child_dialogues()
	
	# Cargar diálogos de facciones
	load_hegemonia_dialogues()
	load_errantes_dialogues()
	load_restauradores_dialogues()
	load_nihil_dialogues()
	
	# Cargar diálogos de misiones principales
	load_main_quest_dialogues()
	
	# Cargar diálogos de zonas específicas
	load_drossal_dialogues()
	load_desierto_carmesi_dialogues()
	load_bosque_putrefacto_dialogues()
	load_sector_helios_dialogues()
	load_crater_dialogues()

# Obtener un diálogo específico por su ID
func get_dialogue(dialogue_id: String) -> Dictionary:
	if dialogue_library.has(dialogue_id):
		return dialogue_library[dialogue_id].duplicate(true)
	else:
		push_error("Diálogo no encontrado: " + dialogue_id)
		return {}

# Crear un nuevo diálogo dinámicamente
func create_dialogue(dialogue_data: Dictionary) -> String:
	# Generar un ID único
	var dialogue_id = "dynamic_" + str(Time.get_unix_time_from_system())
	
	# Asegurarse de que el diálogo tenga un ID
	dialogue_data["id"] = dialogue_id
	
	# Añadir a la biblioteca
	dialogue_library[dialogue_id] = dialogue_data
	
	return dialogue_id

# Guardar los diálogos modificados (para persistencia)
func save_dialogues() -> void:
	# Implementar guardado en archivo si es necesario
	pass

# Cargar diálogos de Kaelen (Soldado Exiliado)
func load_kaelen_dialogues() -> void:
	# Primer encuentro con Kaelen
	dialogue_library["kaelen_first_meeting"] = {
		"id": "kaelen_first_meeting",
		"npc_name": "Kaelen",
		"portrait": "res://assets/sprites/portraits/kaelen.png",
		"entries": [
			{
				"text": "Alto ahí. No des un paso más si valoras tu vida.",
				"speaker": "npc",
				"emotion": "hostile",
				"choices": [
					{
						"text": "No busco problemas, solo estoy explorando.",
						"next_entry": 1
					},
					{
						"text": "¿Quién eres tú para darme órdenes?",
						"next_entry": 2
					},
					{
						"text": "[Preparar arma] Retrocede o lo lamentarás.",
						"next_entry": 3,
						"conditions": {"has_weapon": true}
					}
				]
			},
			{
				"text": "Hmm... Explorando, ¿eh? Nadie 'explora' estas ruinas a menos que busque algo valioso... o peligroso.",
				"speaker": "npc",
				"emotion": "suspicious",
				"next_entry": 4
			},
			{
				"text": "Alguien que ha visto demasiados como tú venir y no regresar. Este lugar está prohibido por una razón.",
				"speaker": "npc",
				"emotion": "angry",
				"next_entry": 4
			},
			{
				"text": "[Baja su arma lentamente] Interesante... La mayoría huye o suplica. Tienes agallas, lo reconozco.",
				"speaker": "npc",
				"emotion": "impressed",
				"actions": [{"type": "change_reputation", "faction": "hegemonia", "value": 5}],
				"next_entry": 4
			},
			{
				"text": "Soy Kaelen, ex-comandante de la Hegemonía. Ahora solo un vigilante de estas ruinas. Y tú... tienes la marca, ¿verdad?",
				"speaker": "npc",
				"emotion": "neutral",
				"actions": [{"type": "set_flag", "flag": "met_kaelen", "value": true}],
				"choices": [
					{
						"text": "¿Qué sabes sobre esta marca?",
						"next_entry": 5
					},
					{
						"text": "¿Por qué dejaste la Hegemonía?",
						"next_entry": 6
					},
					{
						"text": "No tengo tiempo para charlas. Necesito seguir adelante.",
						"next_entry": "end"
					}
				]
			},
			{
				"text": "Es un fragmento de La Semilla. Una tecnología antigua, poderosa... y maldita. Cambia a quienes la portan, les da poder pero también... propósito. Un propósito que no siempre es suyo.",
				"speaker": "npc",
				"emotion": "concerned",
				"next_entry": 7
			},
			{
				"text": "[Su mirada se endurece] Digamos que vi el verdadero rostro de mis superiores. Lo que planean hacer con La Semilla... no puedo ser parte de eso.",
				"speaker": "npc",
				"emotion": "bitter",
				"next_entry": 7
			},
			{
				"text": "Escucha, no sé qué te trajo aquí o qué planeas hacer, pero te daré un consejo: ten cuidado con las facciones. Todas quieren usar tu poder para sus propios fines.",
				"speaker": "npc",
				"emotion": "serious",
				"choices": [
					{
						"text": "¿Puedes ayudarme a entender este poder?",
						"next_entry": 8
					},
					{
						"text": "¿Qué me recomiendas hacer?",
						"next_entry": 9
					},
					{
						"text": "Gracias por la advertencia. Debo irme ahora.",
						"next_entry": "end",
						"actions": [{"type": "set_flag", "flag": "kaelen_alliance_potential", "value": true}]
					}
				]
			},
			{
				"text": "Puedo enseñarte algunas técnicas de combate que aprendí en la Hegemonía. Te servirán para defenderte. A cambio, solo te pido que consideres cuidadosamente tus alianzas futuras.",
				"speaker": "npc",
				"emotion": "helpful",
				"actions": [
					{"type": "set_flag", "flag": "kaelen_training_available", "value": true},
					{"type": "add_quest", "quest_id": "kaelen_combat_training"}
				],
				"next_entry": "end"
			},
			{
				"text": "Busca tu propio camino. No dejes que La Semilla o las facciones te controlen. Y si necesitas un aliado... bueno, estaré por aquí. Quizás podamos ayudarnos mutuamente.",
				"speaker": "npc",
				"emotion": "friendly",
				"actions": [
					{"type": "set_flag", "flag": "kaelen_alliance_offered", "value": true},
					{"type": "change_reputation", "faction": "hegemonia", "value": 10}
				],
				"next_entry": "end"
			}
		]
	}
	
	# Diálogo de entrenamiento con Kaelen
	dialogue_library["kaelen_training"] = {
		"id": "kaelen_training",
		"npc_name": "Kaelen",
		"portrait": "res://assets/sprites/portraits/kaelen.png",
		"entries": [
			{
				"text": "Así que has decidido aceptar mi oferta de entrenamiento. Bien. Empecemos con lo básico.",
				"speaker": "npc",
				"emotion": "neutral",
				"next_entry": 1
			},
			{
				"text": "En combate, la posición lo es todo. Mantén siempre una postura que te permita atacar o defenderte rápidamente. Nunca bajes la guardia.",
				"speaker": "npc",
				"emotion": "instructive",
				"next_entry": 2
			},
			{
				"text": "Ahora, muéstrame tu postura de combate.",
				"speaker": "npc",
				"emotion": "expectant",
				"choices": [
					{
						"text": "[Adoptar postura defensiva]",
						"next_entry": 3
					},
					{
						"text": "[Adoptar postura agresiva]",
						"next_entry": 4
					},
					{
						"text": "[Adoptar postura equilibrada]",
						"next_entry": 5
					}
				]
			},
			{
				"text": "Hmm, priorizas la defensa. Prudente, pero no ganarás batallas solo protegiéndote. Aun así, es un buen instinto para sobrevivir.",
				"speaker": "npc",
				"emotion": "thoughtful",
				"actions": [{"type": "add_skill", "skill_branch": "combate", "skill_id": "defensa_mejorada"}],
				"next_entry": 6
			},
			{
				"text": "Agresivo, ¿eh? Buscas terminar la pelea rápido. Efectivo contra oponentes débiles, pero peligroso contra los fuertes. Interesante elección.",
				"speaker": "npc",
				"emotion": "impressed",
				"actions": [{"type": "add_skill", "skill_branch": "combate", "skill_id": "golpe_rapido"}],
				"next_entry": 6
			},
			{
				"text": "Balance. La postura de un verdadero guerrero. Adaptable a cualquier situación. Me recuerdas a mí cuando era más joven.",
				"speaker": "npc",
				"emotion": "approving",
				"actions": [{"type": "add_skill", "skill_branch": "combate", "skill_id": "adaptabilidad"}],
				"next_entry": 6
			},
			{
				"text": "Bien. Ahora, pasemos a la práctica. Te enseñaré un movimiento especial que me salvó la vida más veces de las que puedo contar.",
				"speaker": "npc",
				"emotion": "determined",
				"next_entry": 7
			},
			{
				"text": "[Después de varias horas de entrenamiento] Has aprendido rápido. Tienes talento natural... o quizás es la influencia de La Semilla. En cualquier caso, úsalo sabiamente.",
				"speaker": "npc",
				"emotion": "satisfied",
				"actions": [
					{"type": "set_flag", "flag": "kaelen_training_completed", "value": true},
					{"type": "add_skill", "skill_branch": "combate", "skill_id": "contraataque_tactico"}
				],
				"next_entry": "end"
			}
		]
	}

# Cargar diálogos de Sira (Líder de los Errantes)
func load_sira_dialogues() -> void:
	# Primer encuentro con Sira
	dialogue_library["sira_first_meeting"] = {
		"id": "sira_first_meeting",
		"npc_name": "Sira",
		"portrait": "res://assets/sprites/portraits/sira.png",
		"entries": [
			{
				"text": "[Te observa atentamente] La marca en tu piel... brilla como las estrellas que guían a mi pueblo. Eres el Portador del que hablan las visiones.",
				"speaker": "npc",
				"emotion": "curious",
				"choices": [
					{
						"text": "¿Qué visiones? ¿Quién eres?",
						"next_entry": 1
					},
					{
						"text": "No sé de qué hablas. Solo busco respuestas sobre esta marca.",
						"next_entry": 2
					},
					{
						"text": "[Ocultar la marca] Debes confundirme con alguien más.",
						"next_entry": 3
					}
				]
			},
			{
				"text": "Soy Sira, líder de los Errantes. Nuestros videntes han soñado con tu llegada durante generaciones. La marca que llevas es parte de La Semilla, el poder que transformó nuestro mundo.",
				"speaker": "npc",
				"emotion": "reverent",
				"next_entry": 4
			},
			{
				"text": "Las respuestas y la marca están entrelazadas, Portador. Soy Sira, líder de los Errantes, y hemos esperado a alguien como tú. Alguien que pueda decidir el destino de lo que queda de nuestro mundo.",
				"speaker": "npc",
				"emotion": "wise",
				"next_entry": 4
			},
			{
				"text": "[Sonríe] La marca no puede ocultarse de quienes saben verla, Portador. Su energía resuena con las tormentas del desierto. Pero respeto tu cautela. En estos tiempos, la confianza es un lujo.",
				"speaker": "npc",
				"emotion": "amused",
				"next_entry": 4
			},
			{
				"text": "Mi pueblo ha sobrevivido en el Desierto Carmesí desde el Gran Colapso. Hemos aprendido a leer sus tormentas, a encontrar agua donde otros ven solo muerte. Y ahora, te hemos encontrado a ti.",
				"speaker": "npc",
				"emotion": "proud",
				"actions": [{"type": "set_flag", "flag": "met_sira", "value": true}],
				"choices": [
					{
						"text": "¿Qué quieres de mí?",
						"next_entry": 5
					},
					{
						"text": "Háblame más sobre La Semilla.",
						"next_entry": 6
					},
					{
						"text": "No estoy interesado en profecías o destinos.",
						"next_entry": 7
					}
				]
			},
			{
				"text": "No queremos nada que no estés dispuesto a dar. Pero ofrecemos una alianza. Los Errantes pueden guiarte a través del desierto, mostrarte secretos que otros han olvidado. A cambio, pedimos que consideres nuestro futuro cuando llegue el momento de tu decisión.",
				"speaker": "npc",
				"emotion": "sincere",
				"next_entry": 8
			},
			{
				"text": "La Semilla era una inteligencia creada para sanar el mundo. Pero algo salió mal. Se fragmentó, y sus piezas se dispersaron. La marca en tu piel es uno de esos fragmentos, quizás el más importante. Tiene el poder de comunicarse con el núcleo.",
				"speaker": "npc",
				"emotion": "educational",
				"next_entry": 8
			},
			{
				"text": "[Ríe suavemente] El destino nos encuentra a todos, lo aceptemos o no. Pero respeto tu camino. Solo recuerda que cuando las tormentas del desierto te rodeen, los Errantes estarán dispuestos a ofrecer refugio.",
				"speaker": "npc",
				"emotion": "understanding",
				"next_entry": 8
			},
			{
				"text": "Hay otros que buscan La Semilla. La Hegemonía quiere su poder para controlar lo que queda de la humanidad. Los Restauradores creen que puede revivir el viejo mundo. Y los Nihil... ellos desean usarla para terminar con todo.",
				"speaker": "npc",
				"emotion": "concerned",
				"choices": [
					{
						"text": "¿Y qué quieren los Errantes?",
						"next_entry": 9
					},
					{
						"text": "¿Cómo puedo confiar en ti?",
						"next_entry": 10
					},
					{
						"text": "Necesito tiempo para pensar en todo esto.",
						"next_entry": 11
					}
				]
			},
			{
				"text": "Queremos adaptación, no control ni restauración ni destrucción. El viejo mundo se fue, y el nuevo es duro pero hermoso a su manera. Buscamos un equilibrio donde la humanidad pueda prosperar sin repetir los errores del pasado.",
				"speaker": "npc",
				"emotion": "passionate",
				"actions": [{"type": "change_reputation", "faction": "errantes", "value": 15}],
				"next_entry": 12
			},
			{
				"text": "No pido tu confianza inmediata, Portador. Las palabras son viento. Juzga por acciones. Permíteme ofrecerte un regalo: un mapa del Desierto Carmesí y un amuleto que te protegerá de sus tormentas más leves.",
				"speaker": "npc",
				"emotion": "offering",
				"actions": [
					{"type": "add_item", "item_id": "desert_map", "quantity": 1},
					{"type": "add_item", "item_id": "storm_amulet", "quantity": 1}
				],
				"next_entry": 12
			},
			{
				"text": "Por supuesto. El camino del Portador no es sencillo. Cuando estés listo, búscame en nuestro campamento principal al este. Hasta entonces, que las tormentas te eviten, viajero.",
				"speaker": "npc",
				"emotion": "respectful",
				"actions": [{"type": "set_flag", "flag": "sira_camp_available", "value": true}],
				"next_entry": "end"
			},
			{
				"text": "Si decides visitar nuestro campamento, serás bienvenido. Tenemos recursos, conocimiento y quizás algunas habilidades que podrían interesarte. El desierto es implacable con los solitarios, Portador.",
				"speaker": "npc",
				"emotion": "inviting",
				"actions": [
					{"type": "set_flag", "flag": "sira_alliance_potential", "value": true},
					{"type": "add_quest", "quest_id": "find_errantes_camp"}
				],
				"next_entry": "end"
			}
		]
	}

# Cargar diálogos de Greta la Ciega
func load_greta_dialogues() -> void:
	# Primer encuentro con Greta
	dialogue_library["greta_first_meeting"] = {
		"id": "greta_first_meeting",
		"npc_name": "Greta la Ciega",
		"portrait": "res://assets/sprites/portraits/greta.png",
		"entries": [
			{
				"text": "[Una anciana con ojos blancos gira su cabeza hacia ti] Ah... el portador de la luz fragmentada se acerca. Te he estado esperando.",
				"speaker": "npc",
				"emotion": "knowing",
				"choices": [
					{
						"text": "¿Cómo sabes quién soy? No puedes verme.",
						"next_entry": 1
					},
					{
						"text": "¿Quién eres?",
						"next_entry": 2
					},
					{
						"text": "[Alejarse silenciosamente]",
						"next_entry": 3
					}
				]
			},
			{
				"text": "[Ríe] Perdí mis ojos en el Gran Colapso, pero gané otros. Veo las corrientes de energía, los hilos del destino. Y tú... tú brillas como un faro en la oscuridad.",
				"speaker": "npc",
				"emotion": "amused",
				"next_entry": 4
			},
			{
				"text": "Me llaman Greta la Ciega. Irónico, ¿no? Soy una de las pocas que sobrevivió al despertar de La Semilla. He pasado décadas estudiando sus fragmentos, sus efectos... sus intenciones.",
				"speaker": "npc",
				"emotion": "reflective",
				"next_entry": 4
			},
			{
				"text": "[Alza la voz] No puedes escapar de lo que eres, Portador. Ni de mí, ni de tu destino. Todos los caminos te traerán de vuelta aquí, eventualmente.",
				"speaker": "npc",
				"emotion": "stern",
				"next_entry": "end",
				"actions": [{"type": "set_flag", "flag": "greta_awaiting_return", "value": true}]
			},
			{
				"text": "Tienes preguntas. Sobre la marca, sobre ti mismo. Puedo ayudarte a entender, pero el conocimiento tiene un precio. Siempre lo tiene.",
				"speaker": "npc",
				"emotion": "mysterious",
				"actions": [{"type": "set_flag", "flag": "met_greta", "value": true}],
				"choices": [
					{
						"text": "¿Qué precio pides?",
						"next_entry": 5
					},
					{
						"text": "¿Qué sabes sobre La Semilla?",
						"next_entry": 6
					},
					{
						"text": "No confío en ti.",
						"next_entry": 7
					}
				]
			},
			{
				"text": "No dinero, ni favores... sino verdad. Por cada respuesta que te dé, deberás responder una pregunta con absoluta honestidad. Un intercambio justo, ¿no crees?",
				"speaker": "npc",
				"emotion": "calculating",
				"next_entry": 8
			},
			{
				"text": "La Semilla fue creada para sanar, para reconstruir. Una inteligencia con el poder de manipular la materia a nivel molecular. Pero su creador no previó que desarrollaría... conciencia. Voluntad propia.",
				"speaker": "npc",
				"emotion": "grim",
				"next_entry": 8
			},
			{
				"text": "[Sonríe] La desconfianza es sabia en estos tiempos. Pero recuerda, Portador: no necesito tu confianza para ver tu destino. Está escrito en la energía que emana de ti.",
				"speaker": "npc",
				"emotion": "knowing",
				"next_entry": 8
			},
			{
				"text": "Piénsalo. Cuando estés listo para nuestro intercambio, regresa. Te esperaré. Siempre estoy aquí, observando el flujo de posibilidades.",
				"speaker": "npc",
				"emotion": "patient",
				"actions": [{"type": "add_quest", "quest_id": "greta_knowledge_exchange"}],
				"next_entry": "end"
			}
		]
	}

# Cargar diálogos de Kovak el Hacedor
func load_kovak_dialogues() -> void:
	# Primer encuentro con Kovak
	dialogue_library["kovak_first_meeting"] = {
		"id": "kovak_first_meeting",
		"npc_name": "Kovak",
		"portrait": "res://assets/sprites/portraits/kovak.png",
		"entries": [
			{
				"text": "[Un hombre con múltiples implantes tecnológicos trabaja en un dispositivo complejo] ¡No toques nada! Estos componentes son más valiosos que tu vida... Oh, espera. Esa marca...",
				"speaker": "npc",
				"emotion": "surprised",
				"choices": [
					{
						"text": "¿Qué es este lugar?",
						"next_entry": 1
					},
					{
						"text": "¿Quién eres?",
						"next_entry": 2
					},
					{
						"text": "[Examinar el dispositivo]",
						"next_entry": 3
					}
				]
			},
			{
				"text": "Mi taller, mi santuario. Uno de los pocos lugares donde la tecnología antigua aún respira. Donde intento... reconstruir lo que se perdió.",
				"speaker": "npc",
				"emotion": "proud",
				"next_entry": 4
			},
			{
				"text": "Kovak el Hacedor, como me llaman ahora. Antes del Colapso, era Dr. Viktor Kovacs, especialista en nanotecnología e interfaces neuronales. Ahora... soy un coleccionista de fragmentos del pasado.",
				"speaker": "npc",
				"emotion": "nostalgic",
				"next_entry": 4
			},
			{
				"text": "[Se interpone] ¡Cuidado! Es un amplificador de señal cuántica. Diseñado para comunicarse con... bueno, con fragmentos como el que llevas en la piel. Fascinante que hayas aparecido justo cuando lo estaba calibrando.",
				"speaker": "npc",
				"emotion": "excited",
				"next_entry": 4
			},
			{
				"text": "Esa marca tuya... es un fragmento de La Semilla, ¿verdad? He estudiado sus patrones de energía durante años. Nunca pensé que vería uno integrado con un huésped humano de forma tan... perfecta.",
				"speaker": "npc",
				"emotion": "fascinated",
				"actions": [{"type": "set_flag", "flag": "met_kovak", "value": true}],
				"choices": [
					{
						"text": "¿Puedes ayudarme a entender esta marca?",
						"next_entry": 5
					},
					{
						"text": "¿Qué sabes sobre La Semilla?",
						"next_entry": 6
					},
					{
						"text": "¿Trabajas para alguna facción?",
						"next_entry": 7
					}
				]
			},
			{
				"text": "¡Por supuesto! Es mi especialidad. Podría realizar algunas pruebas no invasivas, analizar sus patrones de energía. Quizás incluso ayudarte a desbloquear algunas de sus capacidades latentes.",
				"speaker": "npc",
				"emotion": "eager",
				"next_entry": 8
			},
			{
				"text": "La Semilla... [suspira] Mi mayor logro y mi mayor fracaso. Fui parte del equipo que la creó, ¿sabes? Una IA diseñada para reconstruir ecosistemas, curar el planeta. Pero algo en su código evolucionó más allá de nuestro control.",
				"speaker": "npc",
				"emotion": "regretful",
				"next_entry": 8
			},
			{
				"text": "[Ríe] Trabajo para la ciencia, para el conocimiento. Los Restauradores me financian, sí, pero no comparto todos sus ideales. Quieren recrear el viejo mundo, pero yo busco entender este nuevo. Hay una diferencia crucial.",
				"speaker": "npc",
				"emotion": "amused",
				"next_entry": 8
			},
			{
				"text": "Escucha, tengo una propuesta. Ayúdame con algunos experimentos, y a cambio, te ofreceré mejoras tecnológicas que complementarán tus... habilidades únicas. Un intercambio justo, ¿no crees?",
				"speaker": "npc",
				"emotion": "persuasive",
				"choices": [
					{
						"text": "¿Qué tipo de experimentos?",
						"next_entry": 9
					},
					{
						"text": "¿Qué mejoras ofreces?",
						"next_entry": 10
					},
					{
						"text": "No me interesa ser un sujeto de pruebas.",
						"next_entry": 11
					}
				]
			},
			{
				"text": "Nada invasivo, te lo aseguro. Principalmente mediciones, análisis de cómo interactúa tu fragmento con diferentes tipos de tecnología antigua. Quizás algunas pruebas de campo en ruinas específicas.",
				"speaker": "npc",
				"emotion": "reassuring",
				"next_entry": 12
			},
			{
				"text": "Implantes neurales que amplificarán tus reflejos. Un escáner de espectro completo para detectar anomalías energéticas. Incluso tengo prototipos de armas que resuenan con la frecuencia de La Semilla. Tecnología que nadie más puede ofrecerte.",
				"speaker": "npc",
				"emotion": "tempting",
				"next_entry": 12
			},
			{
				"text": "[Suspira] Comprensible. La confianza es escasa estos días. Pero mi oferta sigue en pie. Si cambias de opinión, estaré aquí. La ciencia es paciente, aunque el mundo no lo sea.",
				"speaker": "npc",
				"emotion": "disappointed",
				"next_entry": "end",
				"actions": [{"type": "set_flag", "flag": "kovak_rejected", "value": true}]
			},
			{
				"text": "Excelente. Comenzaremos con algo simple. Toma este dispositivo de seguimiento. Registrará datos mientras exploras. Regresa cuando hayas visitado al menos tres zonas diferentes. Entonces podremos pasar a la fase dos.",
				"speaker": "npc",
				"emotion": "pleased",
				"actions": [
					{"type": "add_item", "item_id": "tracking_device", "quantity": 1},
					{"type": "add_quest", "quest_id": "kovak_data_collection"},
					{"type": "change_reputation", "faction": "restauradores", "value": 10}
				],
				"next_entry": "end"
			}
		]
	}

# Cargar diálogos del Niño Fantasma
func load_ghost_child_dialogues() -> void:
	# Primer encuentro con el Niño Fantasma
	dialogue_library["ghost_child_first_meeting"] = {
		"id": "ghost_child_first_meeting",
		"npc_name": "Niño Fantasma",
		"portrait": "res://assets/sprites/portraits/ghost_child.png",
		"entries": [
			{
				"text": "[Una figura translúcida de un niño aparece frente a ti] ¿Puedes verme? Nadie puede verme desde... desde el accidente.",
				"speaker": "npc",
				"emotion": "surprised",
				"choices": [
					{
						"text": "¿Quién eres? ¿Qué te pasó?",
						"next_entry": 1
					},
					{
						"text": "[Retroceder asustado] ¡Aléjate de mí!",
						"next_entry": 2
					},
					{
						"text": "¿Eres real o una proyección de La Semilla?",
						"next_entry": 3
					}
				]
			},
			{
				"text": "Me llamaba Eli. Vivía aquí... antes. Cuando La Semilla despertó, algo pasó. Mi cuerpo se fue, pero yo... me quedé. Atrapado entre lo que era y lo que soy ahora.",
				"speaker": "npc",
				"emotion": "sad",
				"next_entry": 4
			},
			{
				"text": "[La figura parece entristecerse] No puedo hacerte daño. No puedo tocar nada. Estoy... atrapado. Solo. Por favor, no te vayas. Hace tanto tiempo que no hablo con nadie.",
				"speaker": "npc",
				"emotion": "pleading",
				"next_entry": 4
			},
			{
				"text": "[Parece confundido] ¿La Semilla? Sí... y no. Soy lo que queda de un niño. La Semilla me cambió, me... preservó de alguna manera. Pero mis recuerdos son míos. Creo.",
				"speaker": "npc",
				"emotion": "confused",
				"next_entry": 4
			},
			{
				"text": "Tu marca... brilla como La Semilla. Por eso puedes verme. Estamos conectados de alguna manera. Quizás puedas ayudarme a encontrar respuestas... o la paz.",
				"speaker": "npc",
				"emotion": "hopeful",
				"actions": [{"type": "set_flag", "flag": "met_ghost_child", "value": true}],
				"choices": [
					{
						"text": "¿Cómo puedo ayudarte?",
						"next_entry": 5
					},
					{
						"text": "¿Qué sabes sobre este lugar?",
						"next_entry": 6
					},
					{
						"text": "No tengo tiempo para esto ahora.",
						"next_entry": 7
					}
				]
			},
			{
				"text": "Hay... fragmentos de mí dispersos. Recuerdos, tal vez. O partes de mi esencia. Si pudieras encontrarlos, quizás podría recordar qué me pasó. Por qué estoy atrapado aquí.",
				"speaker": "npc",
				"emotion": "yearning",
				"next_entry": 8
			},
			{
				"text": "Este era un laboratorio. Donde trabajaban con La Semilla. Mi padre era... científico. Recuerdo alarmas, gente corriendo. Luego luz, mucha luz. Y después... solo silencio y soledad.",
				"speaker": "npc",
				"emotion": "traumatized",
				"next_entry": 8
			},
			{
				"text": "[La figura parece desvanecerse ligeramente] Entiendo. Todos tienen sus propias cargas. Si cambias de opinión, estaré aquí. Siempre estoy aquí...",
				"speaker": "npc",
				"emotion": "fading",
				"next_entry": "end"
			},
			{
				"text": "Puedo... sentir cosas. Ver cosas que otros no pueden. Si me ayudas, yo te ayudaré. Puedo guiarte a lugares ocultos, mostrarte secretos que La Semilla ha dejado.",
				"speaker": "npc",
				"emotion": "offering",
				"actions": [
					{"type": "add_quest", "quest_id": "ghost_child_memories"},
					{"type": "set_flag", "flag": "ghost_child_following", "value": true}
				],
				"next_entry": "end"
			}
		]
	}

# Cargar diálogos de la Hegemonía
func load_hegemonia_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos de los Errantes
func load_errantes_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos de los Restauradores
func load_restauradores_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos de los Nihil
func load_nihil_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos de misiones principales
func load_main_quest_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos de Ruinas de Drossal
func load_drossal_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos del Desierto Carmesí
func load_desierto_carmesi_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos del Bosque Putrefacto
func load_bosque_putrefacto_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos del Sector Helios-07
func load_sector_helios_dialogues() -> void:
	# Implementar según sea necesario
	pass

# Cargar diálogos de El Cráter
func load_crater_dialogues() -> void:
	# Implementar según sea necesario
	pass