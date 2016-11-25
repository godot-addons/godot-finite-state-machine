
const StateMachine = preload("state_machine.gd")

"""
Factory method accepting an optional configuration object
"""
func create(config = {}):
	var sm = StateMachine.new()

	if config.contains("states"): sm.set_states(config.states)
	if config.contains("transitions"): sm.set_transitions(config.transitions)
	if config.contains("target"): sm.set_target(config.target)
	if config.contains("initial_state"): sm.set_initial_state(config.initial_state)

	sm.set_current_state(sm.initial_state)

	return sm
