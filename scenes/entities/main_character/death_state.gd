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
	character.get_parent().reset_scene()
