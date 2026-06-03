extends Area2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var gas: PackedScene

var direction: Vector2 = Vector2.RIGHT
var SPEED = 300
var smoke_damage: int

var collided: bool = false

static var impact_flash_texture: GradientTexture2D
static var additive_material: CanvasItemMaterial


func _physics_process(delta: float) -> void:
	if collided:
		return
	if ray_cast_2d.is_colliding() and not collided:
		collided = true
		var impact_position: Vector2 = ray_cast_2d.get_collision_point()
		global_position = impact_position - direction.normalized() * 8.0
		ray_cast_2d.enabled = false
		_play_impact_effect(impact_position)
		await get_tree().create_timer(0.12).timeout
		_spawn_toxic_cloud(impact_position)
		await get_tree().create_timer(0.16).timeout
		queue_free()
		return
	global_position += direction * SPEED * delta


func _spawn_toxic_cloud(impact_position: Vector2) -> void:
	var toxic_cloud: Node2D = gas.instantiate() as Node2D
	if toxic_cloud == null:
		return
	toxic_cloud.global_position = impact_position
	if "damage" in toxic_cloud:
		toxic_cloud.damage *= smoke_damage
	get_tree().current_scene.add_child(toxic_cloud)


func _play_impact_effect(impact_position: Vector2) -> void:
	if sprite_2d:
		var sprite_tween: Tween = create_tween().set_parallel(true)
		sprite_tween.tween_property(sprite_2d, "scale", sprite_2d.scale * 1.55, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		sprite_tween.tween_property(sprite_2d, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var impact_root: Node2D = Node2D.new()
	impact_root.name = "ToxicImpact"
	impact_root.global_position = impact_position
	impact_root.z_index = 5
	get_tree().current_scene.add_child(impact_root)

	var flash: Sprite2D = Sprite2D.new()
	flash.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	flash.texture = _get_impact_flash_texture()
	flash.scale = Vector2.ZERO
	flash.material = _get_additive_material()
	impact_root.add_child(flash)

	for i in range(5):
		var shard: Line2D = Line2D.new()
		var angle: float = direction.angle() + randf_range(-1.25, 1.25) + PI
		var length: float = randf_range(12.0, 24.0)
		shard.width = randf_range(1.0, 1.8)
		shard.default_color = Color(0.36, 0.95, 0.38, 0.75)
		shard.points = PackedVector2Array([Vector2.ZERO, Vector2(cos(angle), sin(angle)) * length])
		impact_root.add_child(shard)

		var shard_tween: Tween = shard.create_tween().set_parallel(true)
		shard_tween.tween_property(shard, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		shard_tween.tween_property(shard, "scale", Vector2(1.35, 1.35), 0.18)

	var tween: Tween = impact_root.create_tween().set_parallel(true)
	tween.tween_property(flash, "scale", Vector2.ONE * 0.85, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(flash, "modulate:a", 0.0, 0.2).set_delay(0.04)
	tween.tween_callback(impact_root.queue_free).set_delay(0.28)


func _get_impact_flash_texture() -> GradientTexture2D:
	if impact_flash_texture == null:
		impact_flash_texture = _make_radial_texture(Color(0.56, 1.0, 0.38, 0.82), Color(0.02, 0.25, 0.08, 0.0), 72)
	return impact_flash_texture


func _get_additive_material() -> CanvasItemMaterial:
	if additive_material == null:
		additive_material = CanvasItemMaterial.new()
		additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return additive_material


static func _make_radial_texture(center_color: Color, edge_color: Color, size: int) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	gradient.colors = PackedColorArray([
		center_color,
		center_color.lerp(edge_color, 0.38),
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
