extends Enemy_State
@onready var look_around_timer: Timer = $look_around_timer
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"

var times_checked:int = 0



func enter(data = {}):
	look_around_timer.start()
	times_checked = 0

func exit():
	print("exiting")
	look_around_timer.stop()

func _on_look_around_timer_timeout() -> void:
	sprite_2d.flip_h = not sprite_2d.flip_h
	times_checked += 1
	look_around_timer.start()
	

func update(delta: float):
	if times_checked >= 4 :
		enemy_state_machine.change_state("wander_state")
	
