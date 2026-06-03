extends Node2D

const MAX_ACTIVE_SMOKE_CLOUDS := 8

static var active_smoke_clouds := 0

@onready var area_2d: Area2D = $Area2D
@onready var damage_cooldown: Timer = $damage_cooldown
@onready var smoke_timer: Timer = $smoke_timer

@export var damage = 20

var bodies_list: Array[Node2D] = []
var counted_as_active := false


func _ready() -> void:
	if active_smoke_clouds >= MAX_ACTIVE_SMOKE_CLOUDS:
		queue_free()
		return
	active_smoke_clouds += 1
	counted_as_active = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("change_speed"):
		body.change_speed(0.5)

	if body.is_in_group("Player") and body.has_node("HP"):
		if not bodies_list.has(body):
			bodies_list.append(body)

		if damage_cooldown.is_stopped():
			damage_cooldown.start()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if bodies_list.has(body):
		bodies_list.erase(body)

	if body.has_method("change_speed"):
		body.change_speed(1.0)

	if bodies_list.is_empty():
		damage_cooldown.stop()


func _on_damage_cooldown_timeout() -> void:
	for body in bodies_list.duplicate():
		if is_instance_valid(body) and body.has_node("HP"):
			body.get_node("HP").damage_taken(damage)
		else:
			bodies_list.erase(body)

	if not bodies_list.is_empty():
		damage_cooldown.start()


func _on_smoke_timer_timeout() -> void:
	for body in area_2d.get_overlapping_bodies():
		if body.has_method("change_speed"):
			body.change_speed(1.0)
	queue_free()


func _exit_tree() -> void:
	if counted_as_active:
		active_smoke_clouds = max(active_smoke_clouds - 1, 0)
