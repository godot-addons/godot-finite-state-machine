extends State

class_name AttackState

func _init().():
	m_physics_process_enabled = false
	m_input_enabled = false

func __process(_delta: float) -> void:
	if not m_managed_object_weakref.get_ref().has_enemies():
		m_state_machine_weakref.get_ref().transition("patrol")
		return

	m_managed_object_weakref.get_ref().attack_enemies()

func __on_enter_state(_p_transition_dictionary : Dictionary = {}) -> void:
	m_managed_object_weakref.get_ref().say("Detected player")

func __on_exit_state() -> void:
	m_managed_object_weakref.get_ref().say("Lost track of player")
