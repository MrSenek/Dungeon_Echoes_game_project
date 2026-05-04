extends Resource

class_name Stats

@export var max_health: int = 50:
	set(value):
		max_health = value
		emit_changed() # To wyśle sygnał 'changed', który odbierze skrypt HP
@export var defence: int = 10
@export var attack: float = 1.0
