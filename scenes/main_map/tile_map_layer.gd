extends TileMapLayer

@export var light_scene: PackedScene


func _ready() -> void:
	for cell in get_used_cells():
		var data := get_cell_tile_data(cell)
		if data and data.get_custom_data("is_light"):
			var new_light := light_scene.instantiate()
			new_light.position = map_to_local(cell)
			add_child(new_light)
			var graphics_settings = get_node_or_null("/root/GraphicsSettings")
			if graphics_settings:
				graphics_settings.apply_to_node(new_light)
