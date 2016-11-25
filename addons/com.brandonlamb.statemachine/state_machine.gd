
var target setget set_target, get_target
var initial_state setget set_initial_state, get_initial_state
var states = {} setget set_states, get_states
var transitions = {} setget set_transitions, get_transitions
var current_state = null setget set_current_state, get_current_state

# Internal current state object
var _current_state = DefaultState.new()

"""
Sets the target object, which could be a node or some other object that the states expect
"""
func set_target(target):
	self.target = target
	for s in states: s.set_target(target)

"""
Returns the target object (node, object, etc)
"""
func get_target(): return target

"""
Sets the id of the initial state. Must be a valid, defined state.
"""
func set_initial_state(state_id): if state_id in states: initial_state = state_id

"""
Returns the id of the initial state
"""
func get_initial_state(): return initial_state

"""
Expects an array of state definitions to generate the dictionary of states
"""
func set_states(states):
	for s in states:
		if s.id && s.state: set_state(s.id, s.state.new())

"""
Returns the dictionary of states
"""
func get_states(): return states

"""
Expects an array of transition definitions to generate the dictionary of transitions
"""
func set_transitions(transitions):
	for t in transitions: if t.state_id && t.to_states: set_transition(t.state_id, t.to_states)

"""
Returns the dictionary of transitions
"""
func get_transitions(): return transitions

"""
This is a "just do it" method and does not validate transition change
"""
func set_current_state(state_id):
	if state_id in states:
		current_state = state_id
		_current_state = states[state_id]

"""
Returns the string id of the current state
"""
func get_current_state(): return current_state

"""
Expects an array of states to iterate over and pass self to the state's set_machine_state() method
"""
func set_state_machine(states): for state in states: state.set_state_machine(self)

"""
Add a state to the states dictionary
"""
func set_state(state_id, state):
	states[state_id] = state

	state.set_id(id)
	state.set_state_machine(self)

	if target: state.set_target(target)

"""
Add a transition for a state. Expects state id and array of to state ids.
If a state id does not exist in states dictionary, the transition will NOT be added.
"""
func set_transition(state_id, to_states): if state_id in states: transitions[state_id] = {"to_states": to_states}

"""
Return the state from the states dictionary by state id if it exists
"""
func get_state(state_id): if state_id in states: return states[state_id]

"""
Return the transition from the transitions dictionary by state id if it exists
"""
func get_transition(state_id): if state_id in transitions: return transitions[state_id]

"""
Transition to new state by state id.
Callbacks will be called on the from and to states if the states have implemented them.
"""
func transition(state_id):
	if !state_id in states || !state_id in transitions[current_state].to_states:
		print("Invalid transition from %s" % current_state, " to %s" % state_id)
		return

	var from_state = get_state(current_state)
	var to_state = get_state(state_id)

	if from_state.has_method("_on_leave_state"): from_state._on_leave_state()
	if to_state.has_method("_on_enter_state"): to_state._on_enter_state()

	set_current_state(state_id)

"""
Callback to handle _process(). Must be called manually by code
"""
func _process(delta): if _current_state.has_method("_process"): _current_state._process(delta)

"""
Callback to handle _fixed_process(). Must be called manually by code
"""
func _fixed_process(delta): if _current_state.has_method("_fixed_process"): _current_state._fixed_process(delta)

"""
Callback to handle _input(). Must be called manually by code
"""
func _input(delta): if _current_state.has_method("_input"): _current_state._input(event)

"""
Default state class to implement null object pattern for the state machine's current state
"""
class DefaultState:
	func _process(delta): print("Unimplemented _process(delta)")
	func _fixed_process(delta): print("Unimplemented _fixed_process(delta)")
	func _input(event): print("Unimplemented _input(event)")
