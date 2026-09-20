extends CharacterBody2D

@export var speed: float = 100.0
@onready var interaction_ray: RayCast2D = $InteractionRay

var last_dir: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	# Lee las entradas de movimiento estándar (WASD o Flechas)
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * speed
	move_and_slide()

	# Si nos movemos, reorientamos la flecha de interacción
	if dir != Vector2.ZERO:
		last_dir = dir
		interaction_ray.target_position = last_dir.normalized() * 24

func _unhandled_input(event: InputEvent) -> void:
	# Detecta la barra espaciadora o la tecla Enter
	if event.is_action_pressed("ui_accept"):
		if interaction_ray.is_colliding():
			var target = interaction_ray.get_collider()
			if target.has_method("interact"):
				target.interact(self)
