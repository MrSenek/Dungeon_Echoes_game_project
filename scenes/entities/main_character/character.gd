extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var HEALTH_POINTS: int = PlayerData.max_health
var SPAWN_POINT
var dir
var speed_modifier: float = 1.0

func _ready() -> void:
	SPAWN_POINT = global_position
	self.add_to_group("Player")
	dir = sprite_2d.flip_h
	

func _process(delta: float) -> void:
	if Input.get_axis("left","right") != 0:
		dir = Input.get_axis("left", "right")

func _on_hp_death() -> void:
		global_position = SPAWN_POINT
		get_node("HP").CURRENT_HEALTH = HEALTH_POINTS
		get_node("HP").set_health(HEALTH_POINTS)

func change_speed(new: float):
	speed_modifier = new
