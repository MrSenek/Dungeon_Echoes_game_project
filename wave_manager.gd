extends Node

@export_group("Wave Manager")
@export var enemy_scenes: Array[PackedScene]
@export var spawn_points: Array[Node2D]
@export var time_between_scenes: float = 2.0
@export var min_spawn_interval: float = 0.75
@export var burst_chance: float = 0.25
@export var max_burst_size: int = 3
@onready var spawn_timer: Timer = $spawn_timer





var current_wave: int = 0
var wave_queue: Array[PackedScene] = []
var active_enemies: int = 0
var base_spawn_interval: float = 2.0

func _ready() -> void:
	base_spawn_interval = min(time_between_scenes, spawn_timer.wait_time)
	current_wave = 0
	PlayerData.current_round = 0
	PlayerData.reset_combo()
	start_new_wave()


func start_new_wave():
	if not is_inside_tree():
		return

	if spawn_timer == null or not spawn_timer.is_inside_tree():
		return

	PlayerData.current_round += 1
	if PlayerData.max_round <= PlayerData.current_round:
		PlayerData.max_round = PlayerData.current_round
	current_wave += 1
	var budget = calc_budget()
	fill_queue(budget)
	spawn_timer.wait_time = calc_spawn_interval()
	spawn_timer.start()


func calc_budget() -> int:
	return 40 + current_wave * 35


func calc_spawn_interval() -> float:
	return max(min_spawn_interval, base_spawn_interval - current_wave * 0.08)

func fill_queue(budget):
	wave_queue.clear()
	var available_enemies: Array = []
	for scene in enemy_scenes:
		var temp_enemy = scene.instantiate()
		if temp_enemy.stats.min_wave <= current_wave:
			available_enemies.append({"scene":scene, "cost": temp_enemy.stats.spawn_cost})
			temp_enemy.queue_free()
	
	while budget > 0 and available_enemies.size() > 0:
		var affordable = available_enemies.filter(func(e): return e.cost <= budget)
		if affordable.size() == 0:
			break
		var chosen = affordable.pick_random()
		wave_queue.append(chosen.scene)
		budget -= chosen.cost

func spawn_random(scene: PackedScene):
	var sp = spawn_points.pick_random()
	var enemy = scene.instantiate()
	enemy.tree_exited.connect(_on_enemy_removed)
	enemy.global_position = sp.global_position
	get_parent().add_child(enemy)
	if enemy.has_node("HP"):
		enemy.get_node("HP").death.connect(_on_enemy_killed.bind(enemy))
	active_enemies+=1


func _on_enemy_killed(enemy: Node = null) -> void:
	var source := "weapon"
	if enemy and enemy.has_meta("combo_source"):
		source = str(enemy.get_meta("combo_source"))
		enemy.remove_meta("combo_source")
	PlayerData.register_enemy_kill(source)


func _on_enemy_removed():
	if not is_inside_tree():
		return

	active_enemies -= 1

	if active_enemies <= 0 and not wave_queue:
		call_deferred("start_new_wave")


func _on_spawn_timer_timeout() -> void:
	if wave_queue.size() > 0:
		var burst_size := 1
		if current_wave >= 3 and randf() < burst_chance:
			burst_size = min(max_burst_size, 1 + int(current_wave / 4))
		for i in range(burst_size):
			if wave_queue.is_empty():
				break
			var scene_to_spawn = wave_queue.pop_back()
			spawn_random(scene_to_spawn)
	else:
		spawn_timer.stop()
