extends Node2D

const StateMachineFactory = preload("state_machine_factory.gd")
const IdleState = preload("idle_state.gd")
const PatrolState = preload("patrol_state.gd")
const AttackState = preload("attack_state.gd")

onready var smf = StateMachineFactory.new()

var brain

func _ready():
	brain = smf.create({
		"target": self,
		"current_state": "patrol",
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
	}))

	set_process(true)
	set_process_input(true)

func _process(delta): brain._process(delta)
func _input(event): brian._input(event)
