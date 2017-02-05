extends "state.gd"

func _process(delta):
	# Move target along a path
	target.move(target.pos.x + 1, target.pos.y + 1)
	taget.find_enemies()

	if target.has_enemies():
		state_machine.transition("attack")

func _input(event):
	# Command given to stop patrolling?
	state_machine.transition("idle")

func _on_enter_state():
	# Equip weapon
	target.set_mode("war")

func _on_leave_state():
	# Unequip weapon
	target.set_mode("peace")
