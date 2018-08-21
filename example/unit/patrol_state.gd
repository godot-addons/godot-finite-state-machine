extends "state.gd"

var patrolDirection = Vector2(1, 1)

var PATROL_MAX_X = 600
var PATROL_MIN_X = 200

var PATROL_MAX_Y = 400
var PATROL_MIN_Y = 200

func check_for_new_patrol_direction():
	"""
	Checks to see whether the unit has left the bounds in one
	direction or the other.

	If the unit is outside bounds, reverse it's walking direction for that axis
	"""
	var position = target.position

	## We've gone too far left or right
	if position.x > PATROL_MAX_X or position.x < PATROL_MIN_X:
		patrolDirection *= Vector2(-1, 1)

	## We've gone too far up or down
	if position.y > PATROL_MAX_Y or position.y < PATROL_MIN_Y:
		patrolDirection *= Vector2(1, -1)

func _process(delta):
	check_for_new_patrol_direction()

	# Move target along a path
	target.position += patrolDirection

	## We're close to the target, let's attack them
	if target.has_enemies():
		state_machine.transition("attack")

	# We're far from the player, stop patrolling
	elif not target.should_patrol():
		state_machine.transition("idle")
