extends Node

const SAVE_PATH := "user://partida.json"
const SETTINGS_PATH := "user://ajustes.cfg"
var volume: float = 1.0
var fullscreen: bool = false
var active: bool = false
var transitioning: bool = false
var pickup_paths: Array[String] = []
var initial_words: Dictionary
var mine_state: Dictionary = {}

func _ready() -> void:
	initial_words = DictionaryManager.known_words.duplicate(true)
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		volume = clampf(float(config.get_value("audio", "volume", 1.0)), 0.0, 1.0)
		fullscreen = bool(config.get_value("video", "fullscreen", false))
	_apply_settings()
	var timer := Timer.new()
	timer.wait_time = 5.0
	timer.timeout.connect(save_game)
	add_child(timer)
	timer.start()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func start_new() -> void:
	_open_world({})

func load_game() -> bool:
	if transitioning or not has_save():
		return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not data is Dictionary or data.get("version") != 1:
		return false
	if not data.get("position") is Array or data["position"].size() != 2:
		return false
	for key in ["items", "removed"]:
		if not data.get(key) is Array:
			return false
	for key in ["quests", "words"]:
		if not data.get(key) is Dictionary:
			return false
	_open_world(data)
	return true

func _open_world(data: Dictionary) -> void:
	if transitioning:
		return
	transitioning = true
	active = false
	get_tree().paused = false
	if get_tree().change_scene_to_file("res://World.tscn") != OK:
		transitioning = false
		return
	await get_tree().scene_changed
	DictionaryManager.reset_learning()
	mine_state.clear()
	Inventory.items.clear()
	Inventory.restore_hotbar([], 0)
	Inventory.equipment.clear()
	Inventory.next_equipment_uid = 1
	QuestManager.states.clear()
	QuestManager.tracked_quest = ""
	Economia.monedas_bronce = 0
	Economia.monedas_plata = 0
	DictionaryManager.has_dictionary = false
	DictionaryManager.known_words = initial_words.duplicate(true)
	var world := get_tree().current_scene
	pickup_paths.clear()
	for node in get_tree().get_nodes_in_group("interactables"):
		if node.get("item_id") != null:
			pickup_paths.append(str(world.get_path_to(node)))
	if not data.is_empty():
		for item in data["items"]:
			if item is String:
				Inventory.items.append(item)
		for id in data["quests"]:
			if QuestManager.QUESTS.has(id) and data["quests"][id] in ["active", "completed"]:
				QuestManager.states[id] = data["quests"][id]
		QuestManager.tracked_quest = str(data.get("tracked", ""))
		Economia.monedas_bronce = maxi(0, int(data.get("bronze", 0)))
		Economia.monedas_plata = maxi(0, int(data.get("silver", 0)))
		DictionaryManager.has_dictionary = bool(data.get("dictionary", false))
		DictionaryManager.known_words = data["words"].duplicate(true)
		if data.get("learning", {}) is Dictionary:
			DictionaryManager.restore_learning(data.get("learning", {}))
		for id in QuestManager.states:
			DictionaryManager.encountered[QuestManager.QUESTS[id]["item"]] = true
		for path in data["removed"]:
			if path in pickup_paths:
				var pickup := world.get_node_or_null(NodePath(path))
				if pickup != null:
					pickup.free()
		var player := get_tree().get_first_node_in_group("player") as Node2D
		player.global_position = Vector2(float(data["position"][0]), float(data["position"][1]))
	if data.get("mine_state", {}) is Dictionary:
		mine_state = data.get("mine_state", {}).duplicate(true)
	var saved_hotbar = data.get("hotbar", [])
	Inventory.restore_hotbar(saved_hotbar if saved_hotbar is Array else [], int(data.get("selected_slot", 0)))
	var saved_equipment = data.get("equipment", [])
	Inventory.restore_equipment(saved_equipment if saved_equipment is Array else [])
	QuestManager.changed.emit()
	active = true
	transitioning = false
	save_game()

func save_game() -> void:
	if not active or transitioning:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return
	var world := get_tree().current_scene
	var removed: Array[String] = []
	for path in pickup_paths:
		var node := world.get_node_or_null(NodePath(path))
		if node == null or node.is_queued_for_deletion():
			removed.append(path)
	var data := {
		"version": 1, "position": [player.global_position.x, player.global_position.y],
		"hotbar": Inventory.hotbar, "selected_slot": Inventory.selected_slot, "mine_state": mine_state,
		"items": Inventory.items, "equipment": Inventory.equipment, "quests": QuestManager.states,
		"tracked": QuestManager.tracked_quest, "bronze": Economia.monedas_bronce,
		"silver": Economia.monedas_plata, "dictionary": DictionaryManager.has_dictionary,
		"words": DictionaryManager.known_words, "removed": removed,
		"learning": {"consulted": DictionaryManager.consulted, "encountered": DictionaryManager.encountered, "practice": DictionaryManager.practice}
	}
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		push_warning("No se pudo guardar la partida.")
		return
	file.store_string(JSON.stringify(data))
	file.close()
	if DirAccess.rename_absolute(SAVE_PATH + ".tmp", SAVE_PATH) != OK:
		push_warning("No se pudo actualizar la partida guardada.")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	_apply_settings()
	_save_settings()

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply_settings()
	_save_settings()

func _apply_settings() -> void:
	AudioServer.set_bus_volume_linear(0, volume)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)
