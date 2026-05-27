extends Area2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@export var explosion_damage: int
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	audio_stream_player_2d.play()
	monitoring = true
	gpu_particles_2d.emitting = true
	await get_tree().physics_frame
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_node("HP"):
			body.get_node("HP").damage_taken(explosion_damage)
	get_tree().create_timer(1.0).timeout.connect(queue_free)
