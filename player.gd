extends CharacterBody2D

# Velocidad de movimiento del personaje (puedes ajustar este número)
const SPEED = 150.0

func _physics_process(delta: float) -> void:
 var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
 
 if direction:
  velocity = direction * SPEED
 else:
  velocity = Vector2.ZERO
  
 # Controlar la animación según la dirección dominante
 if velocity.length() > 0:
  # abs() convierte los números negativos a positivos para comparar la fuerza del movimiento
  if abs(velocity.x) > abs(velocity.y):
   # Movimiento horizontal
   $AnimatedSprite2D.play("caminar_lado")
   if velocity.x < 0:
    $AnimatedSprite2D.flip_h = true
   else:
    $AnimatedSprite2D.flip_h = false
  else:
   # Movimiento vertical
   # Al ir hacia arriba o abajo, desactivamos el flip para que no quede volteado por error
   $AnimatedSprite2D.flip_h = false
   
   if velocity.y < 0:
    $AnimatedSprite2D.play("caminar_arriba")
   else:
    $AnimatedSprite2D.play("caminar_abajo")
 else:
  $AnimatedSprite2D.stop()
  
 move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
 if get_tree().paused or event.is_echo() or not event.is_action_pressed("interact"):
  return
 var nearest: Node2D = null
 var nearest_distance := INF
 for candidate in get_tree().get_nodes_in_group("interactables"):
  if not candidate is Node2D or not candidate.is_visible_in_tree() or candidate.is_queued_for_deletion():
   continue
  var area = candidate.get_node_or_null("AreaInteraccion")
  if area != null:
   if not area.overlaps_body(self):
    continue
  elif candidate.has_node("Rango"):
   if not candidate.overlaps_body(self):
    continue
  elif global_position.distance_to(candidate.global_position) > 54.0:
   continue
  var distance := global_position.distance_squared_to(candidate.global_position)
  if distance < nearest_distance:
   nearest = candidate
   nearest_distance = distance
 if nearest != null:
  get_viewport().set_input_as_handled()
  nearest.interact(self)
