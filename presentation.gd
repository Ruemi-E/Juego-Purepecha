extends Node
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 get_tree().root.theme = preload("res://village_theme.gd").make_theme()
 DisplayServer.window_set_title("Caminos de la meseta")
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  var key: int = event.physical_keycode if event.physical_keycode else event.keycode
  if key == KEY_F11 or (key == KEY_ENTER and event.alt_pressed):
   GameSession.set_fullscreen(not GameSession.fullscreen)
   get_viewport().set_input_as_handled()
