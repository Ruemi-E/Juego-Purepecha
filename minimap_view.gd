extends Control

var map_scale: float = 0.16
var overview := false
const ROAD: Color = Color("d9bd83")
const HOUSE: Color = Color("ac7653")
const WATER: Color = Color("57969a")
var features: Array[Dictionary] = []
var service_markers: Array[Dictionary] = []
var player_position := Vector2.ZERO
var navigation_position := Vector2.ZERO
var has_target: bool = false

func configure(world: Node) -> void:
 features.clear()
 service_markers.clear()
 var services = world.get_node_or_null("VillageServices")
 if services != null:
  add_box(Vector2(344, 1180), Vector2(80, 680), ROAD)
  for id in services.SERVICES:
   var data: Dictionary = services.SERVICES[id]
   add_box(data["position"] + Vector2(8, 80), Vector2(112, 56), HOUSE)
   service_markers.append({"position": services.doors[id].global_position, "letter": {"library": "B", "food": "C", "remedies": "R", "smith": "H"}[id], "color": data["color"], "name": data["title"]})
  add_box(Vector2(730, 1770), Vector2(388, 48), ROAD)
  add_box(Vector2(970, 1570), Vector2(224, 160), Color("656666"))
  service_markers.append({"position": services.doors["mine"].global_position, "name": "Mina", "letter": "M", "color": Color("ded0b7")})
 var landscape = world.get_node_or_null("WorldLandscape")
 if landscape != null:
  for rect in landscape.map_features:
   add_box(rect.position, rect.size, WATER)
  service_markers.append({"position": landscape.exit_gate.global_position, "name": "Salida del pueblo", "letter": "S", "color": Color("ffe3a3")})
 var district = world.get_node_or_null("AdventureDistrict")
 if district != null:
  for pos in district.house_positions:
   add_box(pos + Vector2(8,80),Vector2(112,56),HOUSE)
   service_markers.append({"position":pos+Vector2(72,180),"name":"Vecino · " + (["Nicolás · Hortelano","María · Tejedora","Beto · Farolero","Adrián · Pescador"][district.house_positions.find(pos)]),"letter":"N","color":Color("ffe3a3")})
  for spot in world.get_tree().get_nodes_in_group("fishing_spots"):
   service_markers.append({"position":spot.global_position,"name":"Lugar de pesca","letter":"P","color":Color("9edce6")})
 var tiles = world.get_node_or_null("TileMap")
 if tiles != null:
  for layer in [2, 3, 5]:
   for cell in tiles.get_used_cells(layer):
    add_box(tiles.to_global(tiles.map_to_local(cell)) - Vector2(4,4), Vector2(8,8), HOUSE)
  for cell in tiles.get_used_cells(4):
   if tiles.get_cell_source_id(4, cell) in [0, 2, 4]:
    add_box(tiles.to_global(tiles.map_to_local(cell)) - Vector2(4,4), Vector2(8,8), ROAD)
 for child in world.get_children():
  var walls = child.get_node_or_null("Colision/Paredes")
  if walls is CollisionPolygon2D:
   add_polygon(walls, HOUSE)
 var river = world.get_node_or_null("PuebloEntorno/Rio")
 if river != null:
  for child in river.get_children():
   if child is Sprite2D:
    add_box(child.global_position, child.region_rect.size, WATER)
 var bridge = world.get_node_or_null("PuebloEntorno/Puente/Vigas")
 if bridge is Polygon2D:
  add_polygon(bridge, Color("e6c892"))

func add_box(pos: Vector2, extent: Vector2, color: Color) -> void:
 features.append({"rect": Rect2(pos, extent), "color": color})

func add_polygon(node: Node2D, color: Color) -> void:
 var points: PackedVector2Array = node.polygon
 if points.is_empty():
  return
 var bounds := Rect2(node.to_global(points[0]), Vector2.ZERO)
 for point in points:
  bounds = bounds.expand(node.to_global(point))
 features.append({"rect": bounds, "color": color})

func map_point(world_position: Vector2) -> Vector2:
 return size * 0.5 + (world_position - (preload("res://world_catalog.gd").BOUNDS.get_center() if overview else player_position)) * map_scale

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO, size), Color("63774b"))
 var view := Rect2(Vector2.ZERO, size)
 for feature in features:
  var source: Rect2 = feature["rect"]
  var rect := Rect2(map_point(source.position), source.size * map_scale)
  if rect.intersects(view):
   draw_rect(rect, feature["color"])
 for service in service_markers:
  var pos: Vector2 = map_point(service["position"])
  if view.grow(-7).has_point(pos):
   draw_circle(pos, 6, Color("23342c"))
   draw_string(ThemeDB.fallback_font, pos + Vector2(-3, 3), service["letter"], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, service["color"])
 var center := map_point(player_position)
 if MapRoute.active:
  for i in range(1,MapRoute.points.size()):
   draw_line(map_point(MapRoute.points[i-1]),map_point(MapRoute.points[i]),Color("95e9f5"),2)
  var pin := map_point(MapRoute.destination)
  draw_circle(pin,5,Color("153846"))
  draw_circle(pin,3,Color("95e9f5"))
  if not overview and not view.grow(-9).has_point(pin):
   var guide := pin
   for point in MapRoute.points:
    guide = map_point(point)
    if not view.grow(-9).has_point(guide):
     break
   var direction := (guide-center).normalized()
   var inset := size*0.5-Vector2(9,9)
   var delta := guide-center
   var factor := maxf(1.0,maxf(absf(delta.x)/inset.x,absf(delta.y)/inset.y))
   var tip := center+delta/factor
   draw_colored_polygon(PackedVector2Array([tip+direction*5,tip-direction*4+direction.orthogonal()*4,tip-direction*4-direction.orthogonal()*4]),Color("95e9f5"))
 if has_target and not overview:
  var delta := (navigation_position - player_position) * map_scale
  var inset := size * 0.5 - Vector2(9,9)
  var factor: float = maxf(1.0, maxf(absf(delta.x) / inset.x, absf(delta.y) / inset.y))
  var marker := center + delta / factor
  draw_dashed_line(center, marker, Color(1,0.86,0.34,0.65), 1, 4)
  if factor > 1:
   var direction := delta.normalized()
   var side := direction.orthogonal()
   draw_colored_polygon(PackedVector2Array([marker+direction*5,marker-direction*4+side*4,marker-direction*4-side*4]),Color("ffda59"))
  else:
   draw_circle(marker,5,Color("30291c"))
   draw_colored_polygon(PackedVector2Array([marker+Vector2(0,-4),marker+Vector2(4,0),marker+Vector2(0,4),marker+Vector2(-4,0)]),Color("ffda59"))
 if overview and has_target:
  draw_circle(map_point(navigation_position),4,Color("ffda59"))
 draw_circle(center,4,Color("173c46"))
 draw_circle(center,2.5,Color("91f2ff"))
 draw_rect(view,Color("cfb985"),false,1)

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_STOP
 clip_contents = true
func _process(_delta: float) -> void:
 queue_redraw()
func _get_tooltip(at_position: Vector2) -> String:
 for service in service_markers:
  if map_point(service.position).distance_to(at_position) <= 9:
   return str(service.get("name","Lugar del pueblo"))
 return "Clic: fijar ruta · Clic derecho: borrar" + ("\n" + MapRoute.status if not MapRoute.status.is_empty() else "")
func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed:
  if event.button_index == MOUSE_BUTTON_RIGHT:
   MapRoute.clear_route()
   accept_event()
  elif event.button_index == MOUSE_BUTTON_LEFT:
   var pos: Vector2 = (event.position-size*0.5)/map_scale + (preload("res://world_catalog.gd").BOUNDS.get_center() if overview else player_position)
   for service in service_markers:
    if map_point(service.position).distance_to(event.position) <= 9:
     pos = service.position
     break
   if not MapRoute.set_destination(pos,player_position):
    ItemNotification.show_message("Elige un destino accesible dentro del pueblo")
   accept_event()
