extends Resource

class_name StateMachineFactory

func create(p_config: Dictionary = {}) -> StateMachine:
	"""
	Factory method accepting an optional configuration object
	"""
	var sm = StateMachine.new()

	if "states" in p_config:
		sm.set_states(p_config.states)

	if "target" in p_config:
		sm.set_managed_object(p_config.target)

	if "transitions" in p_config:
		sm.set_transitions(p_config.transitions)

	if "current_state_id" in p_config:
		sm.set_current_transitionable_state_id(p_config.current_state_id)

	return sm
