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
