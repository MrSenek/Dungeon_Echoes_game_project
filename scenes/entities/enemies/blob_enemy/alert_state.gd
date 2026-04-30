extends Enemy_State
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var alert_time: Timer = $alert_time


func enter(data = {}):
	print("going alert")
	alert_time.start()
	sprite_2d.show()

func exit():
	sprite_2d.hide()
	alert_time.stop()
	




func _on_alert_time_timeout() -> void:
	enemy_state_machine.change_state("charge_state")
