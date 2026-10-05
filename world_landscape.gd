extends Node2D

const Catalog = preload("res://world_catalog.gd")
const Nature = preload("res://Little Dreamyland - Free Pack/Little Dreamyland - Free Pack/Tileset/Nature_Tileset.png")
const Water = preload("res://Sprout Lands - Sprites - Basic pack/Tilesets/Water.png")
const Plants = preload("res://Sprout Lands - Sprites - Basic pack/Objects/Basic_Plants.png")
const Interaction = preload("res://service_interaction.gd")
const Animal = preload("res://village_animal.gd")
var tiles: TileMap
var rng := RandomNumberGenerator.new()
var lake_cells: Dictionary = {}
var new_paths: Dictionary = {}
var map_features: Array[Rect2] = []
var exit_gate: Node2D
var landscape_ready := false
var tree_count := 0
var plant_count := 0
var shore_points: Array[Vector2] = []

func _ready() -> void:
 add_to_group("world_landscape")
 rng.seed = 927103
 tiles = get_parent().get_node("TileMap")
 _extend_ground()
 _paths()
 _farm()
 _lake()
 _boundaries()
 _gate()
 _decorate_when_physics_ready()

func _extend_ground() -> void:
 var first := tiles.local_to_map(tiles.to_local(Catalog.BOUNDS.position))
 var last := tiles.local_to_map(tiles.to_local(Catalog.BOUNDS.end))
 for y in range(first.y, last.y):
  for x in range(first.x, last.x):
   var cell := Vector2i(x, y)
   if tiles.get_cell_source_id(0, cell) == -1:
    tiles.set_cell(0, cell, 5, Vector2i(rng.randi_range(2, 9), rng.randi_range(11, 13)))

func _path_rect(rect: Rect2) -> void:
 var start := tiles.local_to_map(tiles.to_local(rect.position))
 var end := tiles.local_to_map(tiles.to_local(rect.end))
 for y in range(start.y, end.y):
  for x in range(start.x, end.x):
   new_paths[Vector2i(x, y)] = true

func _paths() -> void:
 for rect in [Rect2(1088, 1984, 40, 160), Rect2(344, 1180, 80, 1140), Rect2(1300, 1040, 460, 64), Rect2(1424, 688, 48, 1576), Rect2(1424, 704, 248, 40), Rect2(1424, 1184, 248, 40), Rect2(1424, 1664, 248, 40), Rect2(0, 1984, 1456, 40), Rect2(144, 1450, 596, 48), Rect2(144, 1770, 970, 48), Rect2(1054, 1710, 52, 108), Rect2(920, 300, 64, 1504), Rect2(848, 1040, 528, 64), Rect2(-124, 360, 196, 40), Rect2(-124, 360, 40, 1120), Rect2(-104, 1450, 264, 48)]:
  _path_rect(rect)
 for id in get_parent().get_node("VillageServices").doors:
  if id != "mine":
   var pos: Vector2 = get_parent().get_node("VillageServices").doors[id].position
   _path_rect(Rect2(pos + Vector2(-18, 8), Vector2(36, 44)))
 for cell in new_paths:
  var left: bool = new_paths.has(cell + Vector2i.LEFT) or tiles.get_cell_source_id(4, cell + Vector2i.LEFT) == 2
  var right: bool = new_paths.has(cell + Vector2i.RIGHT) or tiles.get_cell_source_id(4, cell + Vector2i.RIGHT) == 2
  var up: bool = new_paths.has(cell + Vector2i.UP) or tiles.get_cell_source_id(4, cell + Vector2i.UP) == 2
  var down: bool = new_paths.has(cell + Vector2i.DOWN) or tiles.get_cell_source_id(4, cell + Vector2i.DOWN) == 2
  var col := 0 if not left else (4 if not right else rng.randi_range(1, 3))
  var row := 10 if not up else (13 if not down else rng.randi_range(11, 12))
  tiles.set_cell(4, cell, 2, Vector2i(col, row))

func _lake_edge(y: int) -> int:
 if y < 0:
  return -192 + int((y + 224) / 64.0) * 16
 if y < 128:
  return -96
 if y < 480:
  return -176 - int((y - 128) / 112.0) * 16
 if y < 1056:
  return -224 + int(sin(y * 0.008) * 2) * 16
 if y < 1456:
  return -240 - int((y - 1056) / 96.0) * 16
 return -336 - int((y - 1456) / 32.0) * 32

func _lake() -> void:
 var layer := TileMapLayer.new()
 layer.name = "LagoPatzcuaro"
 layer.z_index = -1
 var set := TileSet.new()
 set.tile_size = Vector2i(16, 16)
 var atlas := TileSetAtlasSource.new()
 atlas.texture = Water
 atlas.texture_region_size = Vector2i(16, 16)
 for x in range(4):
  atlas.create_tile(Vector2i(x, 0))
 set.add_source(atlas, 0)
 layer.tile_set = set
 add_child(layer)
 for y in range(-224, 1648, 16):
  var edge := _lake_edge(y)
  shore_points.append(Vector2(edge + 16, y))
  for x in range(-704, edge, 16):
   lake_cells[Vector2i(x / 16, y / 16)] = true
  _water_wall(Rect2(-704, y, edge + 704, 16))
  map_features.append(Rect2(-704, y, edge + 704, 16))
  # Shore sand uses the same detailed dirt atlas as the village paths.
  for sx in range(edge, edge + 16, 8):
   for sy in range(y, y + 16, 8):
    var cell := tiles.local_to_map(tiles.to_local(Vector2(sx, sy)))
    tiles.set_cell(4, cell, 2, Vector2i(3 if sx == edge else 4, rng.randi_range(11, 12)))
 # Open connection to the existing river behind the initial houses.
 for y in range(48, 112, 16):
  for x in range(-96, -64, 16):
   lake_cells[Vector2i(x / 16, y / 16)] = true
 _water_wall(Rect2(-96, 48, 32, 64))
 map_features.append(Rect2(-96, 48, 32, 64))
 # Extend the existing river to the eastern edge of the bounded map.
 for x in range(976, 1840, 16):
  for y in range(64, 128, 16):
   lake_cells[Vector2i(x / 16, y / 16)] = true
 _water_wall(Rect2(976, 64, 864, 64))
 map_features.append(Rect2(976, 64, 864, 64))
 for cell in lake_cells:
  layer.set_cell(cell, 0, Vector2i(rng.randi_range(0, 3), 0))
 _sign(Vector2(-116, 408), "LAGO DE\nPÁTZCUARO", 100)

func _water_wall(rect: Rect2) -> void:
 _wall(rect, "WaterBoundary")

func _wall(rect: Rect2, body_name: String) -> void:
 var body := StaticBody2D.new()
 body.name = body_name
 var shape := CollisionShape2D.new()
 var box := RectangleShape2D.new()
 box.size = rect.size
 shape.shape = box
 shape.position = rect.get_center()
 body.add_child(shape)
 add_child(body)

func _boundaries() -> void:
 var bounds := Catalog.BOUNDS
 _wall(Rect2(bounds.position - Vector2(24, 24), Vector2(bounds.size.x + 48, 24)), "LimiteNorte")
 _wall(Rect2(bounds.position.x - 24, bounds.end.y, bounds.size.x + 48, 24), "LimiteSur")
 _wall(Rect2(bounds.position.x - 24, bounds.position.y, 24, bounds.size.y), "LimiteOeste")
 _wall(Rect2(bounds.end.x, bounds.position.y, 24, bounds.size.y), "LimiteEste")
 # Dense trees make the physical limits visible. The lake forms the west edge.
 for x in range(-680, 1840, 32):
  _tree(Vector2(x, -260), false)
  _tree(Vector2(x, 2444), false)
 for y in range(-224, 2448, 32):
  if y < 48 or y > 152:
   _tree(Vector2(1820, y), false)
 for x in range(-656, 1800, 56):
  _tree(Vector2(x, 2396), false)

func _gate() -> void:
 exit_gate = Interaction.new()
 exit_gate.name = "SalidaDelPueblo"
 exit_gate.position = Vector2(1350, 1072)
 exit_gate.prompt = "E · Ruta hacia los siguientes pueblos"
 exit_gate.action = Journey.open_route
 add_child(exit_gate)
 _sign(Vector2(1348, 1012), "RUTA DEL VIAJE\nE · Consultar", 124)
 var guide := get_parent().get_node("MisionesPueblo/TiaJuana")
 guide.position = Vector2(1296, 1114)
 _sign(Vector2(888, 1020), "→ SALIDA DEL PUEBLO", 160)

func _sign(pos: Vector2, text: String, width: float) -> void:
 var sign := Label.new()
 sign.text = text
 sign.position = pos - Vector2(width / 2, 0)
 sign.size.x = width
 sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 sign.add_theme_font_size_override("font_size", 10)
 sign.add_theme_color_override("font_color", Color("fff1c7"))
 sign.add_theme_color_override("font_outline_color", Color("403b2a"))
 sign.add_theme_constant_override("outline_size", 3)
 sign.z_index = 3
 add_child(sign)

func _sprite(texture: Texture2D, region: Rect2, pos: Vector2, z: int) -> Sprite2D:
 var sprite := Sprite2D.new()
 sprite.texture = texture
 sprite.region_enabled = true
 sprite.region_rect = region
 sprite.position = pos
 sprite.z_index = z
 add_child(sprite)
 return sprite

func _tree(base: Vector2, solid: bool = true) -> void:
 var region := Rect2(16 if rng.randf() < 0.65 else 48, 16, 32, 48)
 _sprite(Nature, region, base - Vector2(0, 20), 1)
 if solid:
  _wall(Rect2(base - Vector2(5, 4), Vector2(10, 8)), "TroncoNuevo")
 tree_count += 1

func _safe_decor(pos: Vector2, clearance: float) -> bool:
 if Rect2(1024,2080,288,256).has_point(pos):
  return false
 for house_name in ["CasaInicialTatita", "CasaInicialPatio"]:
  var house := get_parent().get_node_or_null(house_name) as Node2D
  if house != null and Rect2(house.position - Vector2(24,24), Vector2(224,200)).has_point(pos):
   return false
 if not Catalog.BOUNDS.grow(-48).has_point(pos) or lake_cells.has(Vector2i(floori(pos.x / 16), floori(pos.y / 16))):
  return false
 if pos.y > 24 and pos.y < 152:
  return false
 var cell := tiles.local_to_map(tiles.to_local(pos))
 for y in range(-3, 4):
  for x in range(-3, 4):
   if tiles.get_cell_source_id(4, cell + Vector2i(x, y)) in [0, 2, 4] or tiles.get_cell_source_id(2, cell + Vector2i(x, y)) >= 0 or tiles.get_cell_source_id(3, cell + Vector2i(x, y)) >= 0:
    return false
 var player := get_tree().get_first_node_in_group("player") as Node2D
 if is_instance_valid(player) and player.global_position.distance_to(pos) < 64:
  return false
 for node in get_tree().get_nodes_in_group("interactables"):
  if node is Node2D and node.global_position.distance_to(pos) < 64:
   return false
 var query := PhysicsShapeQueryParameters2D.new()
 var shape := CircleShape2D.new()
 shape.radius = clearance
 query.shape = shape
 query.transform = Transform2D(0, pos)
 query.collision_mask = 1
 return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _decorate_when_physics_ready() -> void:
 await get_tree().physics_frame
 await get_tree().physics_frame
 _recover_old_position()
 for i in range(850):
  var pos := Vector2(rng.randi_range(-180, 1750), rng.randi_range(-190, 2350)).snapped(Vector2(8, 8))
  if _safe_decor(pos, 30):
   if i % 4 == 0:
    _tree(pos)
   else:
    _sprite(Plants, Rect2(16 if i % 2 == 0 else 32, 16, 16, 16), pos, 0)
    plant_count += 1
 for i in range(0, shore_points.size(), 5):
  var pos: Vector2 = shore_points[i] + Vector2(16, 8)
  if _safe_decor(pos, 9):
   _sprite(Nature, Rect2(176 if i % 2 == 0 else 192, 16, 16, 16), pos, 0)
   plant_count += 1
 for pos in [Vector2(96, 752), Vector2(320, 904), Vector2(780, 1280), Vector2(800, 1450), Vector2(1120, 1232), Vector2(1152, 1280), Vector2(1088, 1320), Vector2(180, 1880), Vector2(240, 1890), Vector2(620, 1900), Vector2(704, 1900), Vector2(1100, 1880)]:
  if _safe_animal(pos):
   var animal := Animal.new()
   animal.species = "cow" if pos.x > 1000 or pos.y > 1890 else "chicken"
   animal.position = pos
   add_child(animal)
 landscape_ready = true

func _safe_animal(pos: Vector2) -> bool:
 var query := PhysicsShapeQueryParameters2D.new()
 var shape := CircleShape2D.new()
 shape.radius = 16
 query.shape = shape
 query.transform = Transform2D(0, pos)
 query.collision_mask = 1
 return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _recover_old_position() -> void:
 var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
 if not is_instance_valid(player):
  return
 var services := get_parent().get_node("VillageServices")
 if not services.room_at(player.global_position).is_empty():
  return
 if not Catalog.BOUNDS.grow(-16).has_point(player.global_position) or not _safe_animal(player.global_position):
  player.global_position = Catalog.TOWNS[Catalog.FIRST]["spawn"]
  player.velocity = Vector2.ZERO
  services._update_room(player)
  GameSession.save_game()

func _farm() -> void:
 # Leave corridors between beds; collectible maize retains its saved node paths.
 for row in range(3):
  for col in range(3):
   var origin := Vector2(1064+col*72,2144+row*56)
   var bed := Polygon2D.new()
   bed.z_index = -1
   bed.polygon = PackedVector2Array([origin,origin+Vector2(56,0),origin+Vector2(56,40),origin+Vector2(0,40)])
   bed.color = Color("826843")
   add_child(bed)
   for line in range(3):
    var furrow := Line2D.new()
    furrow.z_index = -1
    furrow.width = 2
    furrow.default_color = Color("624f38")
    furrow.points = PackedVector2Array([origin+Vector2(3,8+line*12),origin+Vector2(53,8+line*12)])
    add_child(furrow)
   for x in range(3):
    for y in range(2):
     var pos := origin+Vector2(10+x*16,10+y*20)
     if not ((row == 0 or row == 2) and (col == 0 or col == 2) and x == 1):
      _sprite(Plants,Rect2(16 if (col+row)%2==0 else 32,16,16,16),pos,0)
