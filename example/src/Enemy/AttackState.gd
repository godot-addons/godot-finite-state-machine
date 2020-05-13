extends "ProxyState.gd"

class_name AttackState

func _init().():
	process_enabled = true
	enter_state_enabled = true
	leave_state_enabled = true

func _process(_delta: float) -> void:
	if not target.has_enemies():
		state_machine.transition("patrol")
		return

	target.attack_enemies()

func _on_enter_state() -> void:
	target.say("Detected player")

func _on_leave_state() -> void:
	target.say("Lost track of player")
