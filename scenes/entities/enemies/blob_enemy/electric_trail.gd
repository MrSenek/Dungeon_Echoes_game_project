extends Area2D

@onready var line_2d: Line2D = $Line2D
var points_count = 5
var total_length = 40 # Długość całego śladu

func _process(_delta):
	# Generujemy zygzak co klatkę, żeby prąd "żył"
	var dynamic_points = []
	for i in range(points_count):
		# Równomiernie rozkładamy punkty na długości
		var x_pos = i * (total_length / (points_count - 1))
		# Dodajemy losowe drganie w pionie
		var y_jitter = randf_range(-5, 5) 
		dynamic_points.append(Vector2(x_pos, y_jitter))
	
	line_2d.points = dynamic_points
