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
