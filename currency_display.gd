extends CanvasLayer
var panel: HBoxContainer
var values: Array[Label] = []
func _ready() -> void:
 layer = 8
 panel = HBoxContainer.new()
 panel.position = Vector2(510,28)
 panel.add_theme_constant_override("separation",4)
 add_child(panel)
 for currency in ["plata","bronce"]:
  var icon := TextureRect.new()
  icon.texture = load("res://assets/ui/moneda_"+currency+".svg")
  icon.custom_minimum_size = Vector2(16,16)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.tooltip_text = "Monedas de " + currency
  panel.add_child(icon)
  var amount := Label.new()
  amount.add_theme_font_size_override("font_size",11)
  amount.add_theme_color_override("font_outline_color",Color.BLACK)
  amount.add_theme_constant_override("outline_size",2)
  amount.custom_minimum_size.x = 30
  panel.add_child(amount)
  values.append(amount)
func _process(_delta: float) -> void:
 panel.visible = is_instance_valid(get_tree().get_first_node_in_group("player")) and not get_tree().paused
 values[0].text = str(Economia.monedas_plata)
 values[1].text = str(Economia.monedas_bronce)
