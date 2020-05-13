extends Node2D

class_name Enemy

const StateMachineFactory = preload("res://addons/fsm/StateMachineFactory.gd")
const IdleState = preload("IdleState.gd")
const PatrolState = preload("PatrolState.gd")
const AttackState = preload("AttackState.gd")

const ENEMY_ATTACK_DISTANCE: float = 200.0
const ENEMY_PATROL_DISTANCE: float = 400.0

var last_shot_time: int = 0
var state_machine: StateMachine

onready var smf = StateMachineFactory.new()
onready var player = $"/root/World/Player"
onready var patrol_circle = $PatrolCircle
onready var attack_circle = $AttackCircle

func _ready() -> void:
	state_machine = smf.create({
		"target": self,
		"current_state": "idle",
		"states": [
			{"id": "idle", "state": IdleState},
			{"id": "patrol", "state": PatrolState},
			{"id": "attack", "state": AttackState}
		],
		"transitions": [
			{"state_id": "idle", "to_states": ["patrol", "attack"]},
			{"state_id": "patrol", "to_states": ["idle", "attack"]},
			{"state_id": "attack", "to_states": ["idle", "patrol"]}
		]
	})

	# Here we setup the ranges around the unit for visual aids
	patrol_circle.points = 64
	patrol_circle.color = Color(0, 1, 1)
	patrol_circle.diameter = ENEMY_PATROL_DISTANCE

	attack_circle.points = 64
	attack_circle.color = Color(1, 0, 0)
	attack_circle.diameter = ENEMY_ATTACK_DISTANCE

# This is required so that our FSM can handle updates
func _input(event: InputEvent) -> void:
	state_machine._input(event)

func _process(delta: float) -> void:
	state_machine._process(delta)

func distance_from_player() -> float:
	"""
	Returns the distance to the players position
	"""
	return position.distance_to(player.position)

func should_patrol() -> bool:
	"""
	Returns true if we should be patrolling (the player is close)
	"""
	return distance_from_player() < ENEMY_PATROL_DISTANCE

func has_enemies() -> bool:
	"""
	If we're close to the player, set them as our primary enemy
	"""
	return distance_from_player() < ENEMY_ATTACK_DISTANCE

func can_shoot() -> bool:
	"""
	We should not be able to always fire at the player
	This function only returns true when some time has passed since the last shot
	"""
	return OS.get_system_time_secs() - last_shot_time > 0

func attack_enemies() -> void:
	"""
	Fire at the player if we're reloaded and update the time we shot last
	"""
	if not can_shoot():
		return

	last_shot_time = OS.get_system_time_secs()
	print("Shooting at player")

func say(message: String) -> void:
	print("Target says: ", message)
