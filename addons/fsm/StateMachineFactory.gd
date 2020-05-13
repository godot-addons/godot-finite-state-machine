extends Resource

class_name StateMachineFactory

const StateMachine = preload("StateMachine.gd")

func create(config: Dictionary = {}) -> StateMachine:
	"""
	Factory method accepting an optional configuration object
	"""
	var sm = StateMachine.new()

	if "states" in config:
		sm.set_states(config.states)

	if "target" in config:
		sm.set_target(config.target)

	if "transitions" in config:
		sm.set_transitions(config.transitions)

	if "current_state" in config:
		sm.set_current_state(config.current_state)

	sm.set_current_state(sm.current_state)

	return sm
