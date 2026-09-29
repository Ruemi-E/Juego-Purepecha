extends Area2D

@export var item_id: String = "hierbas_medicinales"
@export var icon_texture: Texture2D
@export var icon_region: Rect2 = Rect2(32, 16, 16, 16)
var collected: bool = false

func _ready() -> void:
 add_to_group("interactables")
 if icon_texture != null:
  $Sprite2D.texture = icon_texture
 $Sprite2D.region_rect = icon_region
 $Pista.hide()

func interact(_player: CharacterBody2D) -> void:
 if collected:
  return
 collected = true
 remove_from_group("interactables")
 Inventory.add_item(item_id)
 queue_free()

func _on_range_entered(body: Node2D) -> void:
 if body.is_in_group("player"):
  $Pista.show()

func _on_range_exited(body: Node2D) -> void:
 if body.is_in_group("player"):
  $Pista.hide()
