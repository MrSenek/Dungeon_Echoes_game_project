extends Line2D

@export var segments: int = 6
@export var deviation: float = 15.0
@export var travel_speed: float = 1400.0
@export var trail_length: float = 140.0

var lightning_path: Array[Vector2] = []
var travel_distance := 0.0
var animation_active := false


func _ready():
	clear_points()


func create_lightning(start_pos: Vector2, end_pos: Vector2):
	lightning_path = [start_pos, end_pos]
	travel_distance = 0.0
	animation_active = true
	_redraw_lightning_path(0.0)


func create_chain_lightning(path: Array[Vector2]):
	lightning_path = path.duplicate()
	animation_active = true
	_redraw_lightning_path(0.0)


func clear_lightning():
	lightning_path.clear()
	travel_distance = 0.0
	animation_active = false
	clear_points()


func _redraw_lightning_path(delta: float):
	clear_points()
	if lightning_path.size() < 2:
		return

	travel_distance += travel_speed * delta
	var lightning_points = _build_lightning_points()
	var path_length = _get_path_length(lightning_points)
	if path_length <= 0.0:
		return

	var visible_start = max(travel_distance - trail_length, 0.0)
	var visible_end = min(travel_distance, path_length)
	if visible_start >= path_length:
		animation_active = false
		return
	if visible_end <= visible_start:
		visible_end = min(visible_start + 1.0, path_length)

	_add_visible_path(lightning_points, visible_start, visible_end)


func _build_lightning_points() -> Array[Vector2]:
	var lightning_points: Array[Vector2] = [lightning_path[0]]
	for path_index in range(lightning_path.size() - 1):
		var start_pos = lightning_path[path_index]
		var end_pos = lightning_path[path_index + 1]
		var segment_direction = end_pos - start_pos
		if segment_direction.length() == 0.0:
			continue

		for i in range(1, segments):
			var progress = float(i) / segments
			var base_pos = start_pos.lerp(end_pos, progress)
			var direction = segment_direction.normalized()
			var normal = Vector2(-direction.y, direction.x)
			var offset = normal * randf_range(-deviation, deviation)
			lightning_points.append(base_pos + offset)

		lightning_points.append(end_pos)

	return lightning_points


func _get_path_length(path_points: Array[Vector2]) -> float:
	var path_length := 0.0
	for point_index in range(path_points.size() - 1):
		path_length += path_points[point_index].distance_to(path_points[point_index + 1])
	return path_length


func _add_visible_path(path_points: Array[Vector2], visible_start: float, visible_end: float) -> void:
	var walked_distance := 0.0
	for point_index in range(path_points.size() - 1):
		var segment_start = path_points[point_index]
		var segment_end = path_points[point_index + 1]
		var segment_length = segment_start.distance_to(segment_end)
		if segment_length == 0.0:
			continue

		var segment_visible_start = max(visible_start - walked_distance, 0.0)
		var segment_visible_end = min(visible_end - walked_distance, segment_length)
		if segment_visible_end > 0.0 and segment_visible_start < segment_length:
			var start_point = segment_start.lerp(segment_end, segment_visible_start / segment_length)
			var end_point = segment_start.lerp(segment_end, segment_visible_end / segment_length)
			if points.size() == 0 or points[points.size() - 1] != start_point:
				add_point(start_point)
			add_point(end_point)

		walked_distance += segment_length
		if walked_distance > visible_end:
			break


func _process(delta):
	if animation_active and lightning_path.size() > 1:
		_redraw_lightning_path(delta)
