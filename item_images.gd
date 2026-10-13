extends RefCounted
static var cache: Dictionary = {}
static func icon(id: String) -> Texture2D:
 var filename := id
 if not cache.has(filename):
  var path := "res://assets/items/" + filename + ".svg"
  cache[filename] = load(path) if ResourceLoader.exists(path) else load("res://assets/items/diccionario.svg")
 return cache[filename]
static func for_word(word: String) -> Texture2D:
 match word.to_lower():
  "tátita", "nánita": return icon("persona")
  "jántani": return icon("caminar")
  "diosï meiamu": return icon("dialogo")
  "jurhijkandani": return icon("derecha")
  "uikixkandani": return icon("izquierda")
 for id in Inventory.item_database:
  if str(Inventory.item_database[id].purepecha).to_lower() == word.to_lower():
   return icon(id)
 return icon("diccionario")
