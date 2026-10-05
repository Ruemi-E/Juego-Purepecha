extends Node2D
# Decorative wooden bandstand; no quest or interaction.
func _ready() -> void:
 z_index = 1
 _poly([Vector2(-48,-10),Vector2(-34,-23),Vector2(34,-23),Vector2(48,-10),Vector2(48,6),Vector2(32,18),Vector2(-32,18),Vector2(-48,6)],"555749")
 _poly([Vector2(-46,-14),Vector2(-32,-26),Vector2(32,-26),Vector2(46,-14),Vector2(46,1),Vector2(30,12),Vector2(-30,12),Vector2(-46,1)],"b4aa82")
 _rect(Rect2(-20,12,40,5),"d2c597")
 _rect(Rect2(-25,17,50,5),"8c8e71")
 for x in [-34,30]:
  _rect(Rect2(x,-66,5,66),"624332")
  _rect(Rect2(x+1,-65,2,64),"b58a56")
 _rect(Rect2(-34,-11,16,4),"a77d4c")
 _rect(Rect2(18,-11,16,4),"a77d4c")
 for x in [-30,-23,22,29]:
  _rect(Rect2(x,-10,2,14),"775236")
 _poly([Vector2(-56,-64),Vector2(-42,-76),Vector2(-16,-91),Vector2(16,-91),Vector2(42,-76),Vector2(56,-64),Vector2(40,-52),Vector2(-40,-52)],"614134")
 _poly([Vector2(-54,-67),Vector2(-40,-79),Vector2(-14,-94),Vector2(14,-94),Vector2(40,-79),Vector2(54,-67),Vector2(38,-57),Vector2(-38,-57)],"b8794b")
 _poly([Vector2(-14,-94),Vector2(14,-94),Vector2(26,-66),Vector2(-26,-66)],"d09959")
 for row in range(4):
  _rect(Rect2(-36-row*4,-80+row*6,72+row*8,2),"98613e")
 _rect(Rect2(-54,-66,108,3),"e0ac6b")
 _rect(Rect2(-6,-99,12,5),"73513a")
 _rect(Rect2(-2,-104,4,5),"c2a05b")
 var body := StaticBody2D.new()
 var shape := CollisionShape2D.new()
 var rectangle := RectangleShape2D.new()
 rectangle.size = Vector2(88,28)
 shape.shape = rectangle
 shape.position = Vector2(0,-2)
 body.add_child(shape)
 add_child(body)
func _poly(points: Array, color: String) -> void:
 var polygon := Polygon2D.new()
 polygon.polygon = PackedVector2Array(points)
 polygon.color = Color(color)
 add_child(polygon)
func _rect(rect: Rect2, color: String) -> void:
 _poly([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)],color)
