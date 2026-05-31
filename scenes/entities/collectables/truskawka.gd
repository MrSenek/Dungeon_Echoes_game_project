extends Area2D
@export_range(0.01, 1.0, 0.01) var heal_percent: float = 0.22


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player") or not body.has_node("HP"):
		return

	var hp = body.get_node("HP")
	var heal_amount := int(ceil(hp.MAX_HEALTH * heal_percent))
	hp.get_hp(heal_amount)
	queue_free()
