extends Node2D

var gridX
var gridY

func init(x, y):
	gridX = x
	gridY = y

func move(x, y):
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16

func on_click():
	print("clicked!")

func _ready():
	move(gridX, gridY)
