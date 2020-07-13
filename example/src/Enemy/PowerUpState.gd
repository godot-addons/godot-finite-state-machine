extends State

class_name PowerUpState

const powerup_seconds : float = 2.0
var time_passed : float = 0
var original_scale : Vector2

func _init().():
	m_physics_process_enabled = false
	m_input_enabled = false

func __process(delta: float) -> void:
	time_passed += delta
	if time_passed > powerup_seconds:
		m_state_machine_weakref.get_ref().pop_state(self)

func __on_enter_state(_p_transition_dictionary : Dictionary = {}) -> void:
	m_managed_object_weakref.get_ref().say("I shall Power Up!")
	original_scale = m_managed_object_weakref.get_ref().get_node("Sprite").scale
	m_managed_object_weakref.get_ref().get_node("Sprite").scale = Vector2(2,2)

func __on_exit_state() -> void:
	m_managed_object_weakref.get_ref().say("My power is fading...")
	m_managed_object_weakref.get_ref().get_node("Sprite").scale = original_scale
