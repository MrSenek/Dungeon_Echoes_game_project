extends Node
signal stats_changed

@export var max_health: int = 200:
	set(value):
		max_health = value
		stats_changed.emit()
@export var defence: int = 10
@export var attack: float = 1
var player_coins = 99999
var current_health = 10
var owned_weapons = ["fireball"]
