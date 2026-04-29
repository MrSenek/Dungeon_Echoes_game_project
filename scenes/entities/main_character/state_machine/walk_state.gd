extends State

class_name walk_state

var idle_timer := 0.0
const IDLE_TIMER := 1.0



func physics_update(delta: float):
	print(character.is_on_wall())
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta * character.speed_modifier

	var direction := Input.get_axis("ui_left", "ui_right")
	var speed = direction*character.SPEED*character.speed_modifier
	if direction:
		character.velocity.x = move_toward(character.velocity.x, speed, character.SPEED)
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, character.SPEED)
	character.move_and_slide()
	
	if direction: 
		if direction < 0:
			character.sprite_2d.flip_h = true
		elif direction > 0:
			character.sprite_2d.flip_h = false

	
	if direction == 0 and is_equal_approx(character.velocity.x, 0):
		idle_timer -= delta
		
		if idle_timer <= 0:
			state_machine.change_state("idle_state")
			return
	else:
		idle_timer = IDLE_TIMER
	
func handle_input(event: InputEvent):
	
	if event.is_action_pressed("ui_accept"):
		state_machine.change_state("jump_state")
	if event.is_action_pressed("shift"):
		state_machine.change_state("dash_state")
