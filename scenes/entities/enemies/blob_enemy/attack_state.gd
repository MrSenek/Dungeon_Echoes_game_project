extends Enemy_State
@onready var attack_timer: Timer = $attack_timer
@export var charge_speed: float = 500.0
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"
@export var electric_trail: PackedScene
@onready var ray_cast_2d: RayCast2D = $RayCast2D



var charge_dir = 1
var spawn_rate = 0.05
var spawn_timer = 0.0


func enter(data = {}):
	character.move_and_slide()
	attack_timer.start()
	if character.player_in_range:
		charge_dir = sign(character.player_in_range.global_position.x - character.global_position.x)
		character.dir = charge_dir
		if charge_dir == 1:
			sprite_2d.flip_h = false
		else:
			sprite_2d.flip_h = true

func exit():
	attack_timer.stop()

func physics_update(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	
	if character.is_on_wall():
		enemy_state_machine.change_state("stun_state")
		return
	
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_electric_trail()
		spawn_timer = spawn_rate
		
	character.velocity.x = charge_speed * charge_dir
	character.move_and_slide()


func spawn_electric_trail():
	if electric_trail:
		var trail = electric_trail.instantiate()
		trail.dmg_multiplier = character.stats.get_scaled_attack(PlayerData.current_round)
		trail.global_position = ray_cast_2d.get_collision_point()
		get_tree().current_scene.add_child(trail)

func _on_attack_timer_timeout() -> void:
	enemy_state_machine.change_state("stun_state")
