extends Control

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var duration: float = 1.0
var time_left: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(150, 150)
	set_process(false)

func start_cooldown(weapon_name: String, cooldown_duration: float) -> void:
	duration = cooldown_duration
	time_left = duration

	texture_progress_bar.min_value = 0
	texture_progress_bar.max_value = 100
	texture_progress_bar.value = 100

	set_process(true)

func _process(delta: float) -> void:
	time_left -= delta

	var percent := time_left / duration * 100.0
	texture_progress_bar.value = clamp(percent, 0.0, 100.0)

	if time_left <= 0.0:
		queue_free()
