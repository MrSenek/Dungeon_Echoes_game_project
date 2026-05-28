extends Enemy_State


@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"


@export var chase_speed: int = 145
@export var attack_start_range: float = 72.0

func enter(data = {}):
	print("chase")
	animated_sprite_2d.play("walk")
	animated_sprite_2d.speed_scale = 1.5

func exit():
	animated_sprite_2d.speed_scale = 1

func update(delta: float):
	if not character.player or not character.player_in_range:
		enemy_state_machine.change_state("wander_state")
		return

	if character.player_dir < 0:
		character.dir = -1
		animated_sprite_2d.flip_h = false
	else:
		character.dir = 1
		animated_sprite_2d.flip_h = true
	if abs(character.player.global_position.x - character.global_position.x) < attack_start_range:
		enemy_state_machine.change_state("attack_state")

func physics_update(delta: float):
	if not character.player_in_range:
		enemy_state_machine.change_state("wander_state")
		return

	character.velocity.x = chase_speed * character.dir
	character.apply_movement_with_external_force()
