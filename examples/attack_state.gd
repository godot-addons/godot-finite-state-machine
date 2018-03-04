extends "state.gd"

func _input(event):
	# Command given to move?
	if Input.is_action_just_pressed("Shoot"):
		state_machine.transition("patrol")

	# Command given to stop attacking?
	#state_machine.transition("idle")

func _on_enter_state():
	print("enter attack")
	#target.attack_target()

func _on_leave_state():
	print("leave attack")
	#target.stop_shooting()
