
var id setget set_id, get_id
var target setget set_target, get_target

"""
Set the state id
"""
func set_id(id): self.id = id

"""
Return the state's id
"""
func get_id(): return id

"""
Set the state's target (object, node, etc)
"""
func set_target(target): self.target = target

"""
Return the state's target
"""
func get_target(): return target

"""
Callback methods which can be overriden/implemented by extending state classes
"""
func _process(delta): pass
func _fixed_process(delta): pass
func _input(event): pass

"""
State machine callback. Called during transition when entering this state
"""
func _on_enter_state(): print("Entering state %s" % id)

"""
State machine callback. Called during transition when leaving this state
"""
func _on_leave_state(): print("Leaving state %s" % id)
