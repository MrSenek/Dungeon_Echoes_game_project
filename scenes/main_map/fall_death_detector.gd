extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if get_tree().paused:
		return
	if body.has_node("HP"):
		body.get_node("HP").damage_taken(99999)
