extends CanvasLayer


@onready var button_hover: AudioStreamPlayer = $button_hover
@onready var button_click: AudioStreamPlayer = $button_click

var paused = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()


func pauseMenu():
	if !paused:
		show()
		Engine.time_scale = 0
	else:
		hide()
		Engine.time_scale = 1
	paused = !paused


func _on_resume_pressed() -> void:
	button_click.play()
	pauseMenu()



func _on_exitsave_pressed() -> void:
	button_click.play()
	await get_tree().create_timer(0.5, true, false, true).timeout
	PlayerData.save_game()
	
	get_tree().quit()


func _on_resume_mouse_entered() -> void:
	button_hover.play()


func _on_exitsave_mouse_entered() -> void:
	button_hover.play()
