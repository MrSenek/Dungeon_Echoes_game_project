extends RefCounted

const HEALTH_PICKUP_SCENE: PackedScene = preload("res://scenes/entities/collectables/truskawka.tscn")
const LOW_HP_THRESHOLD := 0.35
const CRITICAL_HP_THRESHOLD := 0.2
const HIGH_HP_THRESHOLD := 0.7
const FULL_HP_THRESHOLD := 0.95
const LOW_HP_CHANCE_MULTIPLIER := 1.6
const CRITICAL_HP_CHANCE_MULTIPLIER := 2.2
const HIGH_HP_CHANCE_MULTIPLIER := 0.5


static func try_drop(drop_position: Vector2, base_chance: float) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree or not tree.current_scene:
		return

	var chance := _get_adjusted_chance(DifficultySettings.get_health_drop_chance(base_chance))
	if randf() > chance:
		return

	var pickup := HEALTH_PICKUP_SCENE.instantiate() as Node2D
	if not pickup:
		return

	var landing_position := drop_position + Vector2(randf_range(-22, 22), randf_range(-10, 8))
	pickup.global_position = drop_position
	tree.current_scene.add_child(pickup)

	var tween := pickup.create_tween()
	tween.tween_property(pickup, "global_position", landing_position + Vector2(0, -18), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(pickup, "global_position", landing_position, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


static func _get_adjusted_chance(base_chance: float) -> float:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		return base_chance

	var player := tree.get_first_node_in_group("Player")
	if not player or not player.has_node("HP"):
		return base_chance

	var hp = player.get_node("HP")
	if hp.MAX_HEALTH <= 0:
		return base_chance

	var health_percent: float = float(hp.CURRENT_HEALTH) / float(hp.MAX_HEALTH)
	if health_percent >= FULL_HP_THRESHOLD:
		return 0.0
	if health_percent >= HIGH_HP_THRESHOLD:
		return base_chance * HIGH_HP_CHANCE_MULTIPLIER
	if health_percent <= CRITICAL_HP_THRESHOLD:
		return min(base_chance * CRITICAL_HP_CHANCE_MULTIPLIER, 0.75)
	if health_percent <= LOW_HP_THRESHOLD:
		return min(base_chance * LOW_HP_CHANCE_MULTIPLIER, 0.55)
	return base_chance
