extends Node

@onready var tutorial_ui = $"../tutorial_ui"

var current_step := 0
var tutorial_active := true
var last_step_time := 0.0

var steps := [
	{
		"text": "A/D - ruch    SPACJA - skok    SHIFT - dash",
		"actions": ["left", "right", "up", "shift"],
		"minimum_time": 1.0,
		"fallback_time": 6.0
	},
	{
		"text": "LPM albo E - atak. Trzymaj dystans i celuj w przeciwnikow.",
		"actions": ["strzal"],
		"minimum_time": 0.6,
		"fallback_time": 7.0
	},
	{
		"text": "Zbieraj monety po walce. Wydasz je na bronie i ulepszenia.",
		"actions": [],
		"minimum_time": 4.0,
		"fallback_time": 4.0
	},
	{
		"text": "F - interakcja ze sklepem,lub winda.",
		"actions": ["interaction"],
		"minimum_time": 1.0,
		"fallback_time": 8.0
	},
	{
		"text": "1-4 - zmiana broni po kupieniu nowych ulepszen.",
		"actions": ["Weapon 1", "Weapon 2", "Weapon 3", "Weapon 4"],
		"minimum_time": 1.0,
		"fallback_time": 6.0
	}
]


func _ready() -> void:
	if PlayerData.tutorial_seen_this_session:
		tutorial_active = false
		tutorial_ui.hide_hint()
		return

	PlayerData.tutorial_seen_this_session = true
	await get_tree().create_timer(2).timeout
	start_tutorial()


func _process(_delta: float) -> void:
	if not tutorial_active:
		return

	var step = steps[current_step]
	var elapsed = Time.get_ticks_msec() / 1000.0 - last_step_time

	if elapsed < step["minimum_time"]:
		return

	for action in step["actions"]:
		if Input.is_action_just_pressed(action):
			next_step()
			return

	if elapsed >= step["fallback_time"]:
		next_step()


func start_tutorial() -> void:
	current_step = 0
	tutorial_active = true
	show_current_step()


func show_current_step() -> void:
	last_step_time = Time.get_ticks_msec() / 1000.0
	tutorial_ui.show_hint(steps[current_step]["text"])


func next_step() -> void:
	current_step += 1

	if current_step >= steps.size():
		finish_tutorial()
		return

	show_current_step()


func finish_tutorial() -> void:
	tutorial_active = false
	tutorial_ui.show_hint("Przetrwaj jak najwiecej rund. Powodzenia!", 3.0)
