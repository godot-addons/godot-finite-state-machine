extends "state.gd"

func _process(event):
	if not target.has_enemies():
		return state_machine.transition("patrol")

	target.attack_enemies()

func _on_enter_state():
	target.say('OH, an enemy!')

func _on_leave_state():
	target.say('Where did he go?')
