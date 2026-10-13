extends CanvasLayer
const UI = preload("res://modal_ui.gd")
const Images = preload("res://item_images.gd")
var panel: Control
var item_list: ItemList
var item_details: RichTextLabel
var preview: TextureRect
var item_title: Label
var silver: Label
var bronze: Label
var is_open := false
var selected_item_id := ""
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 14
 for child in get_children():
  remove_child(child)
  child.queue_free()
 var ui := UI.build(self,"MI MORRAL",584)
 panel = ui.overlay
 panel.get_child(1).offset_bottom = -52
 ui.panel.custom_minimum_size.y = 288
 for currency in ["plata","bronce"]:
  var icon := TextureRect.new()
  icon.texture = load("res://assets/ui/moneda_"+currency+".svg")
  icon.custom_minimum_size = Vector2(16,16)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  ui.header.add_child(icon)
  var value := UI.label(ui.header,"0",12)
  value.custom_minimum_size.x = 30
  if currency == "plata": silver = value
  else: bronze = value
 var row := HBoxContainer.new()
 row.custom_minimum_size.y = 174
 row.size_flags_vertical = Control.SIZE_EXPAND_FILL
 row.add_theme_constant_override("separation",14)
 ui.column.add_child(row)
 item_list = ItemList.new()
 item_list.custom_minimum_size.x = 210
 item_list.fixed_icon_size = Vector2i(28,28)
 item_list.add_theme_font_size_override("font_size",12)
 item_list.item_selected.connect(_on_item_selected)
 row.add_child(item_list)
 var right := VBoxContainer.new()
 right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 row.add_child(right)
 var heading := HBoxContainer.new()
 heading.add_theme_constant_override("separation",12)
 right.add_child(heading)
 preview = TextureRect.new()
 preview.custom_minimum_size = Vector2(52,52)
 preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 heading.add_child(preview)
 item_title = UI.label(heading,"Tu equipaje",16)
 item_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 item_title.add_theme_color_override("font_color",Color("f3d9a2"))
 item_details = RichTextLabel.new()
 item_details.bbcode_enabled = true
 item_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
 right.add_child(item_details)
 var footer := HBoxContainer.new()
 ui.column.add_child(footer)
 var hint := UI.label(footer,"Selecciona un objeto · 1–5 para asignarlo a la barra",10)
 hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 UI.button(footer,"Cerrar · I / Esc",toggle_inventory)
 panel.hide()
func _process(_delta: float) -> void:
 silver.text = str(Economia.monedas_plata)
 bronze.text = str(Economia.monedas_bronce)
func _input(event: InputEvent) -> void:
 if is_open and not event.is_echo() and (event.is_action_pressed("open_inventory") or event.is_action_pressed("ui_cancel")):
  get_viewport().set_input_as_handled()
  toggle_inventory()
func _unhandled_input(event: InputEvent) -> void:
 if not is_instance_valid(get_tree().get_first_node_in_group("player")) or get_tree().paused or event.is_echo():
  return
 if event.is_action_pressed("open_inventory"):
  get_viewport().set_input_as_handled()
  toggle_inventory()
func toggle_inventory() -> void:
 is_open = not is_open
 panel.visible = is_open
 get_tree().paused = is_open
 if is_open:
  refresh_inventory()
  item_list.grab_focus()
func refresh_inventory() -> void:
 selected_item_id = ""
 item_list.clear()
 item_details.text = "Todavía no llevas objetos. Habla con Tátita para comenzar tu viaje."
 item_title.text = "Tu equipaje"
 preview.texture = Images.icon("morral_recado")
 var counts: Dictionary = {}
 for id in Inventory.items:
  counts[id] = int(counts.get(id,0))+1
 for id in counts:
  var data: Dictionary = Inventory.item_database.get(id,{"purepecha":id})
  var caption: String = str(data.purepecha)
  if counts[id]>1: caption += " × %d" % counts[id]
  var index := item_list.add_item(caption,Images.icon(id))
  item_list.set_item_metadata(index,id)
 if item_list.item_count > 0:
  item_list.select(0)
  _on_item_selected(0)
func _on_item_selected(index: int) -> void:
 var id: String = str(item_list.get_item_metadata(index))
 selected_item_id = id
 var data: Dictionary = Inventory.item_database.get(id,{})
 preview.texture = Images.icon(id)
 item_title.text = str(data.get("purepecha",id))
 var description := "[color=#d6bd87]Cantidad: %d[/color]\n\n" % Inventory.items.count(id)
 for tool in Inventory.equipment:
  if tool.item_id == id:
   description += "Herramienta #%d · Durabilidad: %d/%d\n" % [tool.uid,tool.durability,data.get("max_durability",0)]
 if DictionaryManager.Vocabulary.ENTRIES.has(id):
  description += "J · Consulta su significado en tu diccionario."
 else:
  description += str(data.get("desc",""))

 item_details.text = description
 item_details.get_v_scroll_bar().set_deferred("value",0.0)
