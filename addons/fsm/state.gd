extends Resource

# Internal State Class -- StateMachine depends on this definition
class_name State
"""
State objects used in a StateMachine.
"""

# State ID
var m_id : String setget set_id, get_id

# WeakRef to object we want to manage the state of (object, node, etc)
var m_managed_object_weakref : WeakRef = null setget set_managed_object, get_managed_object# using weakref to avoid memory leaks

# WeakRef to state machine
var m_state_machine_weakref : WeakRef = null setget set_state_machine, get_state_machine # using weakref to avoid memory leaks

# Internal State Variables trigger processing
var m_process_enabled : bool = true setget set_process_enabled, is_process_enabled
var m_physics_process_enabled : bool = true setget set_physics_process_enabled, is_physics_process_enabled
var m_input_enabled : bool = true setget set_input_enabled, is_input_enabled
var m_enter_state_enabled : bool = true setget set_enter_state_enabled, is_enter_state_enabled
var m_exit_state_enabled : bool = true setget set_exit_state_enabled, is_exit_state_enabled

func set_id(p_id : String) -> void:
	m_id = p_id


func get_id() -> String:
	return m_id


func set_managed_object(p_managed_object : WeakRef) -> void:
	m_managed_object_weakref = p_managed_object


func get_managed_object() -> WeakRef:
	return m_managed_object_weakref


func set_state_machine(p_state_machine : WeakRef) -> void:
	m_state_machine_weakref = p_state_machine


func get_state_machine() -> WeakRef:
	return m_state_machine_weakref


func set_process_enabled(p_value : bool) -> void:
	m_process_enabled = p_value


func is_process_enabled() -> bool:
	return m_process_enabled


func set_physics_process_enabled(p_value : bool) -> void:
	m_physics_process_enabled = p_value


func is_physics_process_enabled() -> bool:
	return m_physics_process_enabled


func set_input_enabled(p_value : bool) -> void:
	m_input_enabled = p_value


func is_input_enabled() -> bool:
	return m_input_enabled


func set_enter_state_enabled(p_value : bool) -> void:
	m_enter_state_enabled = p_value


func is_enter_state_enabled() -> bool:
	return m_enter_state_enabled


func set_exit_state_enabled(p_value : bool) -> void:
	m_exit_state_enabled = p_value


func is_exit_state_enabled() -> bool:
	return m_exit_state_enabled

# State machine callback called during transition when entering this state
func __on_enter_state(p_transition_data : Dictionary = {}) -> void:
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

