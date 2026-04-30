extends Enemy_State
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var timer: Timer = $Timer
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"


var bump_timer = 0.3

func enter(data = {}):
	bump_timer = 0.3
	character.velocity.y = -140
	character.velocity.x = character.dir * 150 * -1
	timer.start()

func exit():
	sprite_2d.play("new_animation")
	gpu_particles_2d.emitting = false
	timer.stop()

func physics_update(delta: float):
	character.velocity += character.get_gravity() * delta
	bump_timer -= delta
	
	if bump_timer <= 0:
		sprite_2d.stop()
		sprite_2d.frame = 3
		gpu_particles_2d.emitting = true
		character.velocity.x = 0
	
	character.move_and_slide()

func _on_timer_timeout() -> void:
	enemy_state_machine.change_state("idle_state")
