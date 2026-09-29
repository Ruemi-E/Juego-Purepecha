extends CanvasLayer

const MapView = preload("res://minimap_view.gd")
var card: PanelContainer
var map_view: Control
var objective: Label
var player: Node2D
var world: Node
var elapsed: float = 0.0
# Exposed state also permits verifying navigation without reading pixels.
var target: Node2D
var navigation_position := Vector2.ZERO
var navigation_hint: String = ""

func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 7
 card = PanelContainer.new()
 card.position = Vector2(8,8)
 card.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var style := StyleBoxFlat.new()
 style.bg_color = Color("292f25")
 style.border_color = Color("b8a577")
 style.set_border_width_all(1)
 style.set_content_margin_all(6)
 card.add_theme_stylebox_override("panel",style)
 add_child(card)
 var column := VBoxContainer.new()
 column.add_theme_constant_override("separation",4)
 card.add_child(column)
 var heading := Label.new()
 heading.text = "PUEBLO                           N ↑"
 heading.add_theme_font_size_override("font_size",9)
 heading.add_theme_color_override("font_color",Color("ead9ad"))
 column.add_child(heading)
 map_view = MapView.new()
 map_view.custom_minimum_size = Vector2(144,104)
 map_view.clip_contents = true
 map_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
 column.add_child(map_view)
 objective = Label.new()
 objective.custom_minimum_size = Vector2(144,44)
 objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 objective.add_theme_font_size_override("font_size",9)
 objective.add_theme_color_override("font_color",Color("fff1ce"))
 column.add_child(objective)
 var legend := Label.new()
 legend.text = "● Tú   ◆ Destino\nQ · Cambiar misión"
 legend.add_theme_font_size_override("font_size",8)
 legend.add_theme_color_override("font_color",Color("ccbfa0"))
 column.add_child(legend)
 QuestManager.changed.connect(refresh)
 refresh()

func _process(delta: float) -> void:
 card.visible = not get_tree().paused
 elapsed += delta
 if elapsed < 0.1:
  return
 elapsed = 0
 refresh()

func _unhandled_input(event: InputEvent) -> void:
 if not get_tree().paused and not event.is_echo() and event.is_action_pressed("cycle_quest"):
  QuestManager.cycle_tracked()
  get_viewport().set_input_as_handled()

func bind_world() -> bool:
 var found = get_tree().get_first_node_in_group("player")
 if not is_instance_valid(found):
  player = null
  world = null
  return false
 if not is_instance_valid(player) or not is_instance_valid(world) or found != player or world != found.get_parent():
  player = found
  world = player.get_parent()
  map_view.configure(world)
 return true

func resolve_target(id: String) -> Node2D:
 var quest: Dictionary = QuestManager.QUESTS[id]
 if QuestManager.progress(id) >= int(quest["amount"]):
  for candidate in get_tree().get_nodes_in_group("interactables"):
   if candidate.get("quest_id") == id and not candidate.is_queued_for_deletion():
    return candidate
 elif quest["item"] == "morral_recado":
  return world.get_node_or_null("NPC")
 else:
  var nearest: Node2D
  var best := INF
  for candidate in get_tree().get_nodes_in_group("interactables"):
   if candidate.get("item_id") != quest["item"] or candidate.is_queued_for_deletion() or not candidate.is_visible_in_tree():
    continue
   var distance: float = player.global_position.distance_squared_to(candidate.global_position)
   if distance < best:
    best = distance
    nearest = candidate
  return nearest
 return null

func refresh() -> void:
 if not is_instance_valid(map_view) or not bind_world():
  return
 map_view.player_position = player.global_position
 var id: String = QuestManager.tracked_id()
 target = null
 map_view.has_target = false
 navigation_hint = ""
 if id.is_empty():
  var all_done: bool = not QuestManager.states.is_empty()
  for quest_id in QuestManager.QUESTS:
   if QuestManager.status(quest_id) != "completed":
    all_done = false
  objective.text = "¡Encargos completados!" if all_done else "Sin misión activa\nHabla con los vecinos para recibir un encargo."
  map_view.queue_redraw()
  return
 var quest: Dictionary = QuestManager.QUESTS[id]
 target = resolve_target(id)
 var count: int = mini(QuestManager.progress(id), int(quest["amount"]))
 var instruction: String
 if count >= int(quest["amount"]):
  instruction = "Entrega a " + str(quest["speaker"]).split(" · ")[0]
 elif quest["item"] == "morral_recado":
  instruction = "Habla con Tátita"
 else:
  instruction = "Recoge: %d/%d" % [count, int(quest["amount"])]
 if is_instance_valid(target):
  navigation_position = target.global_position
  # Stage the crossing: approach, cross fully, then follow the real objective.
  var origin := player.global_position
  if navigation_position.y < 40 and origin.y > 0:
   navigation_position = Vector2(300,160) if origin.y > 144 and absf(origin.x-300)>15 else Vector2(300,0)
   navigation_hint = "Cruza el puente"
  elif navigation_position.y > 120 and origin.y < 160:
   navigation_position = Vector2(300,0) if origin.y < 16 and absf(origin.x-300)>15 else Vector2(300,160)
   navigation_hint = "Cruza el puente"
  map_view.has_target = true
  map_view.navigation_position = navigation_position
 objective.text = str(quest["title"]) + "\n" + instruction
 if not navigation_hint.is_empty():
  objective.text += "\n" + navigation_hint
 elif not is_instance_valid(target):
  objective.text += "\nConsulta el encargo con M."
 map_view.queue_redraw()
