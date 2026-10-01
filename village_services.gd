extends Node2D

const Interaction = preload("res://service_interaction.gd")
const ServicesUI = preload("res://services_ui.gd")
const SERVICES: Dictionary = {
	"library": {"title": "BIBLIOTECA", "npc": "Elena · Bibliotecaria", "position": Vector2(140, 1280), "color": Color("688fba"), "house": "res://CasaAdobeChica.tscn"},
	"food": {"title": "COMIDA", "npc": "Lucía · Tendera", "position": Vector2(560, 1280), "color": Color("d5a259"), "house": "res://CasaAdobeChica.tscn"},
	"remedies": {"title": "REMEDIOS", "npc": "Inés · Encargada", "position": Vector2(140, 1600), "color": Color("92ad68"), "house": "res://CasaAdobeChica.tscn"},
	"smith": {"title": "HERRERÍA", "npc": "Tomás · Herrero", "position": Vector2(560, 1600), "color": Color("b77c68"), "house": "res://CasaTaller.tscn"}
}
var rooms: Dictionary = {}
var doors: Dictionary = {}
var merchants: Dictionary = {}
var exits: Dictionary = {}
var ui: CanvasLayer
var active_room: String = ""
var camera_room: String = "?"
var original_camera_position := Vector2(-41, 7)

func _ready() -> void:
	add_to_group("village_services")
	ui = ServicesUI.new()
	add_child(ui)
	# Nueva plaza al sur, conectada al camino existente por el centro.
	_rect(self, Rect2(24, 1232, 832, 680), Color("829858"), -3)
	_rect(self, Rect2(344, 1180, 80, 680), Color("c1aa78"), -2)
	for y in [1450, 1770]:
		_rect(self, Rect2(144, y, 596, 48), Color("c1aa78"), -2)
		for x in range(160, 736, 32):
			_rect(self, Rect2(x, y + 16, 18, 8), Color("d5c494"), -1)
	_label(self, "↓ BIBLIOTECA Y COMERCIOS ↓", Vector2(254, 1216), 260, 11)
	_rect(self, Rect2(254, 394, 154, 24), Color("4b4430"), 1)
	_label(self, "↓ Biblioteca y comercios", Vector2(250, 398), 162, 10)
	var index := 0
	for id in SERVICES:
		_build_exterior(id)
		_build_room(id, Vector2(2600 + index * 600, 2000))
		index += 1
	_build_mine()

func _rect(parent: Node, rect: Rect2, color: Color, z: int = 0) -> Polygon2D:
	var shape := Polygon2D.new()
	shape.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	shape.color = color
	shape.z_index = z
	parent.add_child(shape)
	return shape

func _wall(parent: Node, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()
	body.add_child(shape)
	parent.add_child(body)

func _label(parent: Node, text: String, pos: Vector2, width: float, font_size: int) -> void:
	var label := Label.new()
	label.z_index = 4
	label.text = text
	label.position = pos
	label.size.x = width
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color("283629"))
	parent.add_child(label)

func _build_exterior(id: String) -> void:
	var data: Dictionary = SERVICES[id]
	var house := load(data["house"]).instantiate() as Node2D
	house.name = "Local_" + id
	house.position = data["position"]
	add_child(house)
	var door := Interaction.new()
	door.name = "Entrada_" + id
	door.position = house.position + Vector2(70 if id != "smith" else 90, 156)
	door.prompt = "E · Entrar a " + str(data["title"]).to_lower()
	door.action = enter_room.bind(id)
	add_child(door)
	doors[id] = door
	_rect(house, Rect2(14, 60, 104 if id != "smith" else 144, 18), Color("433b2d"), 2)
	_label(house, data["title"], Vector2(12, 62), 108 if id != "smith" else 148, 10)
	_rect(self, Rect2(door.position + Vector2(-18, 12), Vector2(36, 35)), Color("c1aa78"), -1)

func _build_room(id: String, origin: Vector2) -> void:
	var room := Node2D.new()
	room.name = "Interior_" + id
	room.position = origin
	add_child(room)
	rooms[id] = room
	_rect(room, Rect2(-400, -400, 1248, 1088), Color("172522"), -5)
	_rect(room, Rect2(0, 0, 448, 288), Color("71523c"), -3)
	for y in range(32, 280, 16):
		for x in range(8, 440, 32):
			_rect(room, Rect2(x, y, 31, 15), Color("98734c") if int(x / 32 + y / 16) % 2 == 0 else Color("a78055"), -2)
	_rect(room, Rect2(0, 0, 448, 34), Color("d0bd94"))
	_rect(room, Rect2(8, 34, 432, 4), SERVICES[id]["color"])
	for wall in [Rect2(0, 0, 448, 36), Rect2(0, 0, 8, 288), Rect2(440, 0, 8, 288), Rect2(0, 280, 448, 8)]:
		_wall(room, wall)
	_rect(room, Rect2(140, 158, 168, 74), SERVICES[id]["color"], -1)
	_rect(room, Rect2(146, 164, 156, 62), Color("485848"), -1)
	_label(room, SERVICES[id]["title"], Vector2(70, 12), 308, 13)
	# Estantes; su contenido distingue cada establecimiento.
	for x in [24, 336]:
		_rect(room, Rect2(x, 44, 86, 94), Color("503d2f"))
		_wall(room, Rect2(x, 44, 86, 94))
		for y in [60, 88, 116]:
			_rect(room, Rect2(x + 4, y + 12, 78, 4), Color("c19a65"))
			for k in range(6):
				var color: Color = [Color("9b6352"), Color("719194"), Color("c7ae6b")][k % 3]
				if id == "library":
					_rect(room, Rect2(x + 7 + k * 12, y - k % 3, 8, 13 + k % 3), color)
				elif id == "remedies":
					_rect(room, Rect2(x + 9 + k * 12, y, 7, 11), Color("86a78c"))
					_rect(room, Rect2(x + 10 + k * 12, y - 3, 5, 3), Color("e0cf9e"))
				elif id == "food":
					_rect(room, Rect2(x + 7 + k * 12, y + 4, 10, 8), Color("e1b66e"))
				else:
					_rect(room, Rect2(x + 10 + k * 12, y, 3, 13), Color("bfa17a"))
					_rect(room, Rect2(x + 6 + k * 12, y, 11, 5), Color("9ea5a7"))
	_rect(room, Rect2(158, 62, 132, 28), Color("563c2d"))
	_rect(room, Rect2(158, 62, 132, 7), Color("c19a65"))
	_wall(room, Rect2(158, 62, 132, 28))
	if id == "library":
		for x in [172, 208, 244]:
			_rect(room, Rect2(x, 70, 25, 14), Color("ecdfb7"))
			_rect(room, Rect2(x + 12, 70, 1, 14), Color("a28860"))
	elif id == "smith":
		_rect(room, Rect2(44, 178, 54, 50), Color("575354"))
		_rect(room, Rect2(54, 190, 34, 28), Color("3e3030"))
		_rect(room, Rect2(61, 201, 20, 15), Color("d16b3e"))
		_rect(room, Rect2(67, 197, 8, 17), Color("edb560"))
		_wall(room, Rect2(44, 178, 54, 50))
	var npc := Interaction.new()
	npc.name = "Encargado_" + id
	npc.position = Vector2(224, 110)
	npc.prompt = "E · Hablar con " + str(SERVICES[id]["npc"]).split(" · ")[0]
	npc.action = talk.bind(id)
	var sprite := Sprite2D.new()
	preload("res://npc_appearance.gd").apply(sprite, {"library": 5, "food": 6, "remedies": 7, "smith": 8}[id])
	npc.add_child(sprite)
	room.add_child(npc)
	merchants[id] = npc
	_label(room, SERVICES[id]["npc"], Vector2(134, 132), 180, 9)
	var exit_door := Interaction.new()
	exit_door.name = "Salida_" + id
	exit_door.position = Vector2(224, 266)
	exit_door.prompt = "E · Volver al pueblo"
	exit_door.action = leave_room.bind(id)
	room.add_child(exit_door)
	exits[id] = exit_door
	_rect(room, Rect2(202, 259, 44, 20), Color("d2bb86"), -1)
	_label(room, "SALIDA", Vector2(184, 264), 80, 8)

func enter_room(player: CharacterBody2D, id: String) -> void:
	player.global_position = rooms[id].global_position + Vector2(224, 224)
	player.velocity = Vector2.ZERO
	_update_room(player)
	GameSession.save_game()

func leave_room(player: CharacterBody2D, id: String) -> void:
	player.global_position = doors[id].global_position + Vector2(0, 40)
	player.velocity = Vector2.ZERO
	_update_room(player)
	GameSession.save_game()

func talk(_player: CharacterBody2D, id: String) -> void:
	ui.open_service(id)

func room_at(pos: Vector2) -> String:
	for id in rooms:
		if Rect2(rooms[id].global_position, Vector2(448, 288)).has_point(pos):
			return id
	return ""

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if is_instance_valid(player):
		_update_room(player)

func _update_room(player: CharacterBody2D) -> void:
	active_room = room_at(player.global_position)
	player.set_meta("inside_service", not active_room.is_empty())
	if active_room == camera_room:
		return
	camera_room = active_room
	var camera := player.get_node_or_null("Camera2D2") as Camera2D
	if camera == null:
		return
	if active_room.is_empty():
		camera.position = original_camera_position
		camera.limit_left = -10000000
		camera.limit_top = -10000000
		camera.limit_right = 10000000
		camera.limit_bottom = 10000000
	else:
		var origin: Vector2 = rooms[active_room].global_position
		camera.position = Vector2.ZERO
		camera.limit_left = int(origin.x)
		camera.limit_top = int(origin.y)
		camera.limit_right = int(origin.x + 448)
		camera.limit_bottom = int(origin.y + 288)
	camera.reset_smoothing()

func _build_mine() -> void:
	_rect(self, Rect2(840, 1530, 400, 382), Color("829858"), -3)
	_rect(self, Rect2(730, 1770, 388, 48), Color("c1aa78"), -2)
	_rect(self, Rect2(1054, 1710, 52, 90), Color("c1aa78"), -2)
	_rect(self, Rect2(970, 1570, 224, 160), Color("656666"))
	_rect(self, Rect2(994, 1554, 176, 154), Color("818075"))
	_rect(self, Rect2(1048, 1650, 64, 84), Color("252b2e"), 1)
	for x in [1038, 1112]:
		_rect(self, Rect2(x, 1642, 10, 90), Color("826343"), 2)
	_rect(self, Rect2(1038, 1636, 84, 12), Color("b39566"), 2)
	_wall(self, Rect2(970, 1570, 68, 160))
	_wall(self, Rect2(1122, 1570, 72, 160))
	_wall(self, Rect2(1038, 1570, 84, 66))
	_label(self, "MINA", Vector2(1020, 1590), 120, 14)
	var door := Interaction.new()
	door.position = Vector2(1080, 1738)
	door.prompt = "E · Entrar a la mina"
	door.action = enter_room.bind("mine")
	add_child(door)
	doors["mine"] = door
	var room := Node2D.new()
	room.position = Vector2(5200, 2000)
	room.name = "Interior_mine"
	add_child(room)
	rooms["mine"] = room
	_rect(room, Rect2(-400, -400, 1248, 1088), Color("171b22"), -5)
	_rect(room, Rect2(0, 0, 448, 288), Color("4b4844"), -3)
	for y in range(36, 280, 24):
		for x in range(12, 440, 32):
			_rect(room, Rect2(x, y, 28, 20), Color("57544d") if (x + y) % 3 == 0 else Color("504d48"), -2)
	for wall in [Rect2(0, 0, 448, 32), Rect2(0, 0, 8, 288), Rect2(440, 0, 8, 288), Rect2(0, 280, 448, 8)]:
		_wall(room, wall)
		_rect(room, wall, Color("34383d"))
	_label(room, "MINA · Selecciona tu pico (1–5) y pulsa E cerca de una veta", Vector2(8, 10), 432, 10)
	var ores := ["mineral_hierro", "piedra", "carbon", "mineral_hierro", "piedra", "mineral_hierro", "carbon", "piedra"]
	for i in range(ores.size()):
		var vein := preload("res://mine_vein.gd").new()
		vein.position = Vector2(70 + (i % 4) * 100, 76 + int(i / 4.0) * 84)
		vein.vein_id = "mine_" + str(i)
		vein.ore_id = ores[i]
		room.add_child(vein)
	var exit_door := Interaction.new()
	exit_door.position = Vector2(224, 266)
	exit_door.prompt = "E · Volver al pueblo"
	exit_door.action = leave_room.bind("mine")
	room.add_child(exit_door)
	exits["mine"] = exit_door
	_rect(room, Rect2(202, 259, 44, 20), Color("c1aa78"), -1)
	_label(room, "SALIDA", Vector2(184, 264), 80, 8)
