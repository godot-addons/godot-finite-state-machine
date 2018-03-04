
const StateMachine = preload("state_machine.gd")

func create(config = {}):
	"""
	Factory method accepting an optional configuration object
	"""
	var sm = StateMachine.new()

	if config.has("states"): sm.set_states(config.states)
	if config.has("transitions"): sm.set_transitions(config.transitions)
	if config.has("target"): sm.set_target(config.target)
	if config.has("current_state"): sm.set_current_state(config.current_state)

	sm.set_current_state(sm.current_state)

	return sm
