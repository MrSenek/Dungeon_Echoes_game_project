extends State
@onready var recoil: Timer = $recoil
const GHOST = preload("uid://cdo3m08l7wcjj")


var char_dir: int
var base_recoil = 1

func enter(data = {}):
	var recoil_strength = data.get("strength", base_recoil)
	char_dir = character.dir
	character.velocity.x = char_dir*recoil_strength*-1
	recoil.start()
	character.sprite_2d.material.set_shader_parameter("blur_amount", 3.0)
	

func exit():
	recoil.stop()
	character.sprite_2d.material.set_shader_parameter("blur_amount", 0.0)

func physics_update(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept"):
		
		state_machine.change_state("jump_state")
	character.move_and_slide()
	

func _on_recoil_timeout() -> void:
	state_machine.change_state("idle_state")
