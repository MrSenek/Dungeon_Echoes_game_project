extends Enemy_State
@onready var sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var attack_range: Area2D = $"../../detection/Attack_Range"

var search_token: int = 0


func enter(data = {}):
	search_token += 1
	var token: int = search_token
	sprite.flip_h = !sprite.flip_h
	await get_tree().create_timer(0.7).timeout
	if not _still_searching(token):
		return
	sprite.flip_h = !sprite.flip_h
	await get_tree().create_timer(0.7).timeout
	if not _still_searching(token):
		return
	sprite.flip_h = !sprite.flip_h
	await get_tree().create_timer(0.7).timeout
	if _still_searching(token):
		enemy_state_machine.change_state("caco_idle_state")


func exit():
	search_token += 1


func update(delta: float):
	var targets = character.seeing_range.get_overlapping_bodies()
	var attack_targets = attack_range.get_overlapping_bodies()
	for body in attack_targets:
		if body.is_in_group("Player"):
			enemy_state_machine.change_state("caco_attack_state")
			return
	for body in targets:
		if body.is_in_group("Player"):
			character.eyes.look_at(body.global_position)
			if character.ray_cast_2d.is_colliding() and character.ray_cast_2d.get_collider().is_in_group("Player"):
				enemy_state_machine.change_state("caco_chase_state")
				return


func _still_searching(token: int) -> bool:
	return token == search_token and enemy_state_machine.current_state == self
