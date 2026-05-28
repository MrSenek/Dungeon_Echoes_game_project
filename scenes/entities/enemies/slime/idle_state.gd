extends Enemy_State

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var wait_timer: Timer = $wait_timer


func enter(data = {}):
	print("idle")
	character.velocity.x = 0
	wait_timer.start()
	animated_sprite_2d.play("idle")

func exit():
	wait_timer.stop()

func physics_update(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	
		
	character.apply_movement_with_external_force()


func _on_wait_timer_timeout() -> void:
	enemy_state_machine.change_state("wander_state")
