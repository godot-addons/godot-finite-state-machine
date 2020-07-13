extends Resource

class_name StateMachineFactory

func create(config: Dictionary = {}) -> StateMachine:
	"""
	Factory method accepting an optional configuration object
	"""
	var sm = StateMachine.new()

	if "states" in config:
		sm.set_states(config.states)
	
	var state_dict = sm.get_states()
	for state in state_dict:
		print(state)
		print(state_dict[state])
		print(state_dict[state].get_ref())

	if "target" in config:
		sm.set_managed_object(config.target)

	if "transitions" in config:
		print(config.transitions)
		sm.set_transitions(config.transitions)

	if "current_state" in config:
		sm.set_current_state(config.current_state)

	sm.set_current_state(sm.m_current_state_id)

	return sm
