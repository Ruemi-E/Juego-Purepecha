extends Node2D

var vein_id: String
var ore_id: String
var hint: Label
var next_hit_at: int = 0
var old_empty: bool = false

func _ready() -> void:
 add_to_group("interactables")
 add_to_group("mine_veins")
 hint = Label.new()
 hint.position = Vector2(-65, -43)
 hint.size.x = 130
 hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 hint.add_theme_font_size_override("font_size", 9)
 hint.add_theme_color_override("font_outline_color", Color.BLACK)
 hint.add_theme_constant_override("outline_size", 2)
 add_child(hint)
 var body := StaticBody2D.new()
 var collision := CollisionShape2D.new()
 var shape := CircleShape2D.new()
 shape.radius = 16
 collision.shape = shape
 body.add_child(collision)
 add_child(body)
 queue_redraw()

func state() -> Dictionary:
 var data: Dictionary = GameSession.mine_state.get(vein_id, {"hits": 0, "ready_at": 0.0})
 if float(data.get("ready_at", 0)) > 0 and Time.get_unix_time_from_system() >= float(data["ready_at"]):
  data = {"hits": 0, "ready_at": 0.0}
  GameSession.mine_state[vein_id] = data
 return data

func is_empty() -> bool:
 return float(state().get("ready_at", 0)) > Time.get_unix_time_from_system()

func _process(_delta: float) -> void:
 var player := get_tree().get_first_node_in_group("player") as Node2D
 var empty := is_empty()
 hint.visible = is_instance_valid(player) and player.global_position.distance_to(global_position) <= 54
 hint.text = "Veta agotada · espera" if empty else "E · Minar " + str(Inventory.item_database[ore_id]["name"])
 if empty != old_empty:
  old_empty = empty
  queue_redraw()

func interact(_player: CharacterBody2D) -> void:
 if Time.get_ticks_msec() < next_hit_at:
  return
 next_hit_at = Time.get_ticks_msec() + 350
 if is_empty():
  ItemNotification.show_message("Veta agotada. Se recupera en 90 segundos.")
  return
 var tool: Dictionary = Inventory.active_equipment()
 if tool.is_empty() or int(Inventory.item_database[tool["item_id"]].get("mining_power", 0)) <= 0:
  ItemNotification.show_message("Compra un pico con Tomás y selecciónalo con 1–5.")
  return
 if int(tool["durability"]) <= 0:
  ItemNotification.show_message("Tu pico está roto. Tomás puede repararlo.")
  return
 var data: Dictionary = state()
 data["hits"] = int(data.get("hits", 0)) + int(Inventory.item_database[tool["item_id"]]["mining_power"])
 Inventory.damage_equipment(int(tool["uid"]), 1)
 if data["hits"] >= 3:
  data["ready_at"] = Time.get_unix_time_from_system() + 90.0
  GameSession.mine_state[vein_id] = data
  for i in range(2):
   Inventory.add_item(ore_id)
 else:
  GameSession.mine_state[vein_id] = data
  ItemNotification.show_message("Golpe %d/3 · %s" % [data["hits"], Inventory.item_database[ore_id]["name"]])
 var flash := create_tween()
 modulate = Color("ffe4ae")
 flash.tween_property(self, "modulate", Color.WHITE, 0.2)
 queue_redraw()
 GameSession.save_game()

func _draw() -> void:
 var depleted := is_empty()
 var rock := PackedVector2Array([Vector2(-22, 9), Vector2(-19, -9), Vector2(-7, -20), Vector2(13, -17), Vector2(23, -3), Vector2(19, 12)])
 draw_colored_polygon(rock, Color("4e5157") if depleted else Color("85858b"))
 draw_line(Vector2(-15, -7), Vector2(10, -12), Color("b5b0a2"), 3)
 var color: Color = {"mineral_hierro": Color("c39278"), "piedra": Color("c7c7bd"), "carbon": Color("272b32")}[ore_id]
 if not depleted:
  for point in [Vector2(-11, -3), Vector2(7, 2), Vector2(1, -10)]:
   draw_rect(Rect2(point, Vector2(7, 6)), color)
