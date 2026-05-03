extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var damage_cooldown: Timer = $damage_cooldown
@onready var smoke_timer: Timer = $smoke_timer

var bodies_list = []

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("change_speed"):
		body.change_speed(0.75)
	
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
	# Zadajemy dmg każdemu z listy dokładnie RAZ
	for b in bodies_list:
		if is_instance_valid(b) and b.has_node("HP"):
			b.get_node("HP").damage_taken(1)
	
	# Timer restartuje się tylko jeśli ktoś nadal stoi w gazie
	if not bodies_list.is_empty():
		damage_cooldown.start()

func _on_smoke_timer_timeout() -> void:
	for body in area_2d.get_overlapping_bodies():
		if body.has_method("change_speed"):
			body.change_speed(1.0)
	queue_free()
