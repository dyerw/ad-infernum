extends Node2D

var gridX
var gridY

func init(x, y):
	gridX = x
	gridY = y

func _move(x: int, y: int):
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16

func _ready():
	_move(gridX, gridY)
