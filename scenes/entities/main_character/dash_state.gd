extends State
@onready var dash_timer: Timer = $dash_timer

const GHOST = preload("uid://cdo3m08l7wcjj")



var strength: int = 500
var dir

func enter(data = {}):
	character.sprite_2d.play("dash")
	character.velocity.y = 0
	dash_timer.start()
	dir = character.dir
	character.set_collision_layer_value(1,false)
	var tween = create_tween()
	tween.tween_property(character.sprite_2d, "scale", Vector2(1.4, 0.6), 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var return_time = dash_timer.wait_time - 0.05
	tween.tween_property(character.sprite_2d, "scale", Vector2(1.0, 1.0), return_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_delay(0.05)
	tween.set_parallel(true)
	tween.tween_property(character.sprite_2d, "modulate", Color(2, 2, 2, 1), 0.1) # Lekki błysk (Bloom)
	tween.tween_property(character.sprite_2d, "modulate", Color.WHITE, 0.3).set_delay(0.1)
	
func exit():
	dash_timer.stop()
	character.set_collision_layer_value(1,true)
	character.sprite_2d.play("default")

func physics_update(delta: float):
	if abs(character.velocity.x) > 100:
		spawn_ghost()
	character.velocity.x = dir*strength
	character.move_and_slide()



func _on_dash_timer_timeout() -> void:
	state_machine.change_state("idle_state")


func spawn_ghost():
	var ghost = GHOST.instantiate()
	
	var curr_frame_texture = character.sprite_2d.sprite_frames.get_frame_texture(
		character.sprite_2d.animation, 
		character.sprite_2d.frame
	)
	
	ghost.texture = curr_frame_texture
	ghost.global_position = character.sprite_2d.global_position
	ghost.flip_h = character.sprite_2d.flip_h
	ghost.scale = character.sprite_2d.scale
	get_tree().current_scene.add_child(ghost)
