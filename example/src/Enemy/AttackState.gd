extends "ProxyState.gd"

class_name AttackState

func _init().():
	m_physics_process_enabled = false
	m_input_enabled = false

func __process(_delta: float) -> void:
	if not m_target.has_enemies():
		m_state_machine.transition("patrol")
		return

	m_target.attack_enemies()

func __on_enter_state() -> void:
	m_target.say("Detected player")

func __on_exit_state() -> void:
	m_target.say("Lost track of player")
