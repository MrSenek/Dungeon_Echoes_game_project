extends Enemy_State

class_name caco_idle_state

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer: Timer = $Timer
@onready var navigation_agent_2d: NavigationAgent2D = $"../../NavigationAgent2D"



var dir: int = 1

var flying_up := false
var fly_speed := 100.0

func enter(data = {}):
	flying_up = true
	navigation_agent_2d.target_position = Vector2(character.global_position.x, 650)

func physics_update(delta: float):
	if flying_up:
		if navigation_agent_2d.is_navigation_finished():
			flying_up = false
			character.velocity = Vector2.ZERO
		else:
			var next_pos := navigation_agent_2d.get_next_path_position()
			var dir_to_next := character.global_position.direction_to(next_pos)
			character.velocity = dir_to_next * fly_speed
		
		character.move_and_slide()
		return

	# normalne idle
	if timer.is_stopped():
		dir = [1, -1].pick_random()
		timer.start(randi_range(1, 2))

	character.velocity.x = move_toward(character.velocity.x, dir * character.SPEED, character.SPEED)

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
