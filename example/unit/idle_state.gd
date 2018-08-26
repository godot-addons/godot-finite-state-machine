extends "state.gd"

func _process(event):
	# Start patrolling when the player gets closer to us
	if target.should_patrol():
		state_machine.transition("patrol")

func _on_enter_state():
	target.say("I feel at peace.")

func _on_leave_state():
	target.say("I feel uneasy...")
