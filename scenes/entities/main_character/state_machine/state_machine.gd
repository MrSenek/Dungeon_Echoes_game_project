extends Node

class_name StateMachine


@export var initial_state: State
var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	
	#Register all child states
	for child in get_children():
		states[child.name.to_lower()] = child
		child.state_machine = self
		child.character = get_parent()
	
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
		
		
func change_state(new_state_name: String, data: Dictionary = {}) -> void:
	if current_state:
		current_state.exit()
		
	current_state = states.get(new_state_name.to_lower())
	
	if current_state:
		current_state.enter(data)


func _on_fireball_weapon_fired(recoil_strength: Variant) -> void:
	var data = {
		"strength": recoil_strength
	}
	change_state("recoil_state", data)
	
