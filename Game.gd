extends Node2D
const MapGenUtil = preload("utils/MapGen.gd")


var map
onready var DungeonMap = get_node("DungeonMap")
onready var Entity = preload("res://scenes/Entity.tscn")

func _add_player_unit(x, y):
	var e = Entity.instance()
	e.init(x, y)
	add_child(e)

func _ready():
	OS.set_window_size(Vector2(16 * 30, 16 * 30))
	
	map = MapGenUtil.gen_map(30, 30, 0)
	DungeonMap.draw_map(map)
	
	_add_player_unit(0, 0)
	_add_player_unit(1, 0)
	_add_player_unit(29, 0)
