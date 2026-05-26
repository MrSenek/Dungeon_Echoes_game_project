extends Node

class_name Weapon_State_Machine

@export var initial_state: Weapon_State

var current_state : Weapon_State
var states: Dictionary = {}
signal weapon_cooldown_started(weapon_name: String, duration: float)

func _ready() -> void:
	
	#Register all child states
	for child in get_children():
		states[child.name.to_lower()] = child
		child.weapon_state_machine = self
		child.character = get_parent()
		if child.character.has_node("StateMachine"):
			child.state_machine = child.character.get_node("StateMachine")
		if child.has_signal("cooldown_started"):
			child.cooldown_started.connect(_on_weapon_cooldown_started)
		
	
	#Start with initial state
	if initial_state:
		change_state(initial_state.name.to_lower())
	

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
	if get_parent().is_alive:
		if event.is_action_pressed("Weapon 1"):
			change_state("fireball")
		elif event.is_action_pressed("Weapon 2") and "Electric Weapon" in PlayerData.owned_weapons:
			change_state("electro")
		elif event.is_action_pressed("Weapon 3") and "Self Guiding Missile" in PlayerData.owned_weapons:
			change_state("missile")
		elif event.is_action_pressed("Weapon 4") and "Gravity Grenade" in PlayerData.owned_weapons:
			change_state("gravity_grenade")
	
func change_state(new_state_name: String) -> void:
	if current_state:
		current_state.exit()

	current_state = states.get(new_state_name.to_lower())

	if current_state:
		current_state.enter()


func _on_hp_death() -> void:
	change_state("no_weapona")

func _on_weapon_cooldown_started(weapon_name: String, duration: float) -> void:
	weapon_cooldown_started.emit(weapon_name, duration)
