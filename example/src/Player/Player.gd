extends Area2D

class_name Player

const SPEED = 200

onready var _screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var velocity = Vector2()

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1

	if Input.is_action_pressed("ui_down"):
		velocity.y += 1

	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED

	position += velocity * delta
	position.x = clamp(position.x, 0, _screen_size.x)
	position.y = clamp(position.y, 0, _screen_size.y)
