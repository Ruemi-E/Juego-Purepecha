extends "res://service_interaction.gd"
var puzzle_id := "riego"
var index := 0
var label: Label
func _ready() -> void:
 prompt = "E · " + (["Campana de leña", "Campana de hierbas", "Campana de maíz"][index] if puzzle_id == "campanas" else "Accionar " + str(index+1))
 action = activate
 super._ready()
 label = Label.new()
 label.position = Vector2(-40,20)
 label.size.x = 80
 label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 label.add_theme_font_size_override("font_size",9)
 add_child(label)
 AdventureState.changed.connect(refresh)
 refresh()
func activate(_player: CharacterBody2D) -> void:
 AdventureState.operate(puzzle_id,index)
func refresh() -> void:
 var data: Dictionary = AdventureState.entry(puzzle_id)
 label.text = ["Leña", "Hierbas", "Maíz"][index] if puzzle_id == "campanas" else "%d · %s" % [index+1,"Abierto" if data.values[index] else "Cerrado"]
 if puzzle_id == "faroles":
  label.text = "%d · %s" % [index+1,"Sí" if data.values[index] else "No"]
 queue_redraw()
func _draw() -> void:
 var data: Dictionary = AdventureState.entry(puzzle_id)
 var on: bool = data.solved or (puzzle_id != "campanas" and data.values[index] == 1)
 draw_rect(Rect2(-17,-12,34,28),Color("6f513b"))
 draw_rect(Rect2(-12,-8,24,18),Color("ffdf83") if on else Color("3a4c54"))
 if puzzle_id == "riego":
  draw_line(Vector2(0,12),Vector2(0,34),Color("75cdd1") if on else Color("8a7859"),8)
 else:
  draw_circle(Vector2(0,0),7,Color("e6ba5e") if puzzle_id == "campanas" or on else Color("7d7c67"))
