extends Node2D
const MapGenUtil = preload("utils/MapGen.gd")

var map
var selected_entity
var entities = []

onready var DungeonMap = get_node("DungeonMap")
onready var Entity = preload("res://scenes/Entity.tscn")

func is_entity_at_position(pos: Vector2) -> bool:
	for entity in entities:
		if entity.gridX == pos.x and entity.gridY == pos.y:
			return true
	return false

func _unhandled_input(event):
	if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
		var map_position = DungeonMap.world_to_map(event.position)
		if selected_entity and not is_entity_at_position(map_position):
			selected_entity.move(map_position.x, map_position.y)

func _add_player_unit(x, y):
	var e = Entity.instance()
	e.init(x, y)
	add_child(e)
	return e

func _ready():
	OS.set_window_size(Vector2(16 * 30, 16 * 30))
	
	map = MapGenUtil.gen_map(30, 30, 0)
	DungeonMap.draw_map(map)
	
	entities.push_back(_add_player_unit(0, 0))
	entities.push_back(_add_player_unit(1, 0))
	entities.push_back(_add_player_unit(29, 0))

func child_clicked(node):
	selected_entity = node