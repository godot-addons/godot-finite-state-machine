extends Resource

class_name StateMachineFactory

func create(p_config: Dictionary = {}) -> StateMachine:
	"""
	Factory method accepting an optional configuration object
	"""

	var sm = StateMachine.new()

	var key : String = "transitionable_states"
	if key in p_config:
		sm.set_transitionable_states(p_config[key])

	key = "stackable_states"
	if key in p_config:
		sm.set_stackable_states(p_config[key])

	key = "managed_object"
	if key in p_config:
		sm.set_managed_object(p_config[key])

	key = "transitions"
	if key in p_config:
		sm.set_transitions(p_config[key])

	key = "current_state_id"
	if key in p_config:
		sm.set_current_transitionable_state_id(p_config[key])

	return sm
