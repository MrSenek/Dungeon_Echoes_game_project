extends CanvasLayer

@onready var label: Label = $MarginContainer/HBoxContainer/Label

func _ready() -> void:
	# Łączymy się z sygnałem globalnym przy starcie gry
	Money.coin_collected.connect(_on_coin_collected)
	# Ustawiamy tekst początkowy
	#label.text = str(Money.coins)
	

func _process(delta: float) -> void:
	#label.text = str(Engine.get_frames_per_second())
	#label.text = str(PlayerData.current_round)
	label.text = str(PlayerData.player_coins)

func _on_coin_collected(new_amount):
	label.text = str(new_amount) # Aktualizujemy tekst, gdy przyjdzie sygnał
