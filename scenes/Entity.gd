extends Node2D

var gridX
var gridY

onready var EntitySprite = get_node("EntitySprite")

func init(x, y):
	gridX = x
	gridY = y


func move(x, y):
	gridX = x
	gridY = y
	EntitySprite.position.x = gridX * 16
	EntitySprite.position.y = gridY * 16

func _ready():
	move(gridX, gridY)
