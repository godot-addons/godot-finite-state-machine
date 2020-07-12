extends "ProxyState.gd"

class_name IdleState

func _init().():
	m_physics_process_enabled = false
	m_input_enabled = false

func __process(_delta: float) -> void:
	# Start patrolling when the player gets closer to us
	if m_target.should_patrol():
		m_state_machine.transition("patrol")

func __on_enter_state() -> void:
	m_target.say("I feel at peace.")

func __on_exit_state() -> void:
	m_target.say("I feel uneasy...")
