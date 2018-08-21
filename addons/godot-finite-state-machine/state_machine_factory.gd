
const StateMachine = preload("state_machine.gd")

func create(config = {}):
	"""
	Factory method accepting an optional configuration object
	"""
	var sm = StateMachine.new()

	if "states" in config: sm.set_states(config.states)
	if "target" in config: sm.set_target(config.target)
	if "transitions" in config: sm.set_transitions(config.transitions)
	if "current_state" in config: sm.set_current_state(config.current_state)

	sm.set_current_state(sm.current_state)

	return sm
