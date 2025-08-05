# Documento de Diseño del Juego (GDD)
# "Cenizas del Horizonte"

## Información General

**Título:** Cenizas del Horizonte  
**Género:** RPG 2D con combate por turnos  
**Plataforma:** PC (Windows, Mac, Linux)  
**Motor:** Godot/Unity  
**Estética:** Pixel art con tonos apagados y detalles radiactivos o neón  
**Clasificación:** T (Teen) / PEGI 16  
**Inspiraciones:** Fallout, Wasteland, Hyper Light Drifter, Undertale  

## Sinopsis

En un mundo devastado por un cataclismo tecnológico, despiertas como "El Portador" en una instalación abandonada, sin recuerdos pero con una marca brillante en tu piel. Esta marca es un fragmento de una poderosa IA conocida como "La Semilla", que tiene el poder de restaurar o destruir lo que queda de la civilización. Tu viaje te llevará a través de un paisaje postapocalíptico donde deberás formar alianzas, enfrentar enemigos y tomar decisiones morales que determinarán el destino del mundo. ¿Traerás un nuevo amanecer, gobernarás con puño de hierro o borrarás los últimos vestigios de la humanidad?

## Estilo Visual y Sonoro

### Visual
- **Pixel art** de alta calidad con resolución consistente
- Paleta de colores predominantemente apagada (grises, marrones, azules oscuros)
- Acentos de colores vibrantes (verde radiactivo, azul neón, rojo intenso) para elementos importantes
- Animaciones fluidas para combate y movimiento
- Efectos de partículas para habilidades y fenómenos ambientales
- Ciclo día/noche con cambios de iluminación

### Sonoro
- Música ambiental minimalista con sintetizadores y elementos post-rock
- Efectos de sonido retro pero con profundidad
- Temas musicales únicos para cada región principal
- Sonidos ambientales que reflejan la desolación (viento, estructuras metálicas, estática)
- Sin voces completas, pero con expresiones vocales básicas para personajes clave

## Historia Principal

### Acto I: Despertar
El Portador despierta en las ruinas del Complejo Génesis con amnesia. Descubre que tiene un fragmento de La Semilla incrustado en su piel, que le otorga habilidades especiales. Al salir del complejo, llega a las Ruinas de Drossal, donde debe elegir entre ayudar a los supervivientes locales o explotar sus recursos para fortalecerse.

### Acto II: Búsqueda
La búsqueda de respuestas lleva al Portador a través del Desierto Carmesí y el Bosque Putrefacto, donde conoce las principales facciones:
- **Los Restauradores:** Científicos y visionarios que buscan usar La Semilla para restaurar el ecosistema.
- **La Hegemonía:** Militares y tecnócratas que quieren usar La Semilla para establecer un nuevo orden mundial.
- **Los Nihil:** Culto que cree que la humanidad debe ser borrada para que el planeta sane.

### Acto III: Revelación
En el Sector Helios-07, el Portador descubre la verdad sobre La Semilla: fue creada como una IA de terraformación que se volvió inestable y causó el cataclismo. También aprende sobre su propio pasado y su conexión con La Semilla.

### Acto IV: Decisión
El Portador debe llevar el fragmento al Cráter, donde reside el núcleo de La Semilla. Aquí, dependiendo de las alianzas formadas y decisiones tomadas, podrá:
1. **Restaurar:** Reprogramar La Semilla para sanar el mundo (final Restauradores)
2. **Controlar:** Fusionarse con La Semilla para gobernar con tecnología avanzada (final Hegemonía)
3. **Destruir:** Eliminar La Semilla y dejar que el mundo siga su curso natural (final neutral)
4. **Aniquilar:** Usar La Semilla para acelerar la extinción (final Nihil)

## Mapa y Ambientación

### Ruinas de Drossal
- **Descripción:** Ciudad en ruinas que sirve como tutorial y hub inicial
- **Características:** Edificios derrumbados, pequeños asentamientos, túneles de metro
- **Habitantes:** Supervivientes independientes, saqueadores, comerciantes
- **Peligros:** Bestias mutadas, bandidos, zonas radiactivas

### Desierto Carmesí
- **Descripción:** Vasto desierto con tormentas de arena rojiza y radiación
- **Características:** Dunas cambiantes, caravanas nómadas, oasis tecnológicos
- **Habitantes:** Nómadas del desierto, La Hegemonía (base principal)
- **Peligros:** Tormentas de arena, escorpiones gigantes, espejismos peligrosos

### Bosque Putrefacto
- **Descripción:** Antiguo bosque transformado por esporas y hongos bioluminiscentes
- **Características:** Árboles gigantes, lagos contaminados, estructuras orgánicas
- **Habitantes:** Los Restauradores (base principal), criaturas simbióticas
- **Peligros:** Esporas tóxicas, plantas carnívoras, alucinaciones

### Sector Helios-07
- **Descripción:** Complejo tecnológico parcialmente funcional
- **Características:** Laboratorios, servidores masivos, sistemas de defensa activos
- **Habitantes:** IAs autónomas, robots de mantenimiento, Los Nihil (base oculta)
- **Peligros:** Sistemas de seguridad, experimentos fallidos, realidad virtual

### El Cráter
- **Descripción:** Epicentro del cataclismo, donde reside el núcleo de La Semilla
- **Características:** Paisaje alienígena, tecnología y naturaleza fusionadas
- **Habitantes:** Manifestaciones de La Semilla, guardianes finales
- **Peligros:** Realidad inestable, enemigos finales según facción elegida

## Sistema de Personaje

### Atributos Principales
- **Fuerza:** Daño físico y capacidad de carga
- **Agilidad:** Velocidad en combate, evasión y precisión
- **Resistencia:** Salud, defensa física y resistencia a toxinas
- **Intelecto:** Habilidades tecnológicas, hackeo y conocimiento
- **Percepción:** Detección de secretos, precisión a distancia
- **Voluntad:** Resistencia mental, poder de mutación y persuasión

### Estadísticas Derivadas
- **Salud:** Puntos de vida
- **Energía:** Recurso para habilidades especiales
- **Iniciativa:** Determina el orden en combate
- **Carga Mutante:** Acumula para desatar la Reacción Mutante
- **Reputación:** Con cada facción (Restauradores, Hegemonía, Nihil)

## Árbol de Habilidades

### Rama de Combate
1. **Nivel 1**
   - **Golpe Preciso:** Ataque con mayor probabilidad crítica
   - **Postura Defensiva:** Aumenta defensa por un turno
   - **Disparo Rápido:** Ataque a distancia con menor daño pero mayor velocidad

2. **Nivel 2**
   - **Combo de Golpes:** Múltiples ataques consecutivos
   - **Contraataque:** Devuelve parte del daño recibido
   - **Disparo Penetrante:** Ignora parte de la defensa enemiga

3. **Nivel 3**
   - **Ejecutor:** Daño masivo a enemigos debilitados
   - **Muro Inquebrantable:** Reduce significativamente el daño recibido
   - **Lluvia de Balas:** Ataque de área a múltiples enemigos

### Rama de Tecnología
1. **Nivel 1**
   - **Hackeo Básico:** Desactiva temporalmente un enemigo robótico
   - **Dron de Reconocimiento:** Revela información sobre enemigos
   - **Escudo Energético:** Barrera que absorbe daño

2. **Nivel 2**
   - **Sobrecarga:** Causa daño eléctrico a enemigos tecnológicos
   - **Dron de Combate:** Asiste en batalla con ataques automáticos
   - **Nanomedicina:** Cura gradualmente durante varios turnos

3. **Nivel 3**
   - **Virus Catastrófico:** Toma control de un enemigo robótico
   - **Armamento Prototipo:** Desbloquea armas de energía avanzadas
   - **Campo de Estasis:** Ralentiza a todos los enemigos en el campo

### Rama de Mutación
1. **Nivel 1**
   - **Regeneración Celular:** Cura un porcentaje de salud
   - **Sentidos Aumentados:** Aumenta precisión y evasión
   - **Piel Endurecida:** Resistencia pasiva al daño físico

2. **Nivel 2**
   - **Garras Mutantes:** Ataques que causan sangrado
   - **Telepatía Básica:** Predice ataques enemigos
   - **Adaptación Tóxica:** Inmunidad a venenos y habilidad para usarlos

3. **Nivel 3**
   - **Metamorfosis:** Transforma partes del cuerpo para diferentes ventajas
   - **Manipulación Temporal:** Otorga turnos adicionales
   - **Explosión Psiónica:** Daño masivo de área basado en Voluntad

## Sistema de Combate

### Mecánicas Básicas
- Sistema por turnos con barra de iniciativa visual
- La Agilidad y efectos de estado determinan la frecuencia de turnos
- Acciones: Ataque básico, Habilidad especial, Objeto, Huir/Persuadir
- Posicionamiento táctico en una cuadrícula 2D

### Reacción Mutante
- Barra especial que se llena al recibir daño o usar habilidades de mutación
- Al llenarse, permite desatar una poderosa habilidad única por combate
- El tipo de Reacción Mutante depende de las decisiones narrativas y habilidades desbloqueadas

### Interacciones Ambientales
- Elementos del escenario pueden usarse tácticamente (cobertura, trampas, etc.)
- Condiciones ambientales afectan el combate (radiación, esporas, etc.)
- Posibilidad de evitar combates mediante sigilo o persuasión

## NPCs y Enemigos

### Aliados Potenciales

#### Kaelen (Soldado Exiliado)
- **Personalidad:** Estoico, leal pero atormentado por su pasado
- **Motivación:** Redención por acciones pasadas bajo La Hegemonía
- **Habilidades:** Especialista en combate, conocimiento militar
- **Diseño:** Hombre de mediana edad, armadura militar modificada, cicatrices visibles

#### Sira (Líder de los Errantes)
- **Personalidad:** Carismática, pragmática, desconfiada
- **Motivación:** Proteger a su gente nómada y encontrar un hogar permanente
- **Habilidades:** Supervivencia, conocimiento del desierto, diplomacia
- **Diseño:** Mujer joven, ropas del desierto con adornos tecnológicos, bastón multifuncional

#### Greta la Ciega
- **Personalidad:** Misteriosa, directa, posee conocimiento prohibido
- **Motivación:** Preservar el conocimiento antiguo, guiar al Portador
- **Habilidades:** Precognición, conocimiento histórico, habilidades psiónicas
- **Diseño:** Anciana con ojos blancos, túnica con símbolos arcanos, dispositivo de asistencia flotante

#### Kovak el Hacedor
- **Personalidad:** Excéntrico, brillante, obsesivo
- **Motivación:** Crear la tecnología perfecta, entender La Semilla
- **Habilidades:** Creación de objetos, mejoras, conocimiento tecnológico
- **Diseño:** Hombre de mediana edad, múltiples prótesis cibernéticas, taller portátil

#### Niño Fantasma
- **Personalidad:** Inocente pero inquietante, habla en acertijos
- **Motivación:** Desconocida (revelación tardía: es una manifestación de La Semilla)
- **Habilidades:** Aparece y desaparece, conoce secretos, guía al jugador
- **Diseño:** Niño translúcido con ojos brillantes, ropa de época anterior al cataclismo

### Enemigos Únicos

#### Raak (El Devorador)
- **Tipo:** Bestia mutante masiva
- **Ubicación:** Bosque Putrefacto
- **Habilidades:** Regeneración, absorción de vida, ataques tóxicos
- **Diseño:** Criatura cuadrúpeda con múltiples bocas y tentáculos, partes vegetales y animales fusionadas

#### Hermano Khaor
- **Tipo:** Líder fanático de los Nihil
- **Ubicación:** Sector Helios-07
- **Habilidades:** Manipulación mental, invocación de seguidores, autosacrificio por poder
- **Diseño:** Humano demacrado con implantes tecnológicos, túnica con circuitos, máscara ritual

#### Gólem de Hierro
- **Tipo:** Constructo militar autónomo
- **Ubicación:** Desierto Carmesí (base de La Hegemonía)
- **Habilidades:** Armamento pesado, escudos modulares, llamada a refuerzos
- **Diseño:** Robot masivo con múltiples armas, blindaje adaptativo, núcleo de energía expuesto

#### Devorah
- **Tipo:** Científica corrompida por La Semilla
- **Ubicación:** El Cráter
- **Habilidades:** Control de la realidad local, transformación, creación de anomalías
- **Diseño:** Mujer parcialmente fusionada con tecnología y elementos orgánicos, apariencia cambiante

## Sistema de Misiones

### Tipos de Misiones

#### Misiones Principales
- Avanzan la historia central
- Tienen ramificaciones según decisiones
- Desbloquean nuevas áreas y habilidades clave

#### Misiones de Facción
- Aumentan la reputación con una facción específica
- Revelan más sobre la ideología y planes de cada grupo
- Pueden ser mutuamente excluyentes entre facciones rivales

#### Misiones Secundarias
- Historias personales de compañeros
- Exploración de lugares de interés
- Resolución de problemas locales

#### Contratos de Caza
- Eliminación de enemigos especiales
- Recompensas materiales significativas
- Desafíos de combate únicos

### Sistema de Recompensas
- **Reputación:** Desbloquea diálogos, comerciantes y finales
- **Recursos:** Materiales para crafting, mejoras y comercio
- **Equipo:** Armas, armaduras y dispositivos únicos
- **Conocimiento:** Entradas de diario que expanden el lore
- **Habilidades:** Puntos de habilidad o habilidades únicas

## Economía del Juego

### Recursos
- **Chatarra:** Moneda común, usada para comercio básico
- **Tecnofragmentos:** Moneda rara, para objetos y mejoras avanzadas
- **Biomasa:** Recurso para habilidades de mutación y consumibles
- **Datos:** Recurso para habilidades tecnológicas y desbloqueo de información

### Sistemas de Crafting
- **Modificación de Armas:** Personalización con diferentes efectos
- **Creación de Consumibles:** Medicinas, estimulantes, bombas
- **Mejora de Equipo:** Aumentar estadísticas de objetos existentes

## Diseño UI/UX

### Interfaz de Usuario
- **HUD Minimalista:** Salud, Energía y Carga Mutante siempre visibles
- **Menú de Inventario:** Organizado por categorías, con descripción de objetos
- **Árbol de Habilidades:** Representación visual de las tres ramas
- **Mapa:** Descubierto progresivamente, con marcadores personalizables
- **Diario:** Registro de misiones, entradas de lore y decisiones tomadas

### Experiencia de Usuario
- **Tutoriales Integrados:** Aprendizaje a través de la jugabilidad
- **Sistema de Pistas:** Opcional para jugadores que necesiten ayuda
- **Accesibilidad:** Opciones para daltonismo, tamaño de texto, dificultad
- **Guardado Automático:** En puntos clave, más guardado manual

## Mecánicas Futuras (Expansión)

### Gestión de Asentamientos
- Establecer y mejorar bases en diferentes regiones
- Asignar NPCs a tareas específicas
- Defender asentamientos de ataques

### Sistema de Vehículos
- Personalizar vehículos para atravesar el mundo más rápidamente
- Combate vehicular contra bandidos y criaturas gigantes
- Exploración de zonas anteriormente inaccesibles

### Modo Multijugador Cooperativo
- Segundo jugador controla a un compañero
- Misiones especiales cooperativas
- Habilidades combinadas únicas

---

## Notas de Desarrollo

- Priorizar la narrativa y el sistema de combate en la primera fase
- Implementar el sistema de decisiones morales con consecuencias visibles
- Crear primero una zona completa (Ruinas de Drossal) como prototipo funcional
- Enfocarse en la rejugabilidad a través de diferentes caminos narrativos
- Mantener coherencia estética en todos los elementos del juego