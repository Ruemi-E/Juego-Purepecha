extends Node2D
const Interaction = preload("res://service_interaction.gd")
var house_positions: Array[Vector2] = []
var puzzle_positions: Dictionary = {}
func _ready() -> void:
 var i := 0
 for id in AdventureState.PUZZLES:
  var base := Vector2(1490,520+i*480)
  house_positions.append(base)
  var house: Node2D = load("res://CasaAdobeChica.tscn" if i != 1 else "res://CasaTaller.tscn").instantiate()
  house.position = base
  add_child(house)
  var npc := Interaction.new()
  npc.position = base+Vector2(72,185)
  npc.prompt = "E · Hablar con " + str(AdventureState.PUZZLES[id].npc).split(" · ")[0]
  npc.action = func(_player): DialogueManager.start_dialogue(AdventureState.talk(id))
  _person(npc,2 if i==0 else (3 if i==1 else 8),str(AdventureState.PUZZLES[id].npc))
  add_child(npc)
  var positions: Array[Vector2] = []
  for k in range(5 if id == "faroles" else 3):
   var mechanism := preload("res://puzzle_mechanism.gd").new()
   mechanism.position = base+Vector2(24+k*(48 if id == "faroles" else 88),280)
   mechanism.puzzle_id = id
   mechanism.index = k
   add_child(mechanism)
   positions.append(mechanism.position)
  puzzle_positions[id] = positions
  var reset := Interaction.new()
  reset.position = base+Vector2(248,355)
  reset.prompt = "E · Reiniciar puzzle"
  reset.action = func(_player): AdventureState.reset_puzzle(id)
  add_child(reset)
  _label(reset,"REINICIAR",Vector2(-35,-10))
  i += 1
 # Fisher's cottage close to the shoreline.
 var cabin := preload("res://CasaAdobeChica.tscn").instantiate()
 cabin.position = Vector2(-40,1800)
 add_child(cabin)
 house_positions.append(cabin.position)
 var fisher := Interaction.new()
 fisher.position = Vector2(30,1980)
 fisher.prompt = "E · Hablar con Adrián · Pescador"
 fisher.action = func(_player): DialogueManager.start_dialogue("Adrián: compra una caña con Tomás y anzuelos con Lucía. Equipa la caña en 1–5 y busca los puestos de pesca del lago.\nCada intento usa un anzuelo y desgasta la caña. Pulsa Espacio cuando pique y después detén la marca en verde tres veces. Lucía compra el pescado en su tienda.")
 _person(fisher,0,"Adrián · Pescador")
 add_child(fisher)
 for pos in [Vector2(-160,420),Vector2(-184,850),Vector2(-224,1320)]:
  var spot := Interaction.new()
  spot.position = pos
  spot.prompt = "E · Pescar en el lago"
  spot.action = func(_player): Fishing.open_fishing()
  add_child(spot)
  _label(spot,"PESCA",Vector2(-22,-16))
  spot.add_to_group("fishing_spots")
func _person(parent: Node2D, index: int, title: String) -> void:
 var sprite := Sprite2D.new()
 preload("res://npc_appearance.gd").apply(sprite,index)
 sprite.self_modulate = Color("c3dfed") if index == 2 else Color("eed7bd")
 parent.add_child(sprite)
 _label(parent,title,Vector2(-55,20))
func _label(parent: Node, text: String, pos: Vector2) -> void:
 var label := Label.new()
 label.text = text
 label.position = pos
 label.add_theme_font_size_override("font_size",9)
 label.add_theme_color_override("font_outline_color",Color.BLACK)
 label.add_theme_constant_override("outline_size",2)
 parent.add_child(label)
