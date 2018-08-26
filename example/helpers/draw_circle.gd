extends Node2D

var points = 32
var diameter = 80
var color = Color(1.0, 0.0, 0.0)

func _draw():
	"""
	Draws an arc from center -> radius
	"""
	var points_arc = PoolVector2Array()

	## just add a bunch of points in a circle around our current position
	for i in range(points+1):
		var angle_point = deg2rad(i * 360 / points - 90)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * diameter)

	## Draw a line from each point to the next
	for index_point in range(points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)
