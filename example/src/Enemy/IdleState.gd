extends "ProxyState.gd"

class_name IdleState

func _init().():
	process_enabled = true
	enter_state_enabled = true
	leave_state_enabled = true

func _process(_delta: float) -> void:
	# Start patrolling when the player gets closer to us
	if target.should_patrol():
		state_machine.transition("patrol")

func _on_enter_state() -> void:
	target.say("I feel at peace.")

func _on_leave_state() -> void:
	target.say("I feel uneasy...")
