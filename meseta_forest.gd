extends Node2D
const BOUNDS: Rect2 = preload("res://world_catalog.gd").BOUNDS
const OUTER: Rect2 = Rect2(-1088,-672,3312,3520)
const TREES = [preload("res://assets/forest/pino.svg"),preload("res://assets/forest/pino_claro.svg"),preload("res://assets/forest/encino.svg")]
var tree_count := 0
var sides := {"north":0,"south":0,"east":0,"west":0}
var floor_marks: Array[Rect2] = []
func _ready() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 1201026
 var batches: Array = [[],[],[]]
 var landscape := get_parent()
 for y in range(int(OUTER.position.y)+16,int(OUTER.end.y),30):
  for x in range(int(OUTER.position.x)+16,int(OUTER.end.x),34):
   var pos := Vector2(x+rng.randi_range(-10,10),y+rng.randi_range(-9,9))
   if BOUNDS.grow(48).has_point(pos):
    continue
   # Keep water and the eastward river continuation clear of trees.
   if BOUNDS.has_point(pos) and landscape.lake_cells.has(Vector2i(floori(pos.x/16),floori(pos.y/16))):
    continue
   if pos.x > 1750 and pos.y > 24 and pos.y < 170:
    continue
   var kind := rng.randi_range(0,2)
   var scale_factor := rng.randf_range(0.85,1.35)
   batches[kind].append({"position":pos,"scale":scale_factor,"tone":rng.randf_range(0.83,1.03)})
   tree_count += 1
   if pos.y < BOUNDS.position.y: sides.north += 1
   if pos.y > BOUNDS.end.y: sides.south += 1
   if pos.x < BOUNDS.position.x: sides.west += 1
   if pos.x > BOUNDS.end.x: sides.east += 1
   floor_marks.append(Rect2(pos+Vector2(12,3),Vector2(8,3)))
 for kind in range(3):
  var instance := MultiMeshInstance2D.new()
  instance.name = ["Pinos","PinosClaros","Encinos"][kind]
  instance.z_index = -1
  instance.texture = TREES[kind]
  var mesh := QuadMesh.new()
  mesh.size = TREES[kind].get_size()
  var multimesh := MultiMesh.new()
  multimesh.transform_format = MultiMesh.TRANSFORM_2D
  multimesh.use_colors = true
  multimesh.mesh = mesh
  multimesh.instance_count = batches[kind].size()
  for i in range(batches[kind].size()):
   var data: Dictionary = batches[kind][i]
   var transform := Transform2D(0,Vector2(data.scale,-data.scale),0,data.position-Vector2(0,mesh.size.y*data.scale*0.45))
   multimesh.set_instance_transform_2d(i,transform)
   multimesh.set_instance_color(i,Color(data.tone,data.tone,data.tone,1))
  instance.multimesh = multimesh
  add_child(instance)
 var floor_layer := Node2D.new()
 floor_layer.name = "SueloBoscoso"
 floor_layer.z_index = -4
 floor_layer.draw.connect(func():
  floor_layer.draw_rect(OUTER,Color("60784a"))
  for rect in floor_marks:
   floor_layer.draw_rect(rect,Color("829157"))
  floor_layer.draw_rect(Rect2(1840,64,384,64),Color("57969a")))
 add_child(floor_layer)
