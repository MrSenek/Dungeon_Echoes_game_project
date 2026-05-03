extends Enemy_State

class_name caco_idle_state

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer: Timer = $Timer



var dir: int = 1


func physics_update(delta: float):
	if timer.is_stopped():
		dir = [1,-1].pick_random()
		timer.start(randi_range(1,2))
	if dir:
		character.velocity.x = move_toward(character.velocity.x, dir*character.SPEED, character.SPEED)
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, character.SPEED)
	if dir == -1:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
	character.move_and_slide()

func update(delta: float):
	var targets = character.seeing_range.get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("Player"):
			character.eyes.look_at(body.global_position)
			if character.ray_cast_2d.is_colliding() and character.ray_cast_2d.get_collider().is_in_group("Player"):
				enemy_state_machine.change_state("caco_chase_state")
