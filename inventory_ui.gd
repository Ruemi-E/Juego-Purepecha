extends CanvasLayer

@onready var panel: Control = $Panel
@onready var item_list: ItemList = $Panel/ItemList
@onready var item_details: RichTextLabel = $Panel/ItemDetails

var is_open: bool = false

func _ready() -> void:
	panel.hide()
	item_list.item_selected.connect(_on_item_selected)

func _process(_delta):
	# Asegúrate de que las rutas ($) coincidan con los nombres de tus nodos
	$Panel/Dinero/Plata.text = str(Economia.monedas_plata)
	$Panel/Dinero/Bronce.text = str(Economia.monedas_bronce)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		get_viewport().set_input_as_handled()
		toggle_inventory()

func toggle_inventory() -> void:
	is_open = !is_open
	panel.visible = is_open
	get_tree().paused = is_open

	if is_open:
		refresh_inventory()

func refresh_inventory() -> void:
	item_list.clear()
	item_details.clear()
	
	for i in range(Inventory.items.size()):
		var item_id = Inventory.items[i]
		var data = Inventory.item_database.get(item_id, {"purepecha": item_id})
		item_list.add_item(data["purepecha"])
		item_list.set_item_metadata(i, item_id)

func _on_item_selected(index: int) -> void:
	var item_id = item_list.get_item_metadata(index)
	var data = Inventory.item_database.get(item_id, {})
	
	item_details.text = "[b][color=yellow]" + data.get("purepecha", "") + "[/color][/b]\n"
	item_details.append_text("[color=gray]" + data.get("name", "") + "[/color]\n\n")
	item_details.append_text(data.get("desc", ""))
