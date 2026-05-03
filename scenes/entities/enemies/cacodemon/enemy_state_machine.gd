extends Node

class_name EnemyStateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary

func _ready() -> void:
	
	#Register all child states
	for child in get_children():
		states[child.name.to_lower()] = child
		child.enemy_state_machine = self
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
		
	
func change_state(new_state_name: String) -> void:
	if current_state:
		current_state.exit()
		
	current_state = states.get(new_state_name.to_lower())
	
	if current_state:
		current_state.enter()


func _on_hp_death() -> void:
	change_state("death_state")
