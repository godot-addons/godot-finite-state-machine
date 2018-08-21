extends Node2D

const StateMachineFactory = preload("../../addons/godot-finite-state-machine/state_machine_factory.gd")
const IdleState = preload("idle_state.gd")
const PatrolState = preload("patrol_state.gd")
const AttackState = preload("attack_state.gd")

onready var smf = StateMachineFactory.new()
onready var Player = get_node('/root/World/Player')
onready var PatrolCircle = get_node('PatrolCircle')
onready var AttackCircle = get_node('AttackCircle')

var LAST_SHOT_TIME = 0
const ENEMY_ATTACK_DISTANCE = 200
const ENEMY_PATROL_DISTANCE = 400

var brain

##
## This is required so that our FSM can handle updates
func _input(event): brain._input(event)
func _process(delta): brain._process(delta)

func _ready():
	brain = smf.create({
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

	set_process(true)
	set_process_input(true)

	##
	## Here we setup the ranges around the unit for visual aids
	PatrolCircle.points = 64
	PatrolCircle.color = Color(0, 1, 1)
	PatrolCircle.diameter = ENEMY_PATROL_DISTANCE

	AttackCircle.points = 64
	AttackCircle.color = Color(1, 0, 0)
	AttackCircle.diameter = ENEMY_ATTACK_DISTANCE

func distance_from_player():
	"""
	Returns the distance to the players position
	"""
	return self.position.distance_to(Player.position)

func should_patrol():
	"""
	Returns true if we should be patrolling (the player is close)
	"""
	return distance_from_player() < ENEMY_PATROL_DISTANCE

func has_enemies():
	"""
	If we're close to the player, set them as our primary enemy
	"""
	return distance_from_player() < ENEMY_ATTACK_DISTANCE

func can_shoot():
	"""
	We should not be able to always fire at the player
	This function only returns true when some time has passed since the last shot
	"""
	var currentTime = OS.get_system_time_secs()
	return currentTime - LAST_SHOT_TIME > 0

func attack_enemies():
	"""
	Fire at the player if we're reloaded and update the time we shot last
	"""
	if not can_shoot():
		return

	LAST_SHOT_TIME = OS.get_system_time_secs()
	print("Shooting at player")

func say(message):
	print('Target says: ', message)
