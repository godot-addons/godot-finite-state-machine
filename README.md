# godot-finite-state-machine
Godot FSM (Finite State Machine)

This is a second FSM for Godot that is purely code-only (no editor plugin).

# Examples

## Configuration-based Setup

This first example is the "best" way to create an FSM instance, by passing a configuration dictionary to the `StateMachineFactory.create()` method.

Notice the states property is an array of dictionaries, and we pass IdleState and PatrolState. The state machine handles creating new instances of the states via this method.

```gdscript
const IdleState = preload("idle_state.gd")
const PatrolState = preload("patrol_state.gd")

# Create new state machine factory
var smf = StateMachineFactory.new()

# Create state machine using a configuration dictionary
var sm = smf.create({
  "target": get_tree().get_root().get_node("enemy"),
  "current_state": "patrol",
  "states": [
    {"id": "idle", "state": IdleState},
    {"id": "patrol", "state": PatrolState}
  ],
  "transitions": [
    {"state_id": "idle", "to_states": ["patrol"]},
    {"state_id": "patrol", "to_states": ["idle"]}
  ]
})
```

## Manual Setup

This method shows how to manually create and setup a FSM object.

```gdscript
const IdleState = preload("idle_state.gd")
const PatrolState = preload("patrol_state.gd")

# Create state manually
var sm = smf.create()

# Create states
var idle_state = IdleState.new()
var patrol_state = PatrolState.new()

# Add the state machine to the states (also handled by the state machine)
idle_state.set_state_machine(sm)
patrol_state.set_state_machine(sm)

# Convenience method to set state machine on array of states
sm.set_state_machine([idle_state, patrol_state])

# Add state to state machine, which also adds the state machine to the state
sm.add_state("idle", idle_state)
sm.add_state("patrol", patrol_state)

# Set states method which accepts the same array of state dictionaries as the create factory method
sm.set_states([
  {"id": "idle", "state": IdleState},
  {"id": "patrol", "state": PatrolState}
])

# Add transitions. Must be done after adding states, as the state ids are validated
sm.add_transition("idle", ["patrol"])
sm.add_transition("patrol", ["idle"])

# Set transitions method which accepts the same array of transition dictionaries as the create factory method
sm.set_transitions([
  {"state_id": "idle", "to_states": ["patrol"]},
  {"state_id": "patrol", "to_states": ["idle"]}
])

# Add a single transition
sm.add_transition("idle", "patrol")
sm.add_transition("patrol", "idle")

# Add the target node/object to the state machine
sm.set_target(get_tree().get_root().get_node("enemy"))

# Set the initial state of the state machine
sm.set_current_state("patrol")
```

## State Machine

### State Machine Target

```gdscript
# Set the state machine's target (recursively sets on states)
sm.set_target(get_node("player"))

# Get state machine's target object
var player = sm.get_target()
```

### State Machine Current State

```gdscript
# Set the state machine's current state. This really should be called internally by the state machine only.
sm.set_current_state("patrol")

# Get the state machine's current state
var state = sm.get_state(sm.get_current_state())
```

### State Machine Transition

The transition method of the state machine will validate that the id passed is a valid state. It will call the current state's `_on_leave_state` callback if implemented. It will then call the to state's `_on_enter_state` method.

```gdscript
# Transition to new state
sm.transition("patrol")
```

### State Machine Callbacks

The state manager exposes callback methods for `_process(delta)`, `_fixed_process(delta)`, and `_input(event)`. Calls to these methods are proxied down to the current state's method if it has implemented them.

```gdscript
# State machine callbacks which are proxied down to the current state object
sm._fixed_process(delta)
sm._process(delta)
sm._input(event)
```

## State

### State ID

Each state stores its own ID.

```gdscript
var smf = StateMachineFactory.new()
var sm = smf.create()

var state = IdleState.new()
state.set_state_machine(sm)
state.set_id("idle")

var state_id = state.get_id()
```

### State Target

The state and state machine have a target object, which is assumed to be where any extra required context is coded against.

```gdscript
var smf = StateMachineFactory.new()
var sm = smf.create()

var state = IdleState.new()
state.set_state_machine(sm)
state.set_id("idle")
state.set_target(get_node("player"))

var player = state.get_target()
```

### State Callbacks

A state class can implement callbacks for `_process(delta)`, `_fixed_process(delta)`, `_input(event)`, `_on_enter_state()`, and `_on_leave_state()`.

```gdscript
extends "state.gd"

var memory = 0

func _fixed_process(delta):
	scan_for_enemy(delta)
	move_to_random(delta)

func scan_for_enemy(delta): pass

func move_to_random(delta):
	# some logic to move to a random location
	...

	# Transition to idle state if we have reached our destination
	if arrived_at_location(): state_machine.transition("idle")

func _on_enter_state(): memory = 100
```
