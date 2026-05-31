extends Enemy_State

class_name caco_idle_state

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer: Timer = $Timer


var dir: int = 1
var turn_cooldown: float = 0.0

func enter(data = {}):
	character.velocity = Vector2.ZERO

func physics_update(delta: float):
	turn_cooldown = max(turn_cooldown - delta, 0.0)

	# normalne idle
	var distance_from_spawn: float = character.global_position.x - character.spawn_position.x
	if abs(distance_from_spawn) > character.patrol_radius:
		dir = int(-sign(distance_from_spawn))
		timer.start(1.0)

	if timer.is_stopped():
		dir = [1, -1].pick_random()
		timer.start(randi_range(1, 2))

	character.velocity.x = move_toward(character.velocity.x, dir * character.SPEED, character.SPEED)

	if dir == -1:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true

	character.move_and_slide()
	if turn_cooldown <= 0.0 and _hit_horizontal_wall():
		turn_around()

func update(delta: float):
	var targets = character.seeing_range.get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("Player"):
			character.eyes.look_at(body.global_position)
			if character.ray_cast_2d.is_colliding() and character.ray_cast_2d.get_collider().is_in_group("Player"):
				enemy_state_machine.change_state("caco_chase_state")


func turn_around() -> void:
	dir *= -1
	turn_cooldown = 0.45
	timer.start(1.0)


func _hit_horizontal_wall() -> bool:
	for i in range(character.get_slide_collision_count()):
		var collision: KinematicCollision2D = character.get_slide_collision(i)
		if collision and abs(collision.get_normal().x) > 0.5:
			return true
	return false
