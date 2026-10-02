extends RefCounted
static func build(layer: CanvasLayer, title: String, width: float = 550) -> Dictionary:
 var overlay := Control.new()
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 layer.add_child(overlay)
 var shade := ColorRect.new()
 shade.color = Color(0.02,0.05,0.04,0.94)
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
 column.add_theme_constant_override("separation",8)
 margin.add_child(column)
 label(column,title,18)
 return {"overlay":overlay,"column":column,"panel":panel}
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
 button.custom_minimum_size.y = 30
 button.add_theme_font_size_override("font_size",12)
 button.pressed.connect(callback)
 parent.add_child(button)
 return button
