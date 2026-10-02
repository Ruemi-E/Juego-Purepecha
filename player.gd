extends CharacterBody2D

# Velocidad de movimiento del personaje.
const SPEED = 100.0

func _physics_process(_delta: float) -> void:
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * SPEED

    if velocity.length() > 0:
        if abs(velocity.x) > abs(velocity.y):
            $AnimatedSprite2D.play("caminar_lado")
            $AnimatedSprite2D.flip_h = velocity.x < 0
        else:
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
