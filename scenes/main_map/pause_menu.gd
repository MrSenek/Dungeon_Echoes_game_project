extends CanvasLayer

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
	pauseMenu()



func _on_exitsave_pressed() -> void:
	PlayerData.save_game()
	get_tree().quit()
