extends Enemy_State

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

@export var windup_time: float = 0.12
@export var hit_range_x: float = 105.0
@export var hit_range_y: float = 16.0
@export var lunge_speed: float = 120.0

var attacked: bool = false

func enter(data = {}):
	attacked = false
	character.velocity.x = character.dir * lunge_speed
	animated_sprite_2d.play("attack")


func update(delta: float):
	if character.player and character.player.has_node("HP") and not attacked:
		attacked = true
		await get_tree().create_timer(windup_time).timeout
		if not character.player or not character.player.has_node("HP"):
			return
		if abs(character.player.global_position.x - character.global_position.x) < hit_range_x:
			if abs(character.player.global_position.y - character.global_position.y) < hit_range_y:
				character.player.get_node("HP").damage_taken(character.DMG)

func physics_update(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	character.velocity.x = move_toward(character.velocity.x, 0, 260 * delta)
	character.apply_movement_with_external_force()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		enemy_state_machine.change_state("idle_state")
