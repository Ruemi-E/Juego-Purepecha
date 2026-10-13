extends RefCounted
const INK := Color("f1e5c7")
const GOLD := Color("c6a76a")
static func box(background: Color, border: Color, padding: int = 8) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = background
 style.border_color = border
 style.set_border_width_all(1)
 style.set_corner_radius_all(5)
 style.set_content_margin_all(padding)
 return style
static func make_theme() -> Theme:
 var theme := Theme.new()
 theme.default_font_size = 12
 for type in ["Label","Button","CheckButton","ItemList","RichTextLabel"]:
  theme.set_color("font_color",type,INK)
 theme.set_color("default_color","RichTextLabel",INK)
 var panel := box(Color("203c35"),GOLD,0)
 panel.shadow_color = Color(0,0,0,0.35)
 panel.shadow_size = 6
 panel.shadow_offset = Vector2(0,4)
 theme.set_stylebox("panel","PanelContainer",panel)
 theme.set_stylebox("panel","Panel",panel)
 theme.set_stylebox("normal","Button",box(Color("35584a"),Color("718568"),6))
 theme.set_stylebox("hover","Button",box(Color("466c54"),Color("eed49a"),6))
 theme.set_stylebox("pressed","Button",box(Color("203b34"),GOLD,6))
 theme.set_stylebox("disabled","Button",box(Color("293e36"),Color("50614c"),6))
 theme.set_color("font_disabled_color","Button",Color("819489"))
 var focus := box(Color(0,0,0,0),Color("f7db94"),0)
 focus.set_border_width_all(2)
 theme.set_stylebox("focus","Button",focus)
 theme.set_stylebox("panel","ItemList",box(Color("172f2c"),Color("597762"),4))
 theme.set_stylebox("selected","ItemList",box(Color("446750"),GOLD,3))
 theme.set_stylebox("selected_focus","ItemList",box(Color("446750"),Color("f7db94"),3))
 theme.set_stylebox("cursor","ItemList",focus)
 theme.set_stylebox("cursor_unfocused","ItemList",StyleBoxEmpty.new())
 theme.set_constant("v_separation","ItemList",5)
 theme.set_constant("icon_margin","ItemList",8)
 theme.set_stylebox("panel","PopupPanel",box(Color("172e29"),GOLD,6))
 theme.set_stylebox("panel","TooltipPanel",box(Color("172e29"),GOLD,6))
 theme.set_color("font_color","TooltipLabel",INK)
 theme.set_font_size("font_size","TooltipLabel",11)
 theme.set_stylebox("scroll","VScrollBar",box(Color("172e29"),Color("172e29"),3))
 for state in ["grabber","grabber_highlight","grabber_pressed"]:
  theme.set_stylebox(state,"VScrollBar",box(Color("a39162"),Color("a39162"),3))
 theme.set_constant("separation","HSeparator",4)
 theme.set_stylebox("separator","HSeparator",box(Color("657b59"),Color("657b59"),0))
 return theme
