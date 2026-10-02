extends CanvasLayer
const UI = preload("res://modal_ui.gd")
var opened := false
var overlay: Control
var was_paused := false
var map_mode := false
var big_map: Control
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 24
func open_worlds() -> void:
 if opened:
  return
 _begin(false)
 var ui := UI.build(self,"SELECCIÓN DE MUNDOS")
 overlay = ui.overlay
 UI.label(ui.column,"Recorre los pueblos, aprende sus palabras y llega a casa de tu tía.")
 var in_game := is_instance_valid(get_tree().get_first_node_in_group("player"))
 UI.button(ui.column,"Pueblo de la ribera · Continuar" if in_game or GameSession.has_save() else "Pueblo de la ribera · Comenzar",select_first)
 for title in ["Pueblo 2 · Próximamente","Pueblo 3 · Próximamente","Pueblo de la tía · Próximamente"]:
  UI.button(ui.column,title,func():pass).disabled = true
 UI.button(ui.column,"Volver · Esc",close).grab_focus()
func select_first() -> void:
 var in_game := is_instance_valid(get_tree().get_first_node_in_group("player"))
 close()
 if in_game:
  PauseMenu.resume_game()
 elif GameSession.has_save():
  if not GameSession.load_game():
   open_worlds()
   UI.label(overlay.get_child(1).get_child(0).get_child(0).get_child(0),"No se pudo cargar la partida. Usa Juego Nuevo para empezar.")
 else:
  GameSession.start_new()
func _begin(is_map: bool) -> void:
 opened = true
 map_mode = is_map
 was_paused = get_tree().paused
 get_tree().paused = true
func open_map() -> void:
 if opened or get_tree().paused:
  return
 _begin(true)
 var ui := UI.build(self,"MAPA DEL PUEBLO · Tab / Esc para cerrar",600)
 overlay = ui.overlay
 big_map = preload("res://minimap_view.gd").new()
 big_map.custom_minimum_size = Vector2(572,205)
 big_map.clip_contents = true
 big_map.overview = true
 big_map.map_scale = minf(572.0/preload("res://world_catalog.gd").BOUNDS.size.x,205.0/preload("res://world_catalog.gd").BOUNDS.size.y)*0.94
 big_map.configure(get_tree().current_scene)
 var player := get_tree().get_first_node_in_group("player") as Node2D
 big_map.player_position = player.global_position
 var services := get_tree().current_scene.get_node("VillageServices")
 var room: String = services.room_at(player.global_position)
 if not room.is_empty():
  big_map.player_position = services.doors[room].global_position
 big_map.has_target = QuestHud.map_view.has_target
 big_map.navigation_position = QuestHud.navigation_position
 ui.column.add_child(big_map)
 UI.label(ui.column,"B Biblioteca · C Comida · R Remedios · H Herrería · M Mina · S Salida · P Pesca\nN Nuevos vecinos / puzzles · ● Tú · ◆ Objetivo",10)
func close() -> void:
 if not opened:
  return
 opened = false
 overlay.queue_free()
 get_tree().paused = was_paused
func _input(event: InputEvent) -> void:
 if event.is_echo():
  return
 var tab: bool = event is InputEventKey and event.pressed and event.physical_keycode == KEY_TAB
 if opened and (event.is_action_pressed("ui_cancel") or (map_mode and tab)):
  get_viewport().set_input_as_handled()
  close()
 elif tab and not get_tree().paused and is_instance_valid(get_tree().get_first_node_in_group("player")):
  get_viewport().set_input_as_handled()
  open_map()
