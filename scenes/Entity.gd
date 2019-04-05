extends Node2D

var gridX
var gridY
var id

var current_movement_points
var max_movement_points

func init(x, y, max_move):
	gridX = x
	gridY = y
	current_movement_points = max_move
	max_movement_points = max_move

func move_along_path(path: PoolVector2Array):
	if current_movement_points == 0:
		return
	
	var new_pos
	if current_movement_points < path.size():
		new_pos = path[current_movement_points - 1]
		current_movement_points = 0
	else:
		new_pos = path[path.size() - 1]
		current_movement_points -= path.size()
	_move(new_pos.x, new_pos.y)

func _move(x: int, y: int):
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16

func on_click():
	get_parent().child_clicked(self)

func _ready():
	_move(gridX, gridY)
