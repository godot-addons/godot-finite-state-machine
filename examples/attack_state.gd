extends "state.gd"

func _input(event):
	# Command given to move?
	state_machine.transition("patrol")

	# Command given to stop attacking?
	state_machine.transition("idle")

func _on_enter_state():
	target.attack_target()

func _on_leave_state():
	target.stop_shooting()
