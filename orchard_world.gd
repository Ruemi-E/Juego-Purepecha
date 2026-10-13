extends Node2D
const Catalog = preload("res://world_catalog.gd")
const Interaction = preload("res://service_interaction.gd")
const FruitTree = preload("res://orchard_tree.gd")
var features: Array[Dictionary] = []
var markers: Array[Dictionary] = []
var paths: Array[Rect2] = []
var buildings: Array[Rect2] = []
var trees: Array[Node2D] = []
var neighbors: Dictionary = {}
var ui: CanvasLayer
var rng := RandomNumberGenerator.new()
func _ready() -> void:
 rng.seed = 640127
 var landscape := preload("res://orchard_landscape.gd").new()
 landscape.name = "WorldLandscape"
 add_child(landscape)
 ui = preload("res://orchard_ui.gd").new()
 add_child(ui)
 ground()
 # A winding central street, terraced orchards and an offset market square.
 for rect in [Rect2(344,180,72,1500),Rect2(344,1160,580,64),Rect2(752,656,64,568),Rect2(40,656,776,56),Rect2(40,256,56,456),Rect2(40,256,360,48),Rect2(760,360,340,48),Rect2(1040,360,60,336),Rect2(360,920,400,56),Rect2(80,1380,336,56)]:
  path(rect)
 path(Rect2(344,1040,204,160))
 path(Rect2(232,1040,120,48))
 house(Vector2(245,1030),0,Vector2(1,1))
 house(Vector2(850,1090),1,Vector2(1.1,1))
 house(Vector2(470,780),2,Vector2(0.85,0.9))
 house(Vector2(580,1330),1,Vector2(1.15,1.1))
 house(Vector2(100,1320),2,Vector2(0.9,0.85))
 house(Vector2(880,880),0,Vector2(0.85,1))
 house(Vector2(730,250),1,Vector2(0.8,0.9))
 # Trees grow in staggered rows with broad harvesting lanes.
 for row in range(3):
  for col in range(4):
   fruit_tree("aguacate",Vector2([140,260,490,610][col]+(row%2)*12,395+row*100),"a_%d_%d" % [row,col])
   fruit_tree("durazno",Vector2([865,980,1170,1290][col]+(row%2)*8,500+row*94),"d_%d_%d" % [row,col])
 # Basalt retaining edges stop short of each access path.
 for rect in [Rect2(110,625,210,12),Rect2(440,625,190,12),Rect2(840,700,440,12),Rect2(840,330,410,12)]:
  stone_wall(rect)
 neighbor("teacher","Amalia · Aula de la huerta",Vector2(245,1090),0,"A")
 neighbor("farmer","Jacinto · Frutales",Vector2(466,655),2,"F")
 neighbor("shop","Celia · Mercado de las huertas",Vector2(895,1194),3,"C")
 # The market canopy and produce boxes distinguish the new shop.
 polygon(Rect2(830,1140,135,18),Color("c08747"),2)
 for x in range(6):
  polygon(Rect2(830+x*22,1140,11,18),Color("ead2a0"),3)
 for i in range(4):
  polygon(Rect2(835+i*31,1165,25,18),Color("845e3c"),0)
  var fruit := Sprite2D.new()
  fruit.texture = preload("res://item_images.gd").icon(["aguacate","durazno","calabaza","cebolla"][i])
  fruit.position = Vector2(847+i*31,1170)
  fruit.scale = Vector2(0.25,0.25)
  add_child(fruit)
 var exit := Interaction.new()
 exit.position = Vector2(380,1600)
 exit.prompt = "E · Camino de regreso a la ribera"
 exit.floating_name = true
 exit.action = Journey.open_route
 add_child(exit)
 neighbors["exit"] = exit
 markers.append({"position":exit.position,"letter":"S","name":"Regreso al pueblo de la ribera","color":Color("f2d38e")})
 var forest := preload("res://meseta_forest.gd").new()
 add_child(forest)
 village_details()
 decoration()
 var bounds := Catalog.BOUNDS
 wall(Rect2(bounds.position-Vector2(20,20),Vector2(bounds.size.x+40,20)))
 wall(Rect2(bounds.position.x-20,bounds.end.y,bounds.size.x+40,20))
 wall(Rect2(bounds.position.x-20,bounds.position.y,20,bounds.size.y))
 wall(Rect2(bounds.end.x,bounds.position.y,20,bounds.size.y))
 var player := preload("res://player.tscn").instantiate()
 player.position = Catalog.TOWNS["pueblo_siguiente"].spawn
 add_child(player)
 var camera := Camera2D.new()
 camera.zoom = Vector2(1.8,1.8)
 player.add_child(camera)
 camera.make_current()
func ground() -> void:
 polygon(Catalog.BOUNDS,Color("73845b"),-5)
 for i in range(3900):
  var pos := Vector2(rng.randf_range(-704,1840),rng.randf_range(-288,2464))
  polygon(Rect2(pos,Vector2(rng.randi_range(2,8),2)),Color("7e8d60") if i%2==0 else Color("6b7c51"),-4)
 for rect in [Rect2(108,315,544,305),Rect2(830,380,472,320)]:
  polygon(rect,Color("81784f"),-3)
  features.append({"rect":rect,"color":Color("4d754d")})
func polygon(rect: Rect2, color: Color, z: int = 0) -> void:
 var shape := Polygon2D.new()
 shape.polygon = PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
 shape.color = color
 shape.z_index = z
 add_child(shape)
func path(rect: Rect2) -> void:
 paths.append(rect)
 polygon(rect,Color("b6a176"),-2)
 features.append({"rect":rect,"color":Color("d1ba88")})
 for i in range(int(rect.get_area()/250)):
  polygon(Rect2(Vector2(rng.randf_range(rect.position.x,rect.end.x-5),rng.randf_range(rect.position.y,rect.end.y-3)),Vector2(5,3)),Color("a18d68"),-1)
func wall(rect: Rect2) -> void:
 var body := StaticBody2D.new()
 var collision := CollisionShape2D.new()
 var box := RectangleShape2D.new()
 box.size = rect.size
 collision.shape = box
 collision.position = rect.get_center()
 body.add_child(collision)
 add_child(body)
func stone_wall(rect: Rect2) -> void:
 polygon(rect,Color("626553"))
 for x in range(int(rect.position.x),int(rect.end.x),18):
  polygon(Rect2(x,rect.position.y+2,14,4),Color("999882"),1)
 wall(rect)
func house(base: Vector2, variant: int, extent: Vector2) -> void:
 var sprite := Sprite2D.new()
 sprite.texture = load("res://assets/orchards/casa_%d.svg" % variant)
 sprite.position = base-Vector2(0,65)*extent
 sprite.scale = extent
 sprite.z_index = 1
 add_child(sprite)
 var footprint := Rect2(base-Vector2(80,137)*extent,Vector2(160,144)*extent)
 buildings.append(footprint)
 features.append({"rect":footprint,"color":Color("b27b54")})
 wall(Rect2(base-Vector2(65,67)*extent,Vector2(130,66)*extent))
func fruit_tree(fruit: String, pos: Vector2, id: String) -> void:
 var tree := FruitTree.new()
 tree.fruit_id = fruit
 tree.tree_id = id
 tree.position = pos
 add_child(tree)
 trees.append(tree)
 features.append({"rect":Rect2(pos-Vector2(17,17),Vector2(34,34)),"color":Color("355c3f")})
 if id.ends_with("0_0"):
  markers.append({"position":pos+Vector2(0,26),"letter":"F","name":"Huerta · " + str(Inventory.item_database[fruit].purepecha),"color":Color("d9e899")})
func neighbor(id: String, title: String, pos: Vector2, appearance: int, letter: String) -> void:
 var npc := Interaction.new()
 npc.position = pos
 npc.prompt = "E · " + title
 npc.floating_name = true
 npc.action = func(_player: CharacterBody2D): ui.open_person(id)
 add_child(npc)
 var sprite := Sprite2D.new()
 preload("res://npc_appearance.gd").apply(sprite,appearance)
 npc.add_child(sprite)
 neighbors[id] = npc
 markers.append({"position":pos,"letter":letter,"name":title,"color":Color("ffe2a0")})
func decoration() -> void:
 for i in range(440):
  var pos := Vector2(rng.randf_range(-650,1760),rng.randf_range(-230,2390))
  var rect := Rect2(pos-Vector2(40,80),Vector2(80,90))
  # Keep the village and every road clear of the entire canopy.
  if Rect2(0,180,1350,1500).intersects(rect):
   continue
  var sprite := Sprite2D.new()
  sprite.texture = preload("res://assets/orchards/fruit_tree.svg")
  sprite.position = pos-Vector2(0,34)
  sprite.modulate = Color("91a280")
  sprite.z_index = 1
  add_child(sprite)
  wall(Rect2(pos-Vector2(5,4),Vector2(10,8)))
func map_data() -> Dictionary:
 return {"features":features,"markers":markers}
func lesson_target() -> Node2D:
 match OrchardState.stage:
  0,3: return neighbors.teacher
  1:
   var needed := "aguacate" if int(OrchardState.picked.get("aguacate",0)) < 2 else ("durazno" if int(OrchardState.picked.get("durazno",0)) < 3 else "")
   if needed.is_empty():
    return neighbors.farmer
   var player := get_tree().get_first_node_in_group("player") as Node2D
   var nearest: Node2D
   var distance := INF
   for tree in trees:
    if tree.fruit_id == needed and OrchardState.ripe(tree.tree_id) and tree.position.distance_to(player.position) < distance:
     nearest = tree
     distance = tree.position.distance_to(player.position)
   return nearest
  2: return neighbors.shop
 return neighbors.teacher

func village_details() -> void:
 # A small communal water basin, seats and planted borders frame the square.
 var basin := Polygon2D.new()
 var basin_points := PackedVector2Array()
 for i in range(8):
  var angle := float(i)*TAU/8.0
  basin_points.append(Vector2(472,1112)+Vector2(cos(angle),sin(angle))*22)
 basin.polygon = basin_points
 basin.color = Color("888a70")
 add_child(basin)
 var water := Polygon2D.new()
 var water_points := PackedVector2Array()
 for i in range(8):
  var angle := float(i)*TAU/8.0
  water_points.append(Vector2(472,1112)+Vector2(cos(angle),sin(angle))*16)
 water.polygon = water_points
 water.color = Color("619797")
 water.z_index = 1
 add_child(water)
 wall(Rect2(454,1094,36,36))
 for pos in [Vector2(458,1050),Vector2(510,1130)]:
  polygon(Rect2(pos,Vector2(24,8)),Color("72543b"),1)
  polygon(Rect2(pos+Vector2(2,8),Vector2(3,5)),Color("4c4635"))
  polygon(Rect2(pos+Vector2(19,8),Vector2(3,5)),Color("4c4635"))
 for i in range(260):
  var pos := Vector2(rng.randf_range(20,1360),rng.randf_range(730,1490))
  var rect := Rect2(pos-Vector2(8,8),Vector2(16,16))
  var clear := true
  for road in paths:
   if road.grow(5).intersects(rect): clear = false
  for house_rect in buildings:
   if house_rect.grow(6).intersects(rect): clear = false
  if not clear: continue
  var plant := Sprite2D.new()
  plant.texture = preload("res://Sprout Lands - Sprites - Basic pack/Objects/Basic_Plants.png")
  plant.region_enabled = true
  plant.region_rect = Rect2(16 if i%3==0 else 32,16,16,16)
  plant.position = pos
  add_child(plant)
