extends CanvasLayer
const UI = preload("res://modal_ui.gd")
var opened := false
var overlay: Control
var was_paused := false
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 30
func open_help() -> void:
 if opened:
  return
 opened = true
 was_paused = get_tree().paused
 get_tree().paused = true
 var ui := UI.build(self,"AYUDA · TU VIAJE",570)
 overlay = ui.overlay
 var scroll := ScrollContainer.new()
 scroll.custom_minimum_size.y = 190
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 ui.column.add_child(scroll)
 var body := VBoxContainer.new()
 body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 body.add_theme_constant_override("separation",8)
 scroll.add_child(body)
 UI.label(body,"Ayuda a los vecinos de la ribera y aprende palabras en purépecha. Completa encargos y acertijos para preparar el viaje a casa de tu tía. Los siguientes pueblos aún están en preparación.",12)
 UI.label(body,"WASD / Flechas · Caminar     E · Hablar, recoger e interactuar\nJ · Diccionario     M · Misiones     Q · Cambiar misión seguida\nI · Inventario y monedas     1–5 · Seleccionar acceso rápido\nTab · Mapa completo     Espacio · Acción al pescar\nEsc · Pausa / cerrar ventanas",12)
 UI.label(body,"MAPA: clic izquierdo para fijar una ruta; clic derecho para quitarla. Pasa el cursor por los iconos para leer sus nombres. Consulta en J la palabra de tu encargo para ver su objetivo.",11)
 UI.label(body,"Biblioteca: solo las primeras 3 rondas iniciadas cada día dan monedas. Pescar consume un anzuelo por lanzamiento. Si te atascas con los faroles, Beto ofrece pistas tras 12 movimientos por 3 bronces.",11)
 UI.button(ui.column,"Volver · Esc",close).grab_focus()
func close() -> void:
 if not opened:
  return
 opened = false
 overlay.queue_free()
 get_tree().paused = was_paused
func _input(event: InputEvent) -> void:
 if opened and event.is_action_pressed("ui_cancel") and not event.is_echo():
  get_viewport().set_input_as_handled()
  close()
