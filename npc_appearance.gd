extends RefCounted
static func apply(sprite: Sprite2D, index: int) -> void:
 var atlas := AtlasTexture.new()
 atlas.atlas = preload("res://assets/npcs/village_npcs.png")
 atlas.region = Rect2((index % 3) * 32, int(index / 3.0) * 64, 32, 64)
 sprite.texture = atlas
 sprite.scale = Vector2(0.5, 0.5)
 sprite.self_modulate = Color.WHITE
