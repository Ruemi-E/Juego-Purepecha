extends Control
var cursor := 0.0
func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color("293e43"))
 draw_rect(Rect2(size.x*0.35,0,size.x*0.3,size.y),Color("609e70"))
 draw_line(Vector2(size.x*cursor,0),Vector2(size.x*cursor,size.y),Color("fff3c5"),4)
