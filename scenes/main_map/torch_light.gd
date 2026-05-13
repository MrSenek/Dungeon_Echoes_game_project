extends PointLight2D


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enabled = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	enabled = false
