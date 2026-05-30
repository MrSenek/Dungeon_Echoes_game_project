extends State

@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var death_timer: Timer = $death_timer



var target_zoom := Vector2(10, 10)
var zoom_speed := 2.0

func enter(data = {}):
	death_timer.start()
	Engine.time_scale = 0.25


func exit():
	Engine.time_scale = 1

func update(delta: float):
	camera_2d.zoom = camera_2d.zoom.lerp(target_zoom, zoom_speed * delta)


func _on_death_timer_timeout() -> void:
	var map = character.get_parent()
	if map.has_method("show_death_screen"):
		map.show_death_screen()
	else:
		map.reset_scene()
