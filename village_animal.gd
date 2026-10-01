extends CharacterBody2D

var species := "chicken"
var home := Vector2.ZERO
var roam_radius := 48.0
var rng := RandomNumberGenerator.new()
var decision_time := 0.0
var sprite: AnimatedSprite2D
var direction_index := 3

func _ready() -> void:
 add_to_group("village_animals")
 home = position
 rng.seed = int(home.x * 131 + home.y * 37)
 collision_layer = 0
 collision_mask = 1
 var collision := CollisionShape2D.new()
 var circle := CircleShape2D.new()
 circle.radius = 8 if species == "cow" else 4
 collision.shape = circle
 add_child(collision)
 sprite = AnimatedSprite2D.new()
 var frames := SpriteFrames.new()
 frames.remove_animation("default")
 var texture: Texture2D = load("res://Little Dreamyland - Free Pack/Little Dreamyland - Free Pack/Sprites/Animals/" + ("COW/Cow_Idle.png" if species == "cow" else "CHICKEN/Chicken_Idle.png"))
 for row in range(4):
  var animation := str(row)
  frames.add_animation(animation)
  frames.set_animation_speed(animation, 5)
  for col in range(8):
   var atlas := AtlasTexture.new()
   atlas.atlas = texture
   atlas.region = Rect2(col * 48, row * 48, 48, 48)
   frames.add_frame(animation, atlas)
 sprite.sprite_frames = frames
 sprite.position.y = -5
 add_child(sprite)
 sprite.play("3")
 decision_time = rng.randf_range(0.2, 2.0)

func _physics_process(delta: float) -> void:
 # Animals rest when far away, including when the player enters an interior.
 var player := get_tree().get_first_node_in_group("player") as Node2D
 if not is_instance_valid(player) or player.global_position.distance_squared_to(global_position) > 490000:
  sprite.pause()
  return
 if not sprite.is_playing():
  sprite.play(str(direction_index))
 decision_time -= delta
 if decision_time <= 0:
  decision_time = rng.randf_range(1.5, 3.5)
  if rng.randf() < 0.45:
   velocity = Vector2.ZERO
  else:
   velocity = Vector2.from_angle(rng.randf_range(0, TAU)) * (12 if species == "cow" else 19)
 if position.distance_to(home) > roam_radius:
  velocity = position.direction_to(home) * 16
 if velocity.length_squared() > 0:
  direction_index = (1 if velocity.x > 0 else 2) if absf(velocity.x) > absf(velocity.y) else (3 if velocity.y > 0 else 0)
  sprite.play(str(direction_index))
 move_and_slide()
 if get_slide_collision_count() > 0:
  velocity = position.direction_to(home) * 16
  decision_time = 0.5
