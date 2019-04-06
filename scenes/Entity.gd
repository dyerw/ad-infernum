extends Node2D

var gridX
var gridY
var display_name
var id

var current_movement_points
var current_health

# Stats
var max_movement_points = 5
var max_health = 10
var dexterity = 5

func init(x, y, _display_name):
	gridX = x
	gridY = y
	display_name = _display_name


func move_along_path(path: PoolVector2Array, pathing_delegate):
	if current_movement_points == 0:
		return
	
	var new_pos
	if current_movement_points < path.size():
		new_pos = path[current_movement_points - 1]
		current_movement_points = 0
	else:
		new_pos = path[path.size() - 1]
		current_movement_points -= path.size()
	_move(new_pos.x, new_pos.y, pathing_delegate)

func _move(x: int, y: int, pathing_delegate):
	var oldX = gridX
	var oldY = gridY
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16
	pathing_delegate.unblock_pathing_to_point(Vector2(oldX, oldY))
	pathing_delegate.block_pathing_to_point(Vector2(gridX, gridY))

func on_click():
	get_parent().child_clicked(self)

func end_turn(pathing_delegate):
	current_movement_points = max_movement_points

func _ready():
	current_health = max_health
	current_movement_points = max_movement_points
	_move(gridX, gridY, get_parent())
