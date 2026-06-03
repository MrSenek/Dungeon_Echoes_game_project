extends Node

@export_group("Wave Manager")
@export var enemy_scenes: Array[PackedScene]
@export var spawn_points: Array[Node2D]
@export var time_between_scenes: float = 2.0
@export var min_spawn_interval: float = 0.75
@export var burst_chance: float = 0.25
@export var max_burst_size: int = 3
@export var min_player_spawn_distance: float = 260.0
@export var spawn_telegraph_time: float = 0.55
@onready var spawn_timer: Timer = $spawn_timer





var current_wave: int = 0
var wave_queue: Array[PackedScene] = []
var active_enemies: int = 0
var base_spawn_interval: float = 2.0
var portal_shadow_texture: GradientTexture2D
var portal_glow_texture: GradientTexture2D
var portal_additive_material: CanvasItemMaterial
var portal_ring_points: PackedVector2Array = PackedVector2Array()
var portal_inner_ring_points: PackedVector2Array = PackedVector2Array()
var portal_core_points: PackedVector2Array = PackedVector2Array()

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

func spawn_random(scene: PackedScene) -> bool:
	var sp = get_safe_spawn_point()
	if sp == null:
		return false
	var spawn_position: Vector2 = sp.global_position
	play_spawn_telegraph(spawn_position)
	spawn_enemy_after_telegraph(scene, spawn_position)
	return true


func spawn_enemy_after_telegraph(scene: PackedScene, spawn_position: Vector2) -> void:
	await get_tree().create_timer(spawn_telegraph_time).timeout
	if not is_inside_tree():
		return

	var enemy = scene.instantiate()
	enemy.tree_exited.connect(_on_enemy_removed)
	enemy.global_position = spawn_position
	get_parent().add_child(enemy)
	enemy.modulate = Color(1.35, 1.35, 1.35, 0.0)
	enemy.scale *= 0.72
	if enemy.has_node("HP"):
		enemy.get_node("HP").death.connect(_on_enemy_killed.bind(enemy))
	active_enemies+=1
	var tween: Tween = enemy.create_tween().set_parallel(true)
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(enemy, "scale", enemy.scale / 0.72, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func play_spawn_telegraph(spawn_position: Vector2) -> void:
	var portal: Node2D = Node2D.new()
	portal.name = "SpawnTelegraph"
	portal.global_position = spawn_position
	portal.z_index = 3
	get_parent().add_child(portal)

	var shadow: Sprite2D = Sprite2D.new()
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shadow.texture = get_portal_shadow_texture()
	shadow.scale = Vector2.ZERO
	shadow.z_index = -2
	portal.add_child(shadow)

	var glow: Sprite2D = Sprite2D.new()
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glow.texture = get_portal_glow_texture()
	glow.scale = Vector2.ZERO
	glow.material = get_portal_additive_material()
	glow.z_index = -1
	portal.add_child(glow)

	var ring: Line2D = Line2D.new()
	ring.width = 2.2
	ring.default_color = Color(0.82, 0.05, 0.16, 0.95)
	ring.points = get_portal_ring_points()
	ring.scale = Vector2.ZERO
	portal.add_child(ring)

	var inner_ring: Line2D = Line2D.new()
	inner_ring.width = 1.3
	inner_ring.default_color = Color(0.58, 0.03, 0.82, 0.82)
	inner_ring.points = get_portal_inner_ring_points()
	inner_ring.scale = Vector2.ZERO
	portal.add_child(inner_ring)

	var core: Polygon2D = Polygon2D.new()
	core.color = Color(0.02, 0.0, 0.035, 0.88)
	core.polygon = get_portal_core_points()
	core.scale = Vector2.ZERO
	core.z_index = 1
	portal.add_child(core)

	var rune: Line2D = Line2D.new()
	rune.width = 1.4
	rune.default_color = Color(0.72, 0.04, 0.74, 0.88)
	rune.points = PackedVector2Array([
		Vector2(-15, 10),
		Vector2(0, -17),
		Vector2(15, 10),
		Vector2(-15, 10),
	])
	rune.scale = Vector2.ZERO
	portal.add_child(rune)

	for i in range(6):
		var crack: Line2D = Line2D.new()
		var angle: float = TAU * float(i) / 6.0 + 0.28
		var start: Vector2 = Vector2(cos(angle), sin(angle)) * 9.0
		var end: Vector2 = Vector2(cos(angle), sin(angle)) * randf_range(24.0, 33.0)
		crack.width = randf_range(0.8, 1.3)
		crack.default_color = Color(0.95, 0.12, 0.22, 0.72)
		crack.points = PackedVector2Array([start, end])
		crack.scale = Vector2.ZERO
		portal.add_child(crack)

		var crack_tween: Tween = crack.create_tween().set_parallel(true)
		crack_tween.tween_property(crack, "scale", Vector2.ONE, spawn_telegraph_time * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		crack_tween.tween_property(crack, "modulate:a", 0.0, spawn_telegraph_time * 0.32).set_delay(spawn_telegraph_time * 0.58)

	var tween: Tween = portal.create_tween().set_parallel(true)
	tween.tween_property(shadow, "scale", Vector2(1.35, 0.72), spawn_telegraph_time * 0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(glow, "scale", Vector2.ONE * 1.05, spawn_telegraph_time * 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "scale", Vector2.ONE, spawn_telegraph_time * 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(inner_ring, "scale", Vector2.ONE, spawn_telegraph_time * 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(core, "scale", Vector2.ONE, spawn_telegraph_time * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(rune, "scale", Vector2.ONE, spawn_telegraph_time * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "rotation", TAU, spawn_telegraph_time)
	tween.tween_property(inner_ring, "rotation", -TAU * 1.35, spawn_telegraph_time)
	tween.tween_property(core, "scale", Vector2.ONE * 1.35, spawn_telegraph_time * 0.28).set_delay(spawn_telegraph_time * 0.68).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(shadow, "modulate:a", 0.0, spawn_telegraph_time * 0.28).set_delay(spawn_telegraph_time * 0.72)
	tween.tween_property(glow, "modulate:a", 0.0, spawn_telegraph_time * 0.35).set_delay(spawn_telegraph_time * 0.65)
	tween.tween_property(ring, "modulate:a", 0.0, spawn_telegraph_time * 0.25).set_delay(spawn_telegraph_time * 0.75)
	tween.tween_property(inner_ring, "modulate:a", 0.0, spawn_telegraph_time * 0.25).set_delay(spawn_telegraph_time * 0.75)
	tween.tween_property(core, "modulate:a", 0.0, spawn_telegraph_time * 0.2).set_delay(spawn_telegraph_time * 0.78)
	tween.tween_property(rune, "modulate:a", 0.0, spawn_telegraph_time * 0.25).set_delay(spawn_telegraph_time * 0.75)
	tween.tween_callback(portal.queue_free).set_delay(spawn_telegraph_time + 0.05)


func get_portal_shadow_texture() -> GradientTexture2D:
	if portal_shadow_texture == null:
		portal_shadow_texture = make_radial_texture(Color(0.0, 0.0, 0.0, 0.92), Color(0.0, 0.0, 0.0, 0.0), 118)
	return portal_shadow_texture


func get_portal_glow_texture() -> GradientTexture2D:
	if portal_glow_texture == null:
		portal_glow_texture = make_radial_texture(Color(0.38, 0.02, 0.12, 0.72), Color(0.05, 0.0, 0.12, 0.0), 110)
	return portal_glow_texture


func get_portal_additive_material() -> CanvasItemMaterial:
	if portal_additive_material == null:
		portal_additive_material = make_additive_material()
	return portal_additive_material


func get_portal_ring_points() -> PackedVector2Array:
	if portal_ring_points.is_empty():
		portal_ring_points = make_circle_points(25.0, 34)
	return portal_ring_points


func get_portal_inner_ring_points() -> PackedVector2Array:
	if portal_inner_ring_points.is_empty():
		portal_inner_ring_points = make_circle_points(14.0, 24)
	return portal_inner_ring_points


func get_portal_core_points() -> PackedVector2Array:
	if portal_core_points.is_empty():
		portal_core_points = make_circle_points(8.0, 18)
	return portal_core_points


func make_circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(segments):
		var angle: float = TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	if points.size() > 0:
		points.append(points[0])
	return points


func make_radial_texture(center_color: Color, edge_color: Color, size: int) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([
		center_color,
		center_color.lerp(edge_color, 0.35),
		edge_color,
	])

	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.width = size
	texture.height = size
	texture.fill = 1
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.96, 0.5)
	texture.gradient = gradient
	return texture


func make_additive_material() -> CanvasItemMaterial:
	var material: CanvasItemMaterial = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return material


func get_safe_spawn_point() -> Node2D:
	if spawn_points.is_empty():
		return null

	var players: Array[Node] = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return spawn_points.pick_random()

	var player: Node2D = players[0] as Node2D
	if player == null:
		return spawn_points.pick_random()

	var safe_spawn_points: Array[Node2D] = []
	for spawn_point in spawn_points:
		if spawn_point == null:
			continue
		if spawn_point.global_position.distance_to(player.global_position) >= min_player_spawn_distance:
			safe_spawn_points.append(spawn_point)

	if safe_spawn_points.is_empty():
		return null

	return safe_spawn_points.pick_random()


func _on_enemy_killed(enemy: Node = null) -> void:
	var source: String = "weapon"
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
		var burst_size: int = 1
		if current_wave >= 3 and randf() < burst_chance:
			burst_size = min(max_burst_size, 1 + int(current_wave / 4))
		for i in range(burst_size):
			if wave_queue.is_empty():
				break
			var scene_to_spawn = wave_queue.back()
			if spawn_random(scene_to_spawn):
				wave_queue.pop_back()
			else:
				break
	else:
		spawn_timer.stop()
