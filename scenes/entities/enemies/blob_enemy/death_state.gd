extends Enemy_State
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"
@onready var death_timer: Timer = $death_timer


func enter(data = {}):
	print("ded")
	death_timer.start()
	sprite_2d.stop()
	sprite_2d.frame = 3



func _on_death_timer_timeout() -> void:
	character.queue_free()
