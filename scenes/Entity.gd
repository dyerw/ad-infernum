extends Node2D

var gridX
var gridY
var display_name
var id

var current_movement_points
var max_movement_points = 5

func init(x, y, _display_name):
	gridX = x
	gridY = y
	display_name = _display_name


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

func end_turn():
	current_movement_points = max_movement_points

func _ready():
	current_movement_points = max_movement_points
	_move(gridX, gridY)
