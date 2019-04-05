extends Node2D
const MapGenUtil = preload("utils/MapGen.gd")

var map
var astar
var selected_entity
var entities = []

onready var DungeonMap = get_node("DungeonMap")
onready var Entity = preload("res://scenes/Entity.tscn")

func is_entity_at_position(pos: Vector2) -> bool:
	for entity in entities:
		if entity.gridX == pos.x and entity.gridY == pos.y:
			return true
	return false

# Generates a unique int for a given pair, a uuid for a Vector2
func _cantor_pair(a, b):
	return (a + b) * (a + b + 1) / 2 + a

func _initialize_astar(_map):
	astar = AStar.new()
	for x in range(_map.size()):
		for y in range(_map[x].size()):
			astar.add_point(_cantor_pair(x, y), Vector3(x, y, 0))
	
	for x in range(_map.size()):
		for y in range(_map[x].size()):
			# All except the furthest right
			if x < _map.size() - 1:
				# Connect point to the right
				astar.connect_points(_cantor_pair(x, y), _cantor_pair(x + 1, y))
			# All except the furthest down
			if y < _map[x].size() - 1:
				# Connect point to the bottom
				astar.connect_points(_cantor_pair(x, y), _cantor_pair(x, y + 1))
			# All except furthest right OR furthest down
			if x < _map.size() - 1 and y < _map[x].size():
				# Connect to the bottom-right diagonal
				astar.connect_points(_cantor_pair(x, y), _cantor_pair(x + 1, y + 1))

func get_vector_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var v3_array = astar.get_point_path(_cantor_pair(from.x, from.y), _cantor_pair(to.x, to.y))
	var v2_array = PoolVector2Array([])
	for v3 in v3_array:
		v2_array.append(Vector2(v3.x, v3.y))
	return v2_array

func _unhandled_input(event):
	if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
		var map_position = DungeonMap.world_to_map(event.position)
		if selected_entity and not is_entity_at_position(map_position):
			var path = get_vector_path(Vector2(selected_entity.gridX, selected_entity.gridY), map_position)
			print(path)
			selected_entity.move(map_position.x, map_position.y)

func _add_player_unit(x, y):
	var e = Entity.instance()
	e.init(x, y)
	add_child(e)
	return e

func _ready():
	OS.set_window_size(Vector2(16 * 30, 16 * 30))
	
	map = MapGenUtil.gen_map(30, 30, 0)
	_initialize_astar(map)
	DungeonMap.draw_map(map)
	
	entities.push_back(_add_player_unit(0, 0))
	entities.push_back(_add_player_unit(1, 0))
	entities.push_back(_add_player_unit(29, 0))

func child_clicked(node):
	selected_entity = node