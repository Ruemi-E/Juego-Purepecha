extends Node
signal changed
const PUZZLES := {
 "riego": {"title": "El agua del huerto", "npc": "Nicolás · Hortelano", "reward": 9, "hint": "Abre solo las compuertas 1 y 3 para llevar agua al huerto. La 2 desvía el agua hacia las piedras.", "answer": [1,0,1]},
 "campanas": {"title": "Las campanas del recuerdo", "npc": "María · Tejedora", "reward": 12, "hint": "Toca las campanas en este orden: xanini, chkári, uitsakua. Consulta J si necesitas recordar los significados.", "answer": [2,0,1]},
 "faroles": {"title": "La plaza iluminada", "npc": "Beto · Farolero", "reward": 10, "hint": "Enciende los cinco faroles. Cada palanca cambia su farol y los dos vecinos. El primero y el último también son vecinos.", "answer": [1,1,1,1,1]}
}
var progress: Dictionary = {}
func entry(id: String) -> Dictionary:
 if not progress.has(id):
  progress[id] = {"accepted":false,"solved":false,"paid":false,"values":([0,0,0,0,0] if id == "faroles" else [0,0,0]),"sequence":[]}
 return progress[id]
func talk(id: String) -> String:
 var data: Dictionary = entry(id)
 var spec: Dictionary = PUZZLES[id]
 data.accepted = true
 if data.solved and not data.paid:
  data.paid = true
  Economia.anadir_bronce(spec.reward)
  changed.emit()
  GameSession.save_game()
  return "%s: ¡Lo resolviste! Recibes %d monedas de bronce." % [spec.npc,spec.reward]
 changed.emit()
 GameSession.save_game()
 return str(spec.npc) + ": " + ("Gracias por ayudar al pueblo." if data.paid else str(spec.hint) + "\nUsa E junto a cada mecanismo. Vuelve conmigo cuando termines.")
func operate(id: String, index: int) -> void:
 var data: Dictionary = entry(id)
 if not data.accepted:
  ItemNotification.show_message("Habla primero con " + str(PUZZLES[id].npc).split(" · ")[0])
  return
 if data.solved:
  ItemNotification.show_message("Puzzle resuelto. Vuelve con el vecino.")
  return
 if id == "campanas":
  data.sequence.append(index)
  var step: int = data.sequence.size()-1
  if index != PUZZLES[id].answer[step]:
   data.sequence.clear()
   ItemNotification.show_message("La melodía no coincide. Empieza de nuevo.")
  elif data.sequence.size() == 3:
   data.solved = true
  else:
   ItemNotification.show_message("Nota correcta · %d/3" % data.sequence.size())
 else:
  data.values[index] = 1-int(data.values[index])
  if id == "faroles":
   var next: int = (index+1)%5
   data.values[next] = 1-int(data.values[next])
   var previous: int = (index+4)%5
   data.values[previous] = 1-int(data.values[previous])
  data.solved = data.values == PUZZLES[id].answer
 if data.solved:
  ItemNotification.show_message("¡Puzzle resuelto! Vuelve por tu recompensa.")
 changed.emit()
 GameSession.save_game()
func reset_puzzle(id: String) -> void:
 var data: Dictionary = entry(id)
 if data.solved:
  return
 data.values = [0,0,0] if id != "faroles" else [0,0,0,0,0]
 data.sequence = []
 changed.emit()
 GameSession.save_game()
