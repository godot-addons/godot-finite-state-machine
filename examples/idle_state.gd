extends "state.gd"

func _input(event):
	# Command given to patrol?
	state_machine.transition("patrol")
