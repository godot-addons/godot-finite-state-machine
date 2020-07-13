extends Resource

signal state_transitioned(p_from_state, p_to_state, p_transition_data_dictionary)
"""
Signal to notify the state transition that just occured and what transition data was passed around.
"""

class_name StateMachine
"""
StateMachine class to manage states -- can be used concurrently.

Usage Notes:
	The object that the StateMachine manages the state of must hold references
	to a StateMachine instance and instances to the State objects at all times.
	This implementation of a StateMachine only uses weak references to
	reference-counted State objects in order to avoid cyclic dependencies that
	could lead to memory leaks.
"""

# The state machine's target object, node, etc
var m_managed_object_weakref : WeakRef = null # using weakref to avoid memory leaks

# Dictionary of states by state id
var m_states : Dictionary = {} # Holds state id strings and weak references to the State objects

# Dictionary of valid state transitions
var m_transitions : Dictionary = {}

# Reference to current state object
var m_current_state_id : String = "" setget set_current_state

# Internal current state object
var m_current_state_weakref : WeakRef = null


func set_managed_object(p_managed_object : Object):
	"""
	Sets the target object, which could be a node or some other object that the states expect
	"""
	m_managed_object_weakref = weakref(p_managed_object)
	for s in m_states:
		m_states[s].get_ref().m_managed_object_weakref = weakref(p_managed_object)


func get_managed_object() -> Object:
	"""
	Returns the target object (node, object, etc)
	"""
	return m_managed_object_weakref.get_ref()


func set_states(p_states : Array) -> void:
	"""
	Expects an array of state definitions to generate the dictionary of states
	"""
	for state_dict in p_states:
		if state_dict.id && state_dict.state:
			set_state(state_dict.id, state_dict.state)


func get_states() -> Dictionary:
	"""
	Returns the dictionary of states
	"""
	return m_states


func set_transitions(p_transitions : Array) -> void:
	"""
	Expects an array of transition definitions to generate the dictionary of transitions
	"""
	for transition_dict in p_transitions:
		if transition_dict.state_id && transition_dict.to_states:
			set_transition(transition_dict.state_id, transition_dict.to_states)


func get_transitions() -> Dictionary:
	"""
	Returns the dictionary of transitions
	"""
	return m_transitions


func set_current_state(p_state_id : String) -> void:
	"""
	This is a 'just do it' method and does not validate transition change
	"""
	if p_state_id in m_states:
		m_current_state_id = p_state_id
		m_current_state_weakref = m_states[p_state_id]
	else:
		print_debug("Cannot set current state, invalid state: ", p_state_id)


func get_current_state_id() -> String:
	"""
	Returns the string id of the current state
	"""
	return m_current_state_id


func set_state_machine(p_states : Array) -> void:
	"""
	Expects an array of states to iterate over and pass self to the state's set_machine_state() method
	"""
	for state in p_states:
		state.set_state_machine(weakref(self))


func set_state(p_state_id : String, p_state : State) -> void:
	"""
	Add a state to the states dictionary
	"""
	if OS.is_debug_build(): # warn when a state gets overwritten
		if p_state_id in m_states:
			push_warning("Overwriting state: " + p_state_id)

	m_states[p_state_id] = weakref(p_state)

	p_state.id = p_state_id
	p_state.m_state_machine_weakref = weakref(self)

	if m_managed_object_weakref:
		p_state.set_managed_object(m_managed_object_weakref)


func set_transition(p_state_id : String, p_to_states : Array) -> void:
	"""
	Set valid transitions for a state. Expects state id and array of to state ids.
	If a state id does not exist in states dictionary, the transition will NOT be added.
	"""
	if p_state_id in m_states:
		if OS.is_debug_build():
			if p_state_id in m_transitions:
				push_warning("Overwriting transition for state: " + p_state_id)
		m_transitions[p_state_id] = {"to_states" : p_to_states}
	else:
		print_debug("Cannot set transition, invalid state: ", p_state_id)


func add_transition(from_state_id: String, p_to_state_id: String) -> void:
	"""
	Add a transition for a state. This adds a single state to transitions whereas
	set_transition is a full replace.
	"""
	if !from_state_id in m_states || !p_to_state_id in m_states:
		print_debug(
			"Cannot add transition, invalid state(s): ",
			"from_state_id=", from_state_id,
			", p_to_state_id=", p_to_state_id
		)
		return

	if from_state_id in m_transitions:
		m_transitions[from_state_id].to_states.append(p_to_state_id)
	else:
		m_transitions[from_state_id] = {"to_states": [p_to_state_id]}


func get_state(p_state_id: String) -> State:
	"""
	Return the state from the states dictionary by state id if it exists
	"""
	if p_state_id in m_states:
		return m_states[p_state_id].get_ref()

	print_debug("Cannot get state, invalid state: ", p_state_id)

	return null


func get_transition(p_state_id: String) -> Dictionary:
	"""
	Return the transition from the transitions dictionary by state id if it exists
	"""
	if p_state_id in m_transitions:
		return m_transitions[p_state_id]

	print_debug("ERROR: Cannot get transition, invalid state: ", p_state_id)

	return {}


func transition(p_state_id : String, p_transition_data_dictionary : Dictionary = {}) -> void:
	"""
	Transition to new state by state id.
	Callbacks will be called on the from and to states if the states have implemented them.
	"""
	if not m_transitions.has(m_current_state_id):
		print_debug("No transitions defined for state %s" % m_current_state_id)
		return
	if !p_state_id in m_states || !p_state_id in m_transitions[m_current_state_id].to_states:
		print_debug("Invalid transition from %s" % m_current_state_id, " to %s" % p_state_id)
		return

	var from_state : State = get_state(m_current_state_id)
	var to_state : State = get_state(p_state_id)

	if from_state.m_exit_state_enabled:
		from_state.__on_exit_state()

	set_current_state(p_state_id)

	if to_state.m_enter_state_enabled:
		to_state.__on_enter_state(p_transition_data_dictionary)

	emit_signal("state_transitioned", from_state.id, to_state.id, p_transition_data_dictionary)


func process(p_delta : float) -> void:
	"""
	Callback to handle _process(). Must be called manually by code
	"""
	if m_current_state_weakref.get_ref().m_process_enabled:
		m_current_state_weakref.get_ref().__process(p_delta)


func physics_process(p_delta : float) -> void:
	"""
	Callback to handle _physics_process(). Must be called manually by code
	"""
	if m_current_state_weakref.get_ref().m_physics_process_enabled:
		m_current_state_weakref.get_ref().__physics_process(p_delta)


func input(p_event : InputEvent) -> void:
	"""
	Callback to handle _input(). Must be called manually by code
	"""
	if m_current_state_weakref.get_ref().m_input_enabled:
		m_current_state_weakref.get_ref().__input(p_event)
