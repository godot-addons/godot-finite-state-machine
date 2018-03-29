# The state machine's target object, node, etc
var target = null setget set_target, get_target

# Dictionary of states by state id
var states = {} setget set_states, get_states

# Dictionary of valid state transitions
var transitions = {} setget set_transitions, get_transitions

# Reference to current state object
var current_state = null setget set_current_state, get_current_state

# Internal current state object
var _current_state = DefaultState.new()

func set_target(new_target):
	"""
	Sets the target object, which could be a node or some other object that the states expect
	"""
	target = new_target
	for s in states: states[s].set_target(target)

func get_target():
	"""
	Returns the target object (node, object, etc)
	"""
	return target

func set_states(states):
	"""
	Expects an array of state definitions to generate the dictionary of states
	"""
	for s in states:
		if s.id && s.state: set_state(s.id, s.state.new())

func get_states():
	"""
	Returns the dictionary of states
	"""
	return states

func set_transitions(transitions):
	"""
	Expects an array of transition definitions to generate the dictionary of transitions
	"""
	for t in transitions:
		if t.state_id && t.to_states: set_transition(t.state_id, t.to_states)

func get_transitions():
	"""
	Returns the dictionary of transitions
	"""
	return transitions

func set_current_state(state_id):
	"""
	This is a "just do it" method and does not validate transition change
	"""
	if state_id in states:
		current_state = state_id
		_current_state = states[state_id]
	else:
		print("Cannot set current state, invalid state: ", state_id)

func get_current_state():
	"""
	Returns the string id of the current state
	"""
	return current_state

func set_state_machine(states):
	"""
	Expects an array of states to iterate over and pass self to the state's set_machine_state() method
	"""
	for state in states: state.set_state_machine(self)

func set_state(state_id, state):
	"""
	Add a state to the states dictionary
	"""
	states[state_id] = state

	state.set_id(state_id)
	state.set_state_machine(self)

	if target: state.set_target(target)

func set_transition(state_id, to_states):
	"""
	Set valid transitions for a state. Expects state id and array of to state ids.
	If a state id does not exist in states dictionary, the transition will NOT be added.
	"""
	if state_id in states:
		transitions[state_id] = {"to_states": to_states}
	else:
		print("Cannot set transition, invalid state: ", state_id)

func add_transition(from_state_id, to_state_id):
	"""
	Add a transition for a state. This adds a single state to transitions whereas
	set_transition is a full replace.
	"""
	if !from_state_id in states || !to_state_id in states:
		print(
			"Cannot add transition, invalid state(s): ",
			"from_state_id=", from_state_id,
			", to_state_id=", to_state_id
		)
		return

	if from_state_id in transitions:
		transitions[from_state_id].to_states.append(to_state_id)
	else:
		transitions[from_state_id] = {"to_states": [to_state_id]}

func get_state(state_id):
	"""
	Return the state from the states dictionary by state id if it exists
	"""
	if state_id in states:
		return states[state_id]
	else:
		print("Cannot get state, invalid state: ", state_id)

func get_transition(state_id):
	"""
	Return the transition from the transitions dictionary by state id if it exists
	"""
	if state_id in transitions:
		return transitions[state_id]
	else:
		print("Cannot get transition, invalid state: ", state_id)

func transition(state_id):
	"""
	Transition to new state by state id.
	Callbacks will be called on the from and to states if the states have implemented them.
	"""
	if !state_id in states || !state_id in transitions[current_state].to_states:
		print("Invalid transition from %s" % current_state, " to %s" % state_id)
		return

	var from_state = get_state(current_state)
	var to_state = get_state(state_id)

	if from_state.has_method("_on_leave_state"): from_state._on_leave_state()
	if to_state.has_method("_on_enter_state"): to_state._on_enter_state()

	set_current_state(state_id)

func _process(delta):
	"""
	Callback to handle _process(). Must be called manually by code
	"""
	if _current_state.has_method("_process"): _current_state._process(delta)

func _physics_process(delta):
	"""
	Callback to handle _physics_process(). Must be called manually by code
	"""
	if _current_state.has_method("_physics_process"): _current_state._physics_process(delta)

func _input(event):
	"""
	Callback to handle _input(). Must be called manually by code
	"""
	if _current_state.has_method("_input"): _current_state._input(event)

class State:
	# State ID
	var id

	# Target for the state (object, node, etc)
	var target

	# Reference to state machine
	var state_machine

	# State machine callback called during transition when entering this state
	func _on_enter_state(): pass

	# State machine callback called during transition when leaving this state
	func _on_leave_state(): pass

class DefaultState extends State:
	"""
	Default state class to implement null object pattern for the state machine's current state
	"""
	func _process(delta): print("Unimplemented _process(delta)")
	func _physics_process(delta): print("Unimplemented _physics_process(delta)")
	func _input(event): print("Unimplemented _input(event)")
