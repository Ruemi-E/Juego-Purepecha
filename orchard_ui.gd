extends CanvasLayer
const UI = preload("res://modal_ui.gd")
const Images = preload("res://item_images.gd")
const Words = preload("res://orchard_words.gd")
var overlay: Control
var column: VBoxContainer
var opened := false
var mode := ""
var feedback := ""
func _ready() -> void:
 layer = 18
 process_mode = Node.PROCESS_MODE_ALWAYS
func open_person(person: String) -> void:
 if get_tree().paused or opened:
  return
 mode = person
 feedback = ""
 opened = true
 get_tree().paused = true
 render()
func render() -> void:
 if is_instance_valid(overlay):
  remove_child(overlay)
  overlay.queue_free()
 var titles := {"teacher":"AMALIA · AULA DE LA HUERTA", "farmer":"JACINTO · CUIDADOR DE LOS FRUTALES", "shop":"CELIA · MERCADO DE LAS HUERTAS", "study":"CUADERNO · HUERTAS Y MERCADO"}
 var ui := UI.build(self,titles[mode],570)
 overlay = ui.overlay
 column = ui.column
 match mode:
  "teacher": teacher()
  "farmer": farmer()
  "shop": shop()
  "study": study()
 if not feedback.is_empty():
  UI.label(column,feedback,10)
 var actions := HBoxContainer.new()
 column.add_child(actions)
 if mode != "study":
  UI.button(actions,"Estudiar palabras",func(): mode="study"; feedback=""; render())
 UI.button(actions,"Volver al pueblo · Esc",close).grab_focus()
func picture_button(parent: Node, id: String, text: String, action: Callable) -> Button:
 var button := UI.button(parent,text,action)
 button.icon = Images.icon(id)
 button.expand_icon = true
 button.add_theme_constant_override("icon_max_width",28)
 button.alignment = HORIZONTAL_ALIGNMENT_LEFT
 return button
func teacher() -> void:
 UI.label(column,"Bienvenido a las huertas, un pueblo inspirado en la región de Uruapan. Aquí practicamos frutos, cantidades y compras.",12)
 if OrchardState.stage == 0:
  var id: String = ["aguacate","durazno"][mini(OrchardState.recognition,1)]
  UI.label(column,"Lección 1 · Reconoce la imagen de: " + str(Words.ENTRIES[id].word),16)
  for fruit in ["durazno","aguacate","calabaza"]:
   picture_button(column,fruit,"Elegir esta imagen",func():
    feedback = "¡Bien! Has reconocido la palabra." if OrchardState.answer_recognition(fruit) else "Observa el dibujo y consulta las palabras. Puedes intentarlo otra vez."
    render())
 elif OrchardState.stage == 3:
  var prompts := ["¿Qué significa turasu?", "¿Qué cantidad indica tsimani?", "¿Qué significa piáni?"]
  var choices := [["aguacate","durazno","calabaza"],["tres","uno","dos"],["recolectar","comprar","dinero"]]
  UI.label(column,"Lección 4 · Recuerda sin dibujos (%d/3)" % OrchardState.recall,14)
  UI.label(column,prompts[OrchardState.recall],16)
  for id in choices[OrchardState.recall]:
   UI.button(column,Words.ENTRIES[id].meaning,func():
    feedback = "¡Correcto!" if OrchardState.answer_recall(id) else "Revisa el cuaderno y prueba otra vez."
    render())
 else:
  UI.label(column,OrchardState.objective(),14)
  UI.label(column,"Primero reconocemos imágenes; después contamos la cosecha y atendemos pedidos. Al final recordamos sin dibujos. J abre tu diccionario.")
func farmer() -> void:
 UI.label(column,"Ma = uno · Tsimani = dos · Tanimu = tres",16)
 UI.label(column,"Tánani: juntar, reunir, recolectar. Busca kupanda y turasu en las huertas al norte. Pulsa E cerca de cada tronco; cada árbol maduro da una fruta.")
 UI.label(column,OrchardState.objective(),13)
 if OrchardState.stage == 1:
  var b := UI.button(column,"Mostrar mi cosecha · 4 bronces",func():
   feedback = "¡Cosecha contada! Celia espera tus pedidos en el mercado." if OrchardState.finish_harvest() else "Cosecha al menos dos aguacates y tres duraznos. El minimapa indica los frutales."
   render())
  b.disabled = int(OrchardState.picked.get("aguacate",0)) < 2 or int(OrchardState.picked.get("durazno",0)) < 3
func shop() -> void:
 UI.label(column,"Piáni = comprar · Precios por unidad en bronce · Monedas en I.",11)
 if OrchardState.stage == 2:
  var request: Dictionary = OrchardState.ORDERS[OrchardState.order]
  UI.label(column,"Pedido %d/2 · %s · Cantidad: %s" % [OrchardState.order+1,Words.ENTRIES[request.fruit].word,request.number],13)
  var amounts := HBoxContainer.new()
  column.add_child(amounts)
  for amount in [1,2,3]:
   UI.button(amounts,"Vender %d" % amount,func():
    feedback = "¡Pedido correcto y vendido!" if OrchardState.sell_order(amount) else "Revisa la cantidad y tus frutas; no se consumió nada."
    render())
 var scroll := ScrollContainer.new()
 scroll.custom_minimum_size.y = 100
 column.add_child(scroll)
 var stock := VBoxContainer.new()
 stock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(stock)
 for id in ["aguacate","durazno","calabaza","cebolla","itsï","kurhinda"]:
  var data: Dictionary = Inventory.item_database[id]
  picture_button(stock,id,"Comprar %s · %d" % [data.purepecha,data.price],func():
   feedback = preload("res://shop_transactions.gd").purchase("food",id)
   render()).disabled = Economia.total_bronce() < int(data.price)
 for id in ["aguacate","durazno","calabaza","cebolla"]:
  var data: Dictionary = Inventory.item_database[id]
  picture_button(stock,id,"Vender %s · %d · Llevas %d" % [data.purepecha,data.sell_price,Inventory.items.count(id)],func():
   feedback = preload("res://shop_transactions.gd").sell_fish(id)
   render()).disabled = not Inventory.has_item(id)
func study() -> void:
 var scroll := ScrollContainer.new()
 scroll.custom_minimum_size.y = 160
 column.add_child(scroll)
 var list := VBoxContainer.new()
 list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(list)
 for id in Words.ENTRIES:
  var entry: Dictionary = Words.ENTRIES[id]
  var row := HBoxContainer.new()
  list.add_child(row)
  var icon := TextureRect.new()
  icon.texture = Images.icon(entry.icon)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.custom_minimum_size = Vector2(26,26)
  row.add_child(icon)
  UI.label(row,"%s · %s" % [entry.word,entry.meaning],13).size_flags_horizontal = Control.SIZE_EXPAND_FILL
 UI.label(column,"INEA Michoacán · Vocabulario práctico bilingüe. Consulta las referencias en J. Las grafías varían entre comunidades.",10)
func close() -> void:
 if not opened:
  return
 opened = false
 overlay.queue_free()
 get_tree().paused = false
 GameSession.save_game()
func _input(event: InputEvent) -> void:
 if opened and not event.is_echo() and event.is_action_pressed("ui_cancel"):
  get_viewport().set_input_as_handled()
  close()
