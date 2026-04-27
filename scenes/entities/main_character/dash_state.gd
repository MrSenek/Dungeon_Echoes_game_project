extends State
@onready var dash_timer: Timer = $dash_timer
const GHOST = preload("uid://cdo3m08l7wcjj")

var strength: int = 500
var dir

func enter(data = {}):
	character.velocity.y = 0
	dash_timer.start()
	dir = character.dir
	character.set_collision_layer_value(1,false)
	var tween = create_tween()
	tween.tween_property(character.sprite_2d
	
func exit():
	dash_timer.stop()
	character.set_collision_layer_value(1,true)

func physics_update(delta: float):
	if abs(character.velocity.x) > 100:
		spawn_ghost()
	character.velocity.x = dir*strength
	character.move_and_slide()


func _on_dash_timer_timeout() -> void:
	state_machine.change_state("idle_state")


func spawn_ghost():
	var ghost = GHOST.instantiate()
	ghost.texture = character.sprite_2d.texture
	ghost.global_position = character.global_position
	ghost.flip_h = character.sprite_2d.flip_h
	ghost.scale = character.sprite_2d.scale
	get_tree().current_scene.add_child(ghost)
