extends CanvasLayer

@onready var panel: Control = $Panel
@onready var item_list: ItemList = $Panel/ItemList
@onready var item_details: RichTextLabel = $Panel/ItemDetails

var is_open: bool = false
var selected_item_id: String = ""

func _ready() -> void:
 panel.hide()
 var coins := $Panel/Dinero
 coins.offset_left = -116
 coins.add_theme_constant_override("separation",4)
 for currency in ["plata","bronce"]:
  var icon := TextureRect.new()
  icon.texture = load("res://assets/ui/moneda_" + currency + ".svg")
  icon.custom_minimum_size = Vector2(16,16)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.tooltip_text = "Monedas de " + currency
  coins.add_child(icon)
  coins.move_child(icon,0 if currency == "plata" else 2)
  coins.get_node("Plata" if currency == "plata" else "Bronce").add_theme_font_size_override("font_size",11)
 var hint := Label.new()
 hint.text = "Selecciona un objeto y pulsa 1–5 para asignarlo a la barra"
 hint.position = Vector2(4, 216)
 hint.add_theme_font_size_override("font_size", 10)
 panel.add_child(hint)
 item_list.item_selected.connect(_on_item_selected)

func _process(_delta):
 # Asegúrate de que las rutas ($) coincidan con los nombres de tus nodos
 $Panel/Dinero/Plata.text = str(Economia.monedas_plata)
 $Panel/Dinero/Bronce.text = str(Economia.monedas_bronce)

func _unhandled_input(event: InputEvent) -> void:
 if not is_instance_valid(get_tree().get_first_node_in_group("player")):
  return
 if not event.is_echo() and (event.is_action_pressed("open_inventory") or (is_open and event.is_action_pressed("ui_cancel"))):
  if get_tree().paused and not is_open:
   return
  get_viewport().set_input_as_handled()
  toggle_inventory()

func toggle_inventory() -> void:
 is_open = !is_open
 panel.visible = is_open
 get_tree().paused = is_open

 if is_open:
  refresh_inventory()

func refresh_inventory() -> void:
 selected_item_id = ""
 item_list.clear()
 item_details.clear()
 
 var counts: Dictionary = {}
 for item_id in Inventory.items:
  counts[item_id] = int(counts.get(item_id, 0)) + 1
 for item_id in counts:
  var data: Dictionary = Inventory.item_database.get(item_id, {"purepecha": item_id})
  var caption: String = str(data["purepecha"])
  if counts[item_id] > 1:
   caption += " × %d" % counts[item_id]
  var index: int = item_list.add_item(caption)
  item_list.set_item_metadata(index, item_id)

func _on_item_selected(index: int) -> void:
 var item_id = item_list.get_item_metadata(index)
 selected_item_id = str(item_id)
 var data = Inventory.item_database.get(item_id, {})
 
 item_details.text = "[b][color=yellow]" + data.get("purepecha", "") + "[/color][/b]\n"
 item_details.append_text("Cantidad: %d\n" % Inventory.items.count(item_id))
 for tool in Inventory.equipment:
  if tool["item_id"] == item_id:
   item_details.append_text("Herramienta #%d · Durabilidad: %d\n" % [tool["uid"], tool["durability"]])
 if DictionaryManager.Vocabulary.ENTRIES.has(item_id):
  item_details.append_text("J · Consulta el significado en tu diccionario.")
  return
 item_details.append_text("[color=gray]" + data.get("name", "") + "[/color]\n\n")
 item_details.append_text(data.get("desc", ""))
