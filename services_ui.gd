extends CanvasLayer

const Transactions = preload("res://shop_transactions.gd")
const Card = preload("res://learning_card.gd")
const MAX_TURNS: int = 12
var overlay: Control
var column: VBoxContainer
var service_id: String = ""
var balance: Label
var message: Label
var list: VBoxContainer
var cards: Array[Button] = []
var first_card: int = -1
var locked: bool = false
var turns: int = 0
var pairs: int = 0
var playing: bool = false
var paid: bool = false
var round_token: int = 0
var reward: int = 0
var counters: Label
var board: GridContainer
var repairing: bool = false
var crafting: bool = false
var result_text: String = ""
var was_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 18
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.03, 0.86)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_bottom = -52
	overlay.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(596, 292)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("253a37")
	style.border_color = Color("bba570")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	card.add_theme_stylebox_override("panel", style)
	center.add_child(card)
	column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	card.add_child(column)
	overlay.hide()

func _input(event: InputEvent) -> void:
	if overlay.visible and not event.is_echo() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_service()

func _clear() -> void:
	for child in column.get_children():
		column.remove_child(child)
		child.queue_free()
	cards.clear()

func _label(text: String, font_size: int = 13) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 560
	column.add_child(label)
	return label

func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 30
	button.add_theme_font_size_override("font_size", 12)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func open_service(id: String) -> void:
	if overlay.visible:
		return
	service_id = id
	was_paused = get_tree().paused
	get_tree().paused = true
	overlay.show()
	if id == "library":
		show_library()
	else:
		crafting = false
		repairing = false
		show_shop()

func close_service() -> void:
	if not overlay.visible:
		return
	round_token += 1
	playing = false
	overlay.hide()
	get_tree().paused = was_paused
	GameSession.save_game()

func show_library() -> void:
	playing = false
	_clear()
	_label("ELENA · BIBLIOTECA", 19)
	_label("EL RETO DE LAS PAREJAS", 15)
	var instructions := _label("Destapa dos cartas: une una palabra en purépecha con su objeto y significado.\n\nEncuentra 4 parejas en un máximo de 12 turnos.\nCada pareja vale 2 monedas de bronce.\nCompletar en 4 turnos da +4; en 5 o 6, +2.\n\nPuedes estudiar las palabras antes de comenzar.\nSalir de una ronda sin terminar no entrega premios.")
	instructions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var actions := HBoxContainer.new()
	column.add_child(actions)
	_button(actions, "Jugar", start_round).grab_focus()
	_button(actions, "Estudiar palabras", show_study)
	_button(actions, "Volver · Esc", close_service)

func show_study() -> void:
	_clear()
	_label("ANTES DEL RETO", 19)
	for id in DictionaryManager.Vocabulary.ENTRIES:
		var entry: Dictionary = DictionaryManager.Vocabulary.ENTRIES[id]
		_label("%s  →  %s" % [entry["word"], entry["meaning"]], 16)
	_label("También puedes consultar sus referencias en el diccionario con J al salir.")
	var actions := HBoxContainer.new()
	column.add_child(actions)
	_button(actions, "Comenzar reto", start_round).grab_focus()
	_button(actions, "Volver", show_library)

func start_round() -> void:
	round_token += 1
	_clear()
	playing = true
	paid = false
	locked = false
	first_card = -1
	turns = 0
	pairs = 0
	reward = 0
	_label("BIBLIOTECA · ENCUENTRA LAS PAREJAS", 17)
	counters = _label("")
	board = GridContainer.new()
	board.columns = 4
	board.add_theme_constant_override("h_separation", 8)
	board.add_theme_constant_override("v_separation", 6)
	column.add_child(board)
	var deck: Array[Dictionary] = []
	for id in DictionaryManager.Vocabulary.ENTRIES:
		deck.append({"id": id, "word": true})
		deck.append({"id": id, "word": false})
	deck.shuffle()
	for data in deck:
		var card := Card.new()
		card.item_id = data["id"]
		card.word_side = data["word"]
		card.pressed.connect(flip_card.bind(cards.size()))
		board.add_child(card)
		cards.append(card)
	message = _label("Elige dos cartas. También puedes usar Tab y Enter.", 12)
	message.custom_minimum_size.y = 30
	_button(column, "Abandonar ronda · Esc", close_service)
	_update_counters()
	cards[0].grab_focus()

func _update_counters() -> void:
	counters.text = "Parejas: %d / 4     Turnos: %d / %d     Premio acumulado: %d bronce" % [pairs, turns, MAX_TURNS, pairs * 2]

func flip_card(index: int) -> void:
	if not playing or locked or index < 0 or index >= cards.size():
		return
	var card = cards[index]
	if card.revealed or card.matched:
		return
	card.revealed = true
	card.refresh()
	if first_card < 0:
		first_card = index
		return
	turns += 1
	locked = true
	var other = cards[first_card]
	var matched: bool = other.item_id == card.item_id and other.word_side != card.word_side
	DictionaryManager.encountered[other.item_id] = true
	DictionaryManager.record_answer(other.item_id, matched)
	if matched:
		pairs += 1
		other.matched = true
		card.matched = true
		other.refresh()
		card.refresh()
		var entry: Dictionary = DictionaryManager.Vocabulary.ENTRIES[card.item_id]
		message.text = "¡Pareja! %s → %s" % [entry["word"], entry["meaning"]]
	else:
		message.text = "No forman pareja. Recuerda su posición e inténtalo de nuevo."
	_update_counters()
	var token := round_token
	await get_tree().create_timer(0.9, true).timeout
	if token != round_token or not playing:
		return
	if not matched:
		other.revealed = false
		card.revealed = false
		other.refresh()
		card.refresh()
	first_card = -1
	locked = false
	if pairs == 4 or turns >= MAX_TURNS:
		finish_round()

func finish_round() -> void:
	if not playing or paid:
		return
	playing = false
	paid = true
	reward = pairs * 2
	if pairs == 4:
		reward += 4 if turns <= 4 else (2 if turns <= 6 else 0)
	Economia.anadir_bronce(reward)
	GameSession.save_game()
	_clear()
	var medal := "MEMORIA BRILLANTE" if pairs == 4 and turns <= 6 else ("¡RETO COMPLETADO!" if pairs == 4 else "SIGUE DESCUBRIENDO")
	_label(medal, 21)
	result_text = "%d de 4 parejas · %d turnos\n\nGanaste %d monedas de bronce.\nSaldo: %d plata y %d bronce." % [pairs, turns, reward, Economia.monedas_plata, Economia.monedas_bronce]
	var result := _label(result_text, 16)
	result.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_label("Elena: cada intento te ayuda a recordar. ¡Puedes volver a jugar!")
	var actions := HBoxContainer.new()
	column.add_child(actions)
	_button(actions, "Otra ronda", start_round).grab_focus()
	_button(actions, "Salir del minijuego · Esc", close_service)

func show_shop() -> void:
	_clear()
	var names := {"food": "LUCÍA · TIENDA DE COMIDA", "remedies": "INÉS · CASA DE REMEDIOS", "smith": "TOMÁS · HERRERÍA"}
	_label(names[service_id], 19)
	balance = _label("Saldo: %d plata · %d bronce     1 plata = 10 bronce" % [Economia.monedas_plata, Economia.monedas_bronce])
	if service_id == "smith":
		var tabs := HBoxContainer.new()
		column.add_child(tabs)
		_button(tabs, "Comprar", func(): repairing = false; crafting = false; show_shop())
		_button(tabs, "Reparar", func(): repairing = true; crafting = false; show_shop())
		_button(tabs, "Fabricar", func(): repairing = false; crafting = true; show_shop())
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 108
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if crafting:
		_build_recipes()
	elif repairing:
		_build_repairs()
	else:
		_build_products()
	message = _label("Selecciona un objeto para comprarlo." if not repairing else "El coste depende del desgaste del objeto.", 12)
	if crafting:
		message.text = "Trae materiales de la mina. Selecciona una receta."
	message.custom_minimum_size.y = 30
	_button(column, "Volver al local · Esc", close_service).grab_focus()

func _empty(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 520
	label.add_theme_font_size_override("font_size", 14)
	list.add_child(label)

func _build_products() -> void:
	var ids: Array[String] = Transactions.products(service_id)
	if ids.is_empty():
		_empty("Tomás: todavía no tengo objetos a la venta.\nVuelve cuando lleguen las nuevas herramientas.")
	for id in ids:
		var data: Dictionary = Inventory.item_database[id]
		var price: int = int(data.get("price", 0))
		var button := _button(list, "%s · %d bronce · Tienes: %d" % [data.get("purepecha", data["name"]), price, Inventory.items.count(id)], buy.bind(id))
		button.disabled = price <= 0 or Economia.total_bronce() < price
	if service_id == "remedies":
		_empty("Los remedios se guardan en el inventario. Su uso estará disponible al añadir el sistema de salud.")

func buy(id: String) -> void:
	var result: String = Transactions.purchase(service_id, id)
	show_shop()
	message.text = result

func _build_repairs() -> void:
	var count := 0
	for equipment in Inventory.equipment:
		var data: Dictionary = Inventory.item_database.get(equipment["item_id"], {})
		if not data.get("repairable", false):
			continue
		count += 1
		var cost: int = Transactions.repair_cost(equipment)
		var button := _button(list, "%s · Estado %d/%d · %s" % [data.get("name", equipment["item_id"]), equipment["durability"], data.get("max_durability", 0), "%d bronce" % cost if cost > 0 else "Sin daños"], repair.bind(int(equipment["uid"])))
		button.disabled = cost <= 0 or Economia.total_bronce() < cost
	if count == 0:
		_empty("Tomás: no llevas objetos reparables.\nAquí podrás reparar las herramientas que consigas más adelante.")

func repair(uid: int) -> void:
	var result: String = Transactions.repair(uid)
	show_shop()
	message.text = result

func _build_recipes() -> void:
	for id in Transactions.RECIPES:
		var recipe: Dictionary = Transactions.RECIPES[id]
		var cost_text: Array[String] = []
		for material in recipe["materials"]:
			cost_text.append("%s %d/%d" % [Inventory.item_database[material]["name"], Inventory.items.count(material), recipe["materials"][material]])
		var button := _button(list, "%s · %d bronce" % [Inventory.item_database[id]["name"], recipe["price"]], craft.bind(id))
		button.disabled = not Transactions.can_craft(id)
		_empty(", ".join(cost_text))

func craft(id: String) -> void:
	var result: String = Transactions.craft(id)
	show_shop()
	message.text = result
