extends TextureProgressBar
@onready var label: Label = $Label

var start = 1

func _on_node_health_changed(current, max_hp):
	max_value = max_hp
	value = current
	label.text = str(current)
