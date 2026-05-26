extends CanvasLayer

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@export var cooldown_bar_scene: PackedScene
@onready var cooldown_container: HBoxContainer = $cooldown_container


func _ready() -> void:
	# Łączymy się z sygnałem globalnym przy starcie gry
	Money.coin_collected.connect(_on_coin_collected)


func _process(delta: float) -> void:

	label.text = str(PlayerData.player_coins)

func _on_coin_collected(new_amount):
	label.text = str(new_amount) # Aktualizujemy tekst, gdy przyjdzie sygnał


func show_cooldown(weapon_name: String, duration: float) -> void:
	var bar = cooldown_bar_scene.instantiate()
	cooldown_container.add_child(bar)
	bar.start_cooldown(weapon_name, duration)
