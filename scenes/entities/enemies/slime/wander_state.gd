extends Enemy_State
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var floor_detection: RayCast2D = $floor_detection



var dir:int
@export var wander_speed:int = 30

func enter(data = {}):
	print("wander")
	dir = character.dir
	animated_sprite_2d.play("walk")
	
func update(delta: float):
	if character.player_in_range:
		enemy_state_machine.change_state("chase_state")

func physics_update(delta: float) -> void:
	character.velocity.x = dir*wander_speed
	if !floor_detection.is_colliding():
		turn_around()
	
	character.apply_movement_with_external_force()

func turn_around():
	animated_sprite_2d.flip_h = not animated_sprite_2d.flip_h
	floor_detection.position.x *= -1
	character.dir *= -1
	dir = character.dir
