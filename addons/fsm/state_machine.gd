extends Resource


# Internal State Class -- StateMachine depends on this definition
class State extends Resource:
	# State ID
	var id : String

	# WeakRef to object we want to manage the state of (object, node, etc)
	var m_managed_object_weakref : WeakRef = null # using weakref to avoid memory leaks

	# Reference to state machine
	var m_state_machine_weakref : WeakRef = null # using weakref to avoid memory leaks

	# Internal State Variables trigger processing
	var m_process_enabled : bool = true
	var m_physics_process_enabled : bool = true
	var m_input_enabled : bool = true
	var m_enter_state_enabled : bool = true
	var m_exit_state_enabled : bool = true

	# State machine callback called during transition when entering this state
	func __on_enter_state() -> void:
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


class_name StateMachine


# The state machine's target object, node, etc
#var target = null setget set_managed_object, get_managed_object
var m_managed_object_weakref : WeakRef = null # using weakref to avoid memory leaks


# Dictionary of states by state id
#var states = {} setget set_states, get_states
var m_states : Dictionary = {}


# Dictionary of valid state transitions
#var transitions = {} setget set_transitions, get_transitions
var m_transitions : Dictionary = {}


# Reference to current state object
#var current_state = null setget set_current_state, get_current_state
var m_current_state_id : String = "" setget set_current_state


# Internal current state object
var m_current_state : State = null


func set_managed_object(p_managed_object : Object):
	"""
	Sets the target object, which could be a node or some other object that the states expect
	"""
	m_managed_object_weakref = weakref(p_managed_object)
	for s in m_states:
		m_states[s].m_managed_object_weakref = weakref(p_managed_object)


func get_managed_object() -> Object:
	"""
	Returns the target object (node, object, etc)
	"""
	return m_managed_object_weakref.get_ref()


func set_states(p_states : Array) -> void:
	"""
	Expects an array of state definitions to generate the dictionary of states
	"""
	for s in p_states:
		if s.id && s.state:
			set_state(s.id, s.state.new())


func get_states() -> Dictionary:
	"""
	Returns the dictionary of states
	"""
	return m_states


func set_transitions(p_transitions : Array) -> void:
	"""
	Expects an array of transition definitions to generate the dictionary of transitions
	"""
	for t in p_transitions:
		if t.state_id && t.to_states:
			set_transition(t.state_id, t.to_states)


func get_transitions() -> Dictionary:
	"""
	Returns the dictionary of transitions
	"""
	return m_transitions


func set_current_state(p_state_id : String) -> void:
	"""
	This is a "just do it" method and does not validate transition change
	"""
	if p_state_id in m_states:
		m_current_state_id = p_state_id
		m_current_state = m_states[p_state_id]
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
	m_states[p_state_id] = p_state

	p_state.id = p_state_id
	p_state.m_state_machine_weakref = weakref(self)

	if m_managed_object_weakref:
		p_state.set_managed_object(m_managed_object_weakref)


func set_transition(p_state_id: String, p_to_states: Array) -> void:
	"""
	Set valid transitions for a state. Expects state id and array of to state ids.
	If a state id does not exist in states dictionary, the transition will NOT be added.
	"""
	if p_state_id in m_states:
		m_transitions[p_state_id] = {"to_states": p_to_states}
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
		return m_states[p_state_id]

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


func transition(p_state_id: String) -> void:
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
		to_state.__on_enter_state()


func process(p_delta: float) -> void:
	"""
	Callback to handle _process(). Must be called manually by code
	"""
	if m_current_state.m_process_enabled:
		m_current_state.__process(p_delta)


func physics_process(p_delta: float) -> void:
	"""
	Callback to handle __physics_process(). Must be called manually by code
	"""
	if m_current_state.m_physics_process_enabled:
		m_current_state.__physics_process(p_delta)


func input(p_event: InputEvent) -> void:
	"""
	Callback to handle _input(). Must be called manually by code
	"""
	if m_current_state.m_input_enabled:
		m_current_state.__input(p_event)

