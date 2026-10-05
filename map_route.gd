extends Node
const BOUNDS: Rect2 = preload("res://world_catalog.gd").BOUNDS
const CELL := 16.0
var active := false
var destination := Vector2.ZERO
var points := PackedVector2Array()
var grid: AStarGrid2D
var world_id := 0
var elapsed := 0.0
var status := ""
func clear_route() -> void:
 active = false
 points.clear()
 status = ""
func _cell(pos: Vector2) -> Vector2i:
 return Vector2i((pos - BOUNDS.position) / CELL)
func _free_near(cell: Vector2i, radius: int = 5) -> Vector2i:
 var best := Vector2i(-1,-1)
 var distance := INF
 for y in range(cell.y-radius,cell.y+radius+1):
  for x in range(cell.x-radius,cell.x+radius+1):
   var p := Vector2i(x,y)
   if grid.is_in_boundsv(p) and not grid.is_point_solid(p) and Vector2(p-cell).length_squared() < distance:
    distance = Vector2(p-cell).length_squared()
    best = p
 return best
func _build(world: Node2D) -> void:
 grid = AStarGrid2D.new()
 grid.region = Rect2i(Vector2i.ZERO,Vector2i(BOUNDS.size / CELL))
 grid.cell_size = Vector2(CELL,CELL)
 grid.offset = BOUNDS.position + Vector2(CELL,CELL)*0.5
 grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
 grid.update()
 var query := PhysicsShapeQueryParameters2D.new()
 var shape := CircleShape2D.new()
 shape.radius = 14.0
 query.shape = shape
 query.collision_mask = 1
 var player := get_tree().get_first_node_in_group("player") as CollisionObject2D
 if is_instance_valid(player):
  query.exclude = [player.get_rid()]
 var space := world.get_world_2d().direct_space_state
 for y in range(grid.region.size.y):
  for x in range(grid.region.size.x):
   var cell := Vector2i(x,y)
   query.transform = Transform2D(0,grid.get_point_position(cell))
   grid.set_point_solid(cell,not space.intersect_shape(query,1).is_empty())
 world_id = world.get_instance_id()
func set_destination(pos: Vector2, origin: Vector2) -> bool:
 var world := get_tree().current_scene as Node2D
 if not is_instance_valid(world) or not BOUNDS.has_point(pos):
  return false
 var landscape := world.get_node_or_null("WorldLandscape")
 if landscape == null or not landscape.landscape_ready:
  return false
 if grid == null or world_id != world.get_instance_id():
  _build(world)
 var start := _free_near(_cell(origin))
 var end := _free_near(_cell(pos),3)
 if start.x < 0 or end.x < 0:
  status = "Elige un lugar accesible"
  return false
 var path := grid.get_point_path(start,end)
 if path.is_empty():
  status = "No hay una ruta accesible hasta ese lugar"
  return false
 destination = grid.get_point_position(end)
 points = path
 active = true
 status = "Ruta fijada · clic derecho para quitar"
 return true
func _process(delta: float) -> void:
 if not active or get_tree().paused:
  return
 elapsed += delta
 if elapsed < 0.6:
  return
 elapsed = 0.0
 var player := get_tree().get_first_node_in_group("player") as Node2D
 if not is_instance_valid(player):
  clear_route()
  return
 if player.get_meta("inside_service",false):
  return
 if player.global_position.distance_to(destination) < 24:
  clear_route()
  ItemNotification.show_message("Llegaste al destino de tu ruta")
  return
 var start := _free_near(_cell(player.global_position))
 if start.x >= 0:
  points = grid.get_point_path(start,_cell(destination))
