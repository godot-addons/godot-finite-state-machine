extends "state.gd"

func _process(delta):
	# Move target along a path
	#target.translate(Vector2(target.position.x + 1, target.position.y + 1))
	#target.find_enemies()

#	if target.has_enemies():
#		state_machine.transition("attack")
	pass

func _input(event):
	# Command given to stop patrolling?
	state_machine.transition("idle")

func _on_enter_state():
	# Equip weapon
	#target.set_mode("war")
	pass

func _on_leave_state():
	# Unequip weapon
	#target.set_mode("peace")
	pass
