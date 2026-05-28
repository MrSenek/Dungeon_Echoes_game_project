extends TileMapLayer

@export var light_scene: PackedScene # Tu podpinasz scenę z PointLight2D i Notifierem

func _ready():
	for cell in get_used_cells():
		var data = get_cell_tile_data(cell)
		if data and data.get_custom_data("is_light"):
			var new_light = light_scene.instantiate()
			# Ustawienie pozycji światła na środku kafelka
			new_light.position = map_to_local(cell)
			add_child(new_light)
