extends Resource

signal state_pushed(p_pushed_state)
signal state_transitioned(p_from_state, p_to_state, p_transition_data)
signal state_popped(p_pushed_state)

class_name StateMachine
"""
StateMachine class to manage states -- can be used concurrently.
"""

# The state machine's target object, node, etc
var m_managed_object_weakref : WeakRef = null # using weakref to avoid memory leaks

# Dictionary of states by state id
var m_transitionable_states : Dictionary = {} # Holds state id strings and state instances currently in use
var m_stackable_states : Array = [] # Hold the state id of the stackable states
var m_state_classes : Dictionary = {} # Holds a reference to each GDScript state class

# Dictionary of valid state transitions
var m_transitions : Dictionary = {}

# Reference to current state id
var m_current_transitionable_state_id : String = "" setget set_current_transitionable_state_id

# Reference to the current transitionable state object
var m_current_transitionable_state : State setget set_current_transitionable_state

# Stack of weak reference to states instances
var m_states_stack : Array = []

# Dictionary that backs up the processing state of each state on the stack
# during freeze/unfreeze. This is so that some states can freeze the processing
# of other states until they are done
var m_state_stack_process_backup : Dictionary = {}

func set_managed_object(p_managed_object : Object):
	"""
	Sets the target object, which could be a node or some other object that the states expect
	"""
	m_managed_object_weakref = weakref(p_managed_object)
	for state_id in m_transitionable_states:
		m_transitionable_states[state_id].m_managed_object_weakref = weakref(p_managed_object)


func get_managed_object() -> Object:
	"""
	Returns the target object (node, object, etc)
	"""
	return m_managed_object_weakref.get_ref()


func set_transitionable_states(p_states : Array) -> void:
	"""
	Expects an array of transitionable state definitions to generate the dictionary of states
	"""
	for state_dict in p_states:
		if state_dict.id && state_dict.state:
			if state_dict.id in m_state_classes:
				push_warning("State id \"" + state_dict.id + "\" class is getting overwritten")
			m_state_classes[state_dict.id] = state_dict.state
			add_transitionable_state(state_dict.id, state_dict.state.new())

func add_transitionable_state(p_state_id : String, p_state : State) -> void:
	"""
	Add a state to the states dictionary
	"""
	if p_state_id in m_transitionable_states:
		push_error("Overwriting state: " + p_state_id)

	m_transitionable_states[p_state_id] = p_state

	p_state.m_id = p_state_id
	p_state.m_state_machine_weakref = weakref(self)

	if m_managed_object_weakref:
		p_state.set_managed_object(m_managed_object_weakref)


func set_stackable_states(p_states : Array) -> void:
	"""
	Expects an array of stackable state definitions to generate the dictionary of states
	"""
	for state_dict in p_states:
		if state_dict.id && state_dict.state:
			if state_dict.id in m_state_classes:
				push_warning("State id \"" + state_dict.id + "\" class is getting overwritten")
			# We only need to keep track of the stackable state
			m_state_classes[state_dict.id] = state_dict.state
			if !state_dict.id in m_stackable_states:
				m_stackable_states.append(state_dict.id)


func get_transitionable_states() -> Dictionary:
	"""
	Returns the dictionary of transitionable states
	"""
	return m_transitionable_states


func get_stackable_states() -> Array:
	"""
	Returns the array of stackable states
	"""
	return m_stackable_states


func get_state_classes() -> Dictionary:
	"""
	Returns the dictionary of stackable states
	"""
	return m_state_classes


func get_states_stack() -> Array:
	"""
	Returns the states stack
	"""
	return m_states_stack


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


func push(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	"""
	Guarantees state processing order is not modified
	Pushed stackable state will be processed last than the rest
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__push_back", p_state_id, p_transition_data)


func __push_back(p_state_id : String, p_transition_data : Dictionary = {}):
	if p_state_id in m_stackable_states:
		var p_state : State = __create_state(p_state_id)

		if p_state.m_enter_state_enabled:
			p_state.__on_enter_state(p_transition_data)

		m_states_stack.push_back(p_state)
		emit_signal("state_pushed", p_state)
	else:
		push_error("Cannot push invalid stackable state to the back of the stack: " + p_state_id)


func push_front(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	"""
	Pushed state will be processed first than the rest
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__push_front", p_state_id, p_transition_data)


func __push_front(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	if p_state_id in m_stackable_states:
		var p_state : State = __create_state(p_state_id)

		if p_state.m_enter_state_enabled:
			p_state.__on_enter_state(p_transition_data)

		m_states_stack.push_front(p_state)
		emit_signal("state_pushed", p_state)
	else:
		push_error("Cannot push invalid stackable state to the front of the stack: " + p_state_id)


func push_unique(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	"""
	Guarantees state processing order is not modified - state will be processed last
	If a previous state with the same ID exists, it will not be added to the stack
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__push_back_unique", p_state_id, p_transition_data)


func __push_back_unique(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	if p_state_id in m_stackable_states:
		for state in m_states_stack:
			if state.m_id == p_state_id:
				push_warning("State ID \"" + p_state_id + "\" is already being processed on the stack. Skipping...")
				return

		var p_state : State = __create_state(p_state_id)

		if p_state.m_enter_state_enabled:
			p_state.__on_enter_state(p_transition_data)

		m_states_stack.push_back(p_state)
		emit_signal("state_pushed", p_state)
	else:
		push_error("Cannot push invalid state to the back of the stack: " + p_state_id)


func push_front_unique(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	"""
	Pushed state will be processed first
	If a previous state with the same ID exists, it will not be added to the stack.
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__push_front_unique", p_state_id, p_transition_data)


func __push_front_unique(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	if p_state_id in m_transitionable_states:
		for state in m_states_stack:
			if state.m_id == p_state_id:
				push_warning("State ID \"" + p_state_id + "\" is already being processed on the stack. Skipping...")
				return

		var p_state : State = __create_state(p_state_id)

		if p_state.m_enter_state_enabled:
			p_state.__on_enter_state(p_transition_data)

		m_states_stack.push_front(p_state)
		emit_signal("state_pushed", p_state)
	else:
		push_error("Cannot push invalid stackable state to the front of the stack: " + p_state_id)


func pop() -> void:
	"""
	Guarantees state processing order is not modified
	Removes the state that is being processed last
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__pop_back")


func __pop_back() -> void:
	if len(m_states_stack) == 1:
		push_error("Could not pop state from the stack -- there's is only one element: " + m_states_stack[0].m_id)
		return

	var p_state : State = m_states_stack.pop_back()

	if p_state == m_current_transitionable_state:
		m_states_stack.push_back(p_state)
		push_error("Cannot not pop transitionable state from the stack: " + m_current_transitionable_state_id)
		return

	if p_state.m_exit_state_enabled:
		p_state.__on_exit_state()

	emit_signal("state_popped", p_state)


func pop_state(p_state : State):
	"""
	Removes a specific state from the stack if found
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__pop_state", p_state)


func __pop_state(p_state : State):
	if len(m_states_stack) == 1:
		push_error("Could not pop state from the stack -- there's is only one element: " + m_states_stack[0].m_id)
		return

	if p_state == m_current_transitionable_state:
		push_error("Cannot not pop transitionable state from the stack: " + m_current_transitionable_state_id)
		return

	if p_state in m_states_stack:
		m_states_stack.erase(p_state)
		if p_state.m_exit_state_enabled:
			p_state.__on_exit_state()
		emit_signal("state_popped", p_state)
	else:
		push_error("Could not pop state " + str(p_state) + " with id \"" + p_state.m_id +"\"")


func pop_front() -> void:
	"""
	Remove state that is being processed first
	"""
	# The stack could be getting processed when this function fires -- better
	# to call it during idle time.
	call_deferred("__pop_front")


func __pop_front() -> void:
	if len(m_states_stack) == 1:
		push_error("Could not pop state from the stack -- there's is only one element: " + m_states_stack[0].m_id)
		return

	var p_state : State = m_states_stack.pop_front()

	if p_state == m_current_transitionable_state:
		m_states_stack.push_front(p_state)
		push_error("Cannot not pop transitionable state from the stack: " + m_current_transitionable_state_id)
		return

	if p_state.m_exit_state_enabled:
		p_state.__on_exit_state()

	emit_signal("state_popped", p_state)


func get_current_state_id() -> String:
	"""
	Returns the string id of the current state
	"""
	return m_current_transitionable_state_id


func set_state_machine(p_states : Array) -> void:
	"""
	Expects an array of states to iterate over and pass self to the state's set_machine_state() method
	"""
	for state in p_states:
		state.set_state_machine(weakref(self))


func set_transition(p_state_id : String, p_to_states : Array) -> void:
	"""
	Set valid transitions for a state. Expects state id and array of to state ids.
	If a state id does not exist in states dictionary, the transition will NOT be added.
	"""
	if p_state_id in m_transitionable_states:
		if p_state_id in m_transitions:
			push_error("Overwriting transition for state: " + p_state_id)
		m_transitions[p_state_id] = {"to_states" : p_to_states}
	else:
		push_error("Cannot set transition, invalid state: " + p_state_id)


func add_transition(from_state_id : String, p_to_state_id : String) -> void:
	"""
	Add a transition for a state. This adds a single state to transitions whereas
	set_transition is a full replace.
	"""
	if !from_state_id in m_transitionable_states || !p_to_state_id in m_transitionable_states:
		push_error(
			"Cannot add transition, invalid state(s): " +
			"from_state_id=" + from_state_id +
			", p_to_state_id=" +  p_to_state_id
		)
		return

	if from_state_id in m_transitions:
		m_transitions[from_state_id].to_states.append(p_to_state_id)
	else:
		m_transitions[from_state_id] = {"to_states": [p_to_state_id]}


func get_state(p_state_id : String) -> State:
	"""
	Return the state from the states dictionary by state id if it exists
	"""
	if p_state_id in m_transitionable_states:
		return m_transitionable_states[p_state_id]

	push_error("Cannot get state, invalid state: " + p_state_id)
	return null


func get_transition(p_state_id : String) -> Dictionary:
	"""
	Return the transition from the transitions dictionary by state id if it exists
	"""
	if p_state_id in m_transitions:
		return m_transitions[p_state_id]

	push_error("Cannot get transition, invalid state: " + p_state_id)
	return {}


func set_current_transitionable_state(p_state : State) -> void:
	"""
	This is needed to keep a reference to know which state can be transitioned froom/to
	"""
	if p_state in m_transitionable_states.values():
		m_current_transitionable_state = p_state
	else:
		push_error("Cannot set transitionable state with invalid state: " + str(p_state))


func set_current_transitionable_state_id(p_state_id : String) -> void:
	"""
	This is a 'just do it' method and does not validate transition change
	"""
	if p_state_id in m_transitionable_states:
		if len(m_states_stack) == 0: # this is the first state we are settting the StateMachine to
			m_current_transitionable_state_id = p_state_id
			m_current_transitionable_state = m_transitionable_states[p_state_id]
			m_states_stack.append(m_transitionable_states[p_state_id])
		else:
			if m_current_transitionable_state:
				var transitionable_state_index = m_states_stack.find(m_current_transitionable_state)
				if transitionable_state_index != -1:
					var target_transitionable_state : State = m_transitionable_states[p_state_id]
					m_states_stack[transitionable_state_index] = target_transitionable_state
					m_current_transitionable_state_id = target_transitionable_state.m_id
				else:
					push_error("Cannot set transitionable state! Transitionable state not found!: " + str(m_current_transitionable_state))
	else:
		push_error("Cannot set current state, invalid state: " + p_state_id)


func transition(p_state_id : String, p_transition_data : Dictionary = {}) -> void:
	"""
	Transition to new state by state id.
	Callbacks will be called on the from and to states if the states have implemented them.
	"""
	if not m_transitions.has(m_current_transitionable_state_id):
		push_error("No transitions defined for state %s" % m_current_transitionable_state_id)
		return
	if !p_state_id in m_transitionable_states || !p_state_id in m_transitions[m_current_transitionable_state_id].to_states:
		push_error("Invalid transition from %s" % m_current_transitionable_state_id + " to %s" % p_state_id)
		return

	var from_state : State = m_current_transitionable_state
	var to_state : State = get_state(p_state_id)

	if from_state.m_exit_state_enabled:
		from_state.__on_exit_state()

	# Update local references
	set_current_transitionable_state_id(p_state_id)
	set_current_transitionable_state(to_state)

	if to_state.m_enter_state_enabled:
		to_state.__on_enter_state(p_transition_data)

	emit_signal("state_transitioned", from_state.m_id, to_state.m_id, p_transition_data)


func process(p_delta : float) -> void:
	"""
	Callback to handle _process(). Must be called manually by code
	"""
	for state in m_states_stack:
		if state.m_process_enabled:
			state.__process(p_delta)


func physics_process(p_delta : float) -> void:
	"""
	Callback to handle _physics_process(). Must be called manually by code
	"""
	for state in m_states_stack:
		if state.m_physics_process_enabled:
			state.__physics_process(p_delta)


func input(p_event : InputEvent) -> void:
	"""
	Callback to handle _input(). Must be called manually by code
	"""
	for state in m_states_stack:
		if state.m_input_enabled:
			state.__input(p_event)


func freeze_except(p_state : State) -> void:
	"""
	Call to freeze processing on every state except the one specified
	Useful for using on State.__on_enter_state when a single state must be processed
	"""
	if len(m_state_stack_process_backup) > 0:
		push_warning("StateMachine has been frozen previously -- unfreeze data could possibly be lost")

	for state in m_states_stack:
		if state != p_state:
			# Backup State
			m_state_stack_process_backup[state]["is_process_enabled"] = state.is_process_enabled()
			m_state_stack_process_backup[state]["is_physics_process_enabled"] = state.is_physics_process_enabled()
			m_state_stack_process_backup[state]["is_input_enabled"] = state.is_input_enabled()
			m_state_stack_process_backup[state]["is_enter_state_enabled"] = state.is_enter_state_enabled()
			m_state_stack_process_backup[state]["is_exit_state_enabled"] = state.is_exit_state_enabled()

			# Disable processing
			state.set_process_enabled(false)
			state.set_physics_process_enabled(false)
			state.set_input_enabled(false)
			state.set_enter_state_enabled(false)
			state.set_exit_state_enabled(false)


func unfreeze() -> void:
	"""
	Call to unfreeze processing on the remaining states
	Useful for using on State.__on_exit_state when the current state has previously frozen the processing of the remaining states
	"""
	if len(m_state_stack_process_backup) == 0:
		push_error("StateMachine has never been freezed previously! Cannot unfreeze state stack!")
		return

	for state in m_states_stack:
		if state in m_state_stack_process_backup:
			state.set_process_enabled(m_state_stack_process_backup[state]["is_process_enabled"])
			state.set_physics_process_enabled(m_state_stack_process_backup[state]["is_physics_process_enabled"])
			state.set_input_enabled(m_state_stack_process_backup[state]["is_input_enabled"])
			state.set_enter_state_enabled(m_state_stack_process_backup[state]["is_enter_state_enabled"])
			state.set_exit_state_enabled(m_state_stack_process_backup[state]["is_exit_state_enabled"])

	# Clear backup
	m_state_stack_process_backup.clear()


# Private Functions
func __create_state(p_state_id : String) -> State:
	var new_state = m_state_classes[p_state_id].new()
	new_state.m_id = p_state_id
	new_state.m_state_machine_weakref = weakref(self)
	if m_managed_object_weakref:
		new_state.m_managed_object_weakref = m_managed_object_weakref
	return new_state
