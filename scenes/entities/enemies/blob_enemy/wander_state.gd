extends Enemy_State
@onready var jump_collider: RayCast2D = $jump_collider
@onready var edge_detection: RayCast2D = $edge_detection
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"

var jump_velocity = 400.0
var blob_wander_speed = 100.0



func enter(data = {}):
	print("wander")

func exit():
	print("leaving wander")

func physics_update(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
		# Zamiast polegać tylko na RayCast, sprawdź czy Godot mówi, że uderzyłeś w ścianę
	if (jump_collider.is_colliding() or character.is_on_wall()) and character.is_on_floor():
		character.velocity.y = -jump_velocity
	if !edge_detection.is_colliding() and character.is_on_floor():
		jump_collider.target_position.x *= -1
		edge_detection.position.x *= -1
		sprite_2d.flip_h = not sprite_2d.flip_h
	character.velocity.x = blob_wander_speed * character.dir
	character.move_and_slide()
	#print("velocity: ", character.velocity.x," real_velocity: ", character.get_real_velocity().x," on_wall: ", character.is_on_wall())
