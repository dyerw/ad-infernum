extends Node2D

var gridX
var gridY
var id

func init(x, y):
	gridX = x
	gridY = y

func move(x: int, y: int):
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16

func on_click():
	get_parent().child_clicked(self)

func _ready():
	move(gridX, gridY)
