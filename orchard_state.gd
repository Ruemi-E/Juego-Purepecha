extends Node
signal changed
const WORDS = preload("res://orchard_words.gd")
var stage := 0
var recognition := 0
var recall := 0
var harvests: Dictionary = {}
var picked: Dictionary = {}
var order := 0
const ORDERS = [{"fruit":"aguacate", "amount":2, "number":"tsimani"}, {"fruit":"durazno", "amount":3, "number":"tanimu"}]
func restore(data: Dictionary) -> void:
 stage = clampi(int(data.get("stage",0)),0,4)
 recognition = clampi(int(data.get("recognition",0)),0,2)
 recall = clampi(int(data.get("recall",0)),0,3)
 order = clampi(int(data.get("order",0)),0,2)
 harvests = data.get("harvests",{}).duplicate(true)
 picked = data.get("picked",{}).duplicate(true)
 changed.emit()
func snapshot() -> Dictionary:
 return {"stage":stage,"recognition":recognition,"recall":recall,"order":order,"harvests":harvests,"picked":picked}
func commit() -> void:
 changed.emit()
 GameSession.save_game()
func objective() -> String:
 match stage:
  0: return "Nivel 2 · Conoce los frutos\nHabla con Amalia en el aula de la huerta."
  1: return "Nivel 2 · Cuenta tu cosecha\nKupanda: %d/2 · Turasu: %d/3\nE junto a los frutales; vuelve con Jacinto." % [mini(2,int(picked.get("aguacate",0))),mini(3,int(picked.get("durazno",0)))]
  2:
   var request: Dictionary = ORDERS[mini(order,1)]
   return "Nivel 2 · El pedido de Celia\nProducto: %s · Cantidad: %s\nLleva la cosecha al mercado." % [WORDS.ENTRIES[request.fruit].word,request.number]
  3: return "Nivel 2 · Recuerda sin imágenes\nVuelve con Amalia: tres preguntas del mercado."
 return "¡Nivel 2 completado!\nPuedes seguir cosechando, vendiendo y practicando."
func journal() -> String:
 return "[b]HUERTAS · NIVEL 2[/b]    M / Esc: cerrar\n\n" + objective() + "\n\n1. Amalia: reconoce kupanda y turasu. Premio: 3 bronces.\n2. Jacinto: cosecha dos aguacates y tres duraznos. Premio: 4 bronces.\n3. Celia: interpreta y vende dos pedidos por su valor de mercado.\n4. Amalia: recuerda palabras y cantidades sin dibujos. Premio: 5 bronces.\n\nJ: consulta el vocabulario. Los frutos vuelven a madurar tras cinco minutos reales; el tiempo y el progreso se guardan.\nLas palabras y cantidades se presentan por separado: este nivel practica vocabulario, aún no construcción de frases."
func answer_recognition(id: String) -> bool:
 if stage != 0 or recognition >= 2:
  return false
 var expected: String = ["aguacate","durazno"][recognition]
 if id != expected:
  return false
 recognition += 1
 if recognition == 2:
  stage = 1
  Economia.anadir_bronce(3)
 commit()
 return true
func harvest(tree_id: String, fruit: String) -> bool:
 if not fruit in ["aguacate","durazno"] or not ripe(tree_id):
  return false
 harvests[tree_id] = Time.get_unix_time_from_system() + 300.0
 picked[fruit] = int(picked.get(fruit,0)) + 1
 Inventory.add_item(fruit)
 commit()
 return true
func ripe(tree_id: String) -> bool:
 return Time.get_unix_time_from_system() >= float(harvests.get(tree_id,0))
func finish_harvest() -> bool:
 if stage != 1 or int(picked.get("aguacate",0)) < 2 or int(picked.get("durazno",0)) < 3:
  return false
 stage = 2
 Economia.anadir_bronce(4)
 commit()
 return true
func sell_order(quantity: int = -1) -> bool:
 if stage != 2 or order >= 2:
  return false
 var request: Dictionary = ORDERS[order]
 if quantity != int(request.amount):
  return false
 if Inventory.items.count(request.fruit) < int(request.amount):
  return false
 order += 1
 if order == 2:
  stage = 3
 for i in range(int(request.amount)):
  Inventory.remove_item(request.fruit)
 Economia.anadir_bronce(int(request.amount)*int(Inventory.item_database[request.fruit].sell_price))
 commit()
 return true
func answer_recall(answer: String) -> bool:
 if stage != 3 or recall >= 3 or answer != ["durazno","dos","comprar"][recall]:
  return false
 recall += 1
 if recall == 3:
  stage = 4
  Economia.anadir_bronce(5)
 commit()
 return true
