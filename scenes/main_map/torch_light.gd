extends PointLight2D


func _ready() -> void:
	var graphics_settings = get_node_or_null("/root/GraphicsSettings")
	if graphics_settings:
		graphics_settings.apply_to_node(self)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enabled = true
	var graphics_settings = get_node_or_null("/root/GraphicsSettings")
	if graphics_settings:
		graphics_settings.apply_to_node(self)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	enabled = false
