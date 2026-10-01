extends RefCounted

const FIRST := "pueblo_ribera"
# Add a scene and enable a destination only when its map is implemented.
const TOWNS: Dictionary = {
 "pueblo_ribera": {"name": "Pueblo de la ribera", "scene": "res://World.tscn", "enabled": true, "spawn": Vector2(168, 344), "next": "pueblo_siguiente", "quests": ["hierbas", "lena", "maiz"]},
 "pueblo_siguiente": {"name": "Siguiente pueblo", "scene": "", "enabled": false, "spawn": Vector2.ZERO, "next": "", "quests": []}
}
const BOUNDS := Rect2(-704, -288, 2144, 2368)

static func available(id: String) -> bool:
 return TOWNS.has(id) and TOWNS[id]["enabled"] and not str(TOWNS[id]["scene"]).is_empty() and ResourceLoader.exists(TOWNS[id]["scene"])
