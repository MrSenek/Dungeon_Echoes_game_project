extends CharacterBody2D
@onready var eyes: Node2D = $eyes
@onready var ray_cast_2d: RayCast2D = $eyes/RayCast2D
@export var stats: Stats
@onready var seeing_range: Area2D = $detection/Seeing_Range

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

func _on_node_death() -> void:
	queue_free()
