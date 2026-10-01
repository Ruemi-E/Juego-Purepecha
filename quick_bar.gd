extends CanvasLayer

var bar: HBoxContainer
var buttons: Array[Button] = []

func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 21
 bar = HBoxContainer.new()
 bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 bar.offset_left = -181
 bar.offset_right = 181
 bar.offset_top = -48
 bar.offset_bottom = -4
 bar.add_theme_constant_override("separation", 5)
 add_child(bar)
 for i in range(5):
  var button := Button.new()
  button.custom_minimum_size = Vector2(68, 44)
  button.add_theme_font_size_override("font_size", 8)
  button.pressed.connect(choose.bind(i))
  bar.add_child(button)
  buttons.append(button)
 bar.hide()

func _process(_delta: float) -> void:
 bar.visible = is_instance_valid(get_tree().get_first_node_in_group("player"))
 for i in range(5):
  var id: String = Inventory.hotbar[i]
  var data: Dictionary = Inventory.item_database.get(id, {})
  var title: String = str(data.get("purepecha", "Vacío"))
  var count: int = Inventory.items.count(id)
  var state := "x%d" % count if not id.is_empty() else "I · Asignar"
  if int(data.get("max_durability", 0)) > 0:
   var durability := 0
   for tool in Inventory.equipment:
    if tool["item_id"] == id:
     durability = maxi(durability, int(tool["durability"]))
   state = "%d/%d · x%d" % [durability, data["max_durability"], count]
  buttons[i].text = "%d · %s\n%s" % [i + 1, title, state]
  buttons[i].tooltip_text = title + "\n1–5: seleccionar. En el inventario: asignar el objeto elegido."
  buttons[i].disabled = get_tree().paused and not InventoryUi.is_open
  var style := StyleBoxFlat.new()
  style.bg_color = Color("30483b") if i == Inventory.selected_slot else Color("212c2d")
  style.border_color = Color("ffe09a") if i == Inventory.selected_slot else Color("8e8064")
  style.set_border_width_all(2 if i == Inventory.selected_slot else 1)
  buttons[i].add_theme_stylebox_override("normal", style)
  buttons[i].add_theme_stylebox_override("disabled", style)

func _input(event: InputEvent) -> void:
 if not bar.visible or not event is InputEventKey or not event.pressed or event.echo:
  return
 var key: int = event.physical_keycode if event.physical_keycode else event.keycode
 if key >= KEY_1 and key <= KEY_5 and (not get_tree().paused or InventoryUi.is_open):
  get_viewport().set_input_as_handled()
  choose(key - KEY_1)

func choose(index: int) -> void:
 if get_tree().paused and not InventoryUi.is_open:
  return
 if InventoryUi.is_open:
  if InventoryUi.selected_item_id.is_empty():
   return
  Inventory.assign_slot(index, InventoryUi.selected_item_id)
 else:
  Inventory.selected_slot = index
 GameSession.save_game()
