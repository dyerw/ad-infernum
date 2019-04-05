extends Node2D
const MapGenUtil = preload("utils/MapGen.gd")

var map
var astar
var selected_entity
var entities = []

var _path_tile_indicator_ponts = PoolVector2Array([])
var _path_tile_indicators = []

onready var DungeonMap = get_node("DungeonMap")
onready var Entity = preload("res://scenes/Entity.tscn")
onready var TileIndicator = preload("res://scenes/TileIndicator.tscn")

func is_entity_at_position(pos: Vector2) -> bool:
	for entity in entities:
		if entity.gridX == pos.x and entity.gridY == pos.y:
			return true
	return false

# Generates a unique int for a given pair, a uuid for a Vector2
func _cantor_pair(a, b):
	return (a + b) * (a + b + 1) / 2 + a

func _connect_points_if_passable(_map, from: Vector2, to: Vector2) -> void:
	if MapGenUtil.is_passable(_map[to.x][to.y]) and MapGenUtil.is_passable(_map[from.x][from.y]):
		astar.connect_points(_cantor_pair(from.x, from.y), _cantor_pair(to.x, to.y))

func _initialize_astar(_map):
	astar = AStar.new()
	for x in range(_map.size() - 1):
		for y in range(_map[x].size() - 1):
			astar.add_point(_cantor_pair(x, y), Vector3(x, y, 0))
	
	for x in range(_map.size() - 1):
		for y in range(_map[x].size() - 1):
			# All except the furthest right
			if x < _map.size() - 1:
				# Connect point to the right
				_connect_points_if_passable(_map, Vector2(x, y), Vector2(x + 1, y))
			# All except the furthest down
			if y < _map[x].size() - 1:
				# Connect point to the bottom
				_connect_points_if_passable(_map, Vector2(x, y), Vector2(x, y + 1))
			# All except furthest right OR furthest up
			if x < _map.size() - 1 and (not y == 0):
				# Connect to top right diagonal
				_connect_points_if_passable(_map, Vector2(x, y), Vector2(x + 1, y - 1))
			# All except furthest right OR furthest down
			if x < _map.size() - 1 and y < _map[x].size():
				# Connect to the bottom-right diagonal
				_connect_points_if_passable(_map, Vector2(x, y), Vector2(x + 1, y + 1))

func get_vector_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var v3_array = astar.get_point_path(_cantor_pair(from.x, from.y), _cantor_pair(to.x, to.y))
	var v2_array = PoolVector2Array([])
	for v3 in v3_array:
		v2_array.append(Vector2(v3.x, v3.y))
	return v2_array

func delete_movement_path() -> void:
	for ti in _path_tile_indicators:
		remove_child(ti)
	_path_tile_indicator_ponts = PoolVector2Array([])
	_path_tile_indicators = []

func redraw_movement_path(path: PoolVector2Array) -> void:
	delete_movement_path()
	for point in path:
		var p = TileIndicator.instance()
		p.init(point.x, point.y)
		add_child(p)
		_path_tile_indicators.push_back(p)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var map_position = DungeonMap.world_to_map(event.position)
		if selected_entity and not is_entity_at_position(map_position):
			var path = get_vector_path(
				Vector2(selected_entity.gridX, selected_entity.gridY), 
				map_position
			)
			if not path == _path_tile_indicator_ponts:
				_path_tile_indicator_ponts = path
				redraw_movement_path(path)
	
	if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
		var map_position = DungeonMap.world_to_map(event.position)
		if selected_entity and not is_entity_at_position(map_position):
			var path = get_vector_path(Vector2(selected_entity.gridX, selected_entity.gridY), map_position)
			selected_entity.move(map_position.x, map_position.y)
			delete_movement_path()
			selected_entity = null

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