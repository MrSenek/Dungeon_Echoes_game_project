extends State

class_name jump_state
const max_jumps : int= 200
var jumps : int= 0

func enter(data = {}):
	if character.is_on_floor():
		character.velocity.y = character.JUMP_VELOCITY
		jumps = 1
	else:
		jumps = 1

func physics_update(delta: float):
	if Input.is_action_just_pressed("ui_accept") and jumps < max_jumps and not character.is_on_floor():
		character.velocity.y = character.JUMP_VELOCITY*0.8
		jumps += 1
		
	# Add the gravity.
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
		
	#change direction and move in air
	var direction = Input.get_axis("left", "right")
	character.velocity.x = direction * character.SPEED
	if direction < 0:
		character.sprite_2d.flip_h = true
	elif direction > 0:
		character.sprite_2d.flip_h = false
	
	character.move_and_slide()


	if character.is_on_floor() and character.velocity.y >= 0:
		if direction != 0:
			state_machine.change_state("walk_state")
		else:
			state_machine.change_state("idle_state")

func handle_input(event: InputEvent):
	if event.is_action_pressed("shift"):
		state_machine.change_state("dash_state")
