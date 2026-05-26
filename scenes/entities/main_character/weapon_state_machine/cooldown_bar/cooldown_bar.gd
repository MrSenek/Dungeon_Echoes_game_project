extends Control
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar


var cooldown_started: bool = false
var time: float = 100
var weapon = null

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	texture_progress_bar.value = time


func start_cooldown():
	texture_progress_bar.value = time
	set_process(true)
