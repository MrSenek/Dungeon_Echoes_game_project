extends State

class_name idle_state
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"

func enter(data = {}):
	sprite_2d.play("default")
	character.velocity.x = 0


func physics_update(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	character.move_and_slide()
	var input_dir = Input.get_axis("left","right")
	if input_dir != 0:
		state_machine.change_state("walk_state")
	if Input.is_action_just_pressed("ui_accept"):
		state_machine.change_state("jump_state")
