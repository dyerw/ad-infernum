extends Node

var tiles
var height
var width

func get_tile(pos: Vector2):
	return tiles[pos.x][pos.y]

func init(_width, _height):
	height = _height
	width = _width
