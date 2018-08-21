# State ID
var id

# Target for the state (object, node, etc)
var target

# Reference to state machine
var state_machine

func set_id(new_id):
	id = new_id

func set_state_machine(new_state_machine):
	state_machine = new_state_machine

func set_target(new_target):
	target = new_target

# State machine callback called during transition when entering this state
func _on_enter_state(): pass

# State machine callback called during transition when leaving this state
func _on_leave_state(): pass
