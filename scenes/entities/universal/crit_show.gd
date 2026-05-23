extends Node2D

@onready var label = $Label

func _ready():
	scale = Vector2.ZERO
	
	var tween = create_tween()

	tween.parallel().tween_property(self, "position:y", position.y - 70, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)

	await tween.finished
	queue_free()
