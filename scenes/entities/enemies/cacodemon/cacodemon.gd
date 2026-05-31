extends CharacterBody2D
@onready var eyes: Node2D = $eyes
@onready var ray_cast_2d: RayCast2D = $eyes/RayCast2D
@export var stats: Stats
@export var patrol_radius: float = 520.0
@export var return_radius: float = 650.0
@onready var seeing_range: Area2D = $detection/Seeing_Range

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var spawn_position: Vector2
var spawn_position_set: bool = false

func _enter_tree() -> void:
	_set_spawn_position()


func _ready() -> void:
	if not spawn_position_set:
		_set_spawn_position()


func _set_spawn_position() -> void:
	spawn_position = global_position
	spawn_position_set = true


func is_outside_return_radius() -> bool:
	return global_position.distance_to(spawn_position) > return_radius
