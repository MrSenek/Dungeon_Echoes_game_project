extends Enemy_State
@onready var attack_range: Area2D = $"../../detection/Attack_Range"
@export var speed: float = 400.0
@export var toxic: PackedScene
@onready var shoot_cooldown: Timer = $shoot_cooldown
@onready var delay_timer: Timer = $delay_timer


var direction: Vector2 = Vector2.RIGHT
var player_detected:bool = false
var target_player = null

func enter(data = {}):
	check_for_player()
	if target_player:
		delay_timer.start()

func physics_update(delta: float):
	check_for_player()
	if target_player:
		direction = (target_player.global_position - character.global_position).normalized()
		if shoot_cooldown.is_stopped():
			shoot()
			delay_timer.start()
	else:
		enemy_state_machine.change_state("caco_search_state")

func check_for_player():
	target_player = null
	var bodies = attack_range.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			player_detected = true
			target_player = body

func shoot():
	var attack = toxic.instantiate()
	attack.global_position = character.global_position
	attack.direction = direction
	attack.rotation = direction.angle()
	attack.smoke_damage = character.stats.base_attack
	get_tree().current_scene.add_child(attack)
	shoot_cooldown.start()
