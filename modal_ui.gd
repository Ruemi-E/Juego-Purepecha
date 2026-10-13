extends RefCounted
static func build(layer: CanvasLayer, title: String, width: float = 550) -> Dictionary:
 var overlay := Control.new()
 overlay.theme = preload("res://village_theme.gd").make_theme()
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 layer.add_child(overlay)
 var shade := ColorRect.new()
 shade.color = Color(0.025,0.05,0.04,0.78)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.add_child(shade)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.offset_bottom = -52 if is_instance_valid(layer.get_tree().get_first_node_in_group("player")) else 0
 overlay.add_child(center)
 var panel := PanelContainer.new()
 panel.custom_minimum_size = Vector2(width,260)
 center.add_child(panel)
 var margin := MarginContainer.new()
 for edge in ["left","right","top","bottom"]:
  margin.add_theme_constant_override("margin_"+edge,12)
 panel.add_child(margin)
 var column := VBoxContainer.new()
 column.add_theme_constant_override("separation",6)
 margin.add_child(column)
 var header := HBoxContainer.new()
 column.add_child(header)
 var heading := label(header,title,17)
 heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 heading.add_theme_color_override("font_color",Color("f3d9a2"))
 var line := HSeparator.new()
 column.add_child(line)
 return {"overlay":overlay,"column":column,"panel":panel,"header":header}
static func label(parent: Node, text: String, font_size: int = 12) -> Label:
 var label := Label.new()
 label.text = text
 label.add_theme_font_size_override("font_size",font_size)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(label)
 return label
static func button(parent: Node, text: String, callback: Callable) -> Button:
 var button := Button.new()
 button.text = text
 button.custom_minimum_size.y = 28
 button.add_theme_font_size_override("font_size",12)
 button.pressed.connect(callback)
 parent.add_child(button)
 return button
