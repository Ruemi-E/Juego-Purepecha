extends "res://service_interaction.gd"
var fruit_id := "aguacate"
var tree_id := ""
var fruits: Array[Sprite2D] = []
var elapsed := 0.0
func _ready() -> void:
 prompt = "E · " + str(Inventory.item_database[fruit_id].purepecha)
 floating_name = true
 super._ready()
 action = pick
 var body := StaticBody2D.new()
 var collision := CollisionShape2D.new()
 var shape := CircleShape2D.new()
 shape.radius = 8
 collision.shape = shape
 body.add_child(collision)
 add_child(body)
 var crown := Sprite2D.new()
 crown.texture = preload("res://assets/orchards/fruit_tree.svg")
 crown.position = Vector2(0,-34)
 crown.z_index = 1
 add_child(crown)
 for pos in [Vector2(-18,-40),Vector2(13,-56),Vector2(20,-30),Vector2(-6,-26)]:
  var fruit := Sprite2D.new()
  fruit.texture = preload("res://item_images.gd").icon(fruit_id)
  fruit.scale = Vector2(0.18,0.18)
  fruit.position = pos
  fruit.z_index = 2
  add_child(fruit)
  fruits.append(fruit)
 update_fruits()
func _process(delta: float) -> void:
 super._process(delta)
 elapsed += delta
 if elapsed > 1:
  elapsed = 0
  update_fruits()
func update_fruits() -> void:
 var ready_now := OrchardState.ripe(tree_id)
 for fruit in fruits:
  fruit.visible = ready_now
 hint.text = "E · %s · Recolectar" % Inventory.item_database[fruit_id].purepecha if ready_now else "Fruto creciendo · %ds" % maxi(0,ceili(float(OrchardState.harvests.get(tree_id,0))-Time.get_unix_time_from_system()))
func pick(_player: CharacterBody2D = null) -> void:
 if OrchardState.harvest(tree_id,fruit_id):
  ItemNotification.show_message("%s · %s +1" % [Inventory.item_database[fruit_id].purepecha,Inventory.item_database[fruit_id].name])
 else:
  ItemNotification.show_message("Este árbol volverá a dar fruta cuando termine de madurar.")
 update_fruits()
