extends "ProxyState.gd"

class_name PatrolState

const PATROL_MAX_X: float = 600.0
const PATROL_MIN_X: float = 200.0
const PATROL_MAX_Y: float = 400.0
const PATROL_MIN_Y: float = 200.0

var _patrol_direction = Vector2(1, 1)

func _init().():
	m_physics_process_enabled = false
	m_input_enabled = false
	m_enter_state_enabled = false
	m_exit_state_enabled = false

func __process(_delta: float) -> void:
	check_for_new_patrol_direction()

	# Move target along a path
	m_managed_object_weakref.get_ref().position += _patrol_direction

	# We're close to the target, let's attack them
	if m_managed_object_weakref.get_ref().has_enemies():
		m_state_machine_weakref.get_ref().transition("attack")

	# We're far from the player, stop patrolling
	elif not m_managed_object_weakref.get_ref().should_patrol():
		m_state_machine_weakref.get_ref().transition("idle")

func check_for_new_patrol_direction() -> void:
	"""
	Checks to see whether the unit has left the bounds in one
	direction or the other.

	If the unit is outside bounds, reverse it's walking direction for that axis
	"""
	var position = m_managed_object_weakref.get_ref().position

	# We've gone too far left or right
	if position.x > PATROL_MAX_X or position.x < PATROL_MIN_X:
		_patrol_direction *= Vector2(-1, 1)

	# We've gone too far up or down
	if position.y > PATROL_MAX_Y or position.y < PATROL_MIN_Y:
		_patrol_direction *= Vector2(1, -1)
