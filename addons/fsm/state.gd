extends Resource

# Internal State Class -- StateMachine depends on this definition
class_name State
"""
State objects used in a StateMachine.

Usage Notes:
	See StateMachine docstring.
"""

# State ID
var m_id : String

# WeakRef to object we want to manage the state of (object, node, etc)
var m_managed_object_weakref : WeakRef = null # using weakref to avoid memory leaks

# WeakRef to state machine
var m_state_machine_weakref : WeakRef = null # using weakref to avoid memory leaks

# Internal State Variables trigger processing
var m_process_enabled : bool = true
var m_physics_process_enabled : bool = true
var m_input_enabled : bool = true
var m_enter_state_enabled : bool = true
var m_exit_state_enabled : bool = true


# State machine callback called during transition when entering this state
func __on_enter_state(p_transition_data_dictionary : Dictionary = {}) -> void:
	push_warning("Unimplemented __on_enter_state")


# State machine callback called during transition when leaving this state
func __on_exit_state() -> void:
	push_warning("Unimplemented __on_exit_state")


func __process(delta: float) -> void:
	push_warning("Unimplemented __process(delta)")


func __physics_process(delta: float) -> void:
	push_warning("Unimplemented __physics_process(delta)")


func __input(event: InputEvent) -> void:
	push_warning("Unimplemented __input(event)")

