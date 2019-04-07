extends Node2D

# Resources
var selection_cursor = load("res://selection_cursor.png")
var cursor = load("res://cursor.png")
var attack_cursor = load("res://attack_cursor.png")

const MapGenUtil = preload("utils/MapGen.gd")

const map_height = 30
const map_width = 30

var map
var astar
var selected_entity
var entities = []
var enemy_entities = []
var unit_display
var game_log

var _path_tile_indicator_points = PoolVector2Array([])
var _path_tile_indicators = []

onready var DungeonMap = get_node("DungeonMap")
onready var Entity = preload("res://scenes/Entity.tscn")
onready var EnemyEntity = preload("res://scenes/EnemyEntity.tscn")
onready var TileIndicator = preload("res://scenes/TileIndicator.tscn")
onready var UnitDisplay = preload("res://scenes/UnitDisplay.tscn")
onready var Log = preload("res://scenes/Log.tscn")

func get_entity_at_position(pos: Vector2):
	for entity in all_entities():
		if entity.gridX == pos.x and entity.gridY == pos.y:
			return entity

func is_enemy_entity_at_position(pos: Vector2) -> bool:
	for entity in enemy_entities:
		if entity.gridX == pos.x and entity.gridY == pos.y:
			return true
	return false

func is_player_entity_at_position(pos: Vector2) -> bool:
	for entity in entities:
		if entity.gridX == pos.x and entity.gridY == pos.y:
			return true
	return false

func is_entity_at_position(pos: Vector2) -> bool:
	return is_enemy_entity_at_position(pos) or is_player_entity_at_position(pos)

# Generates a unique int for a given pair, a uuid for a Vector2
func _cantor_pair(a, b):
	return (a + b) * (a + b + 1) / 2 + a

func pos_is_unobstructed(pos: Vector2) -> bool:
	return not is_entity_at_position(pos) and MapGenUtil.is_passable(map[pos.x][pos.y])

func block_pathing_to_point(pos: Vector2) -> void:
	astar.set_point_weight_scale(_cantor_pair(pos.x, pos.y), 99998)

func unblock_pathing_to_point(pos: Vector2) -> void:
	astar.set_point_weight_scale(
		_cantor_pair(pos.x, pos.y), 
		MapGenUtil.get_movement_cost(map[pos.x][pos.y])
	)

func _connect_points(_map, from: Vector2, to: Vector2) -> void:
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
				_connect_points(_map, Vector2(x, y), Vector2(x + 1, y))
			# All except the furthest down
			if y < _map[x].size() - 1:
				# Connect point to the bottom
				_connect_points(_map, Vector2(x, y), Vector2(x, y + 1))
			# All except furthest right OR furthest up
			if x < _map.size() - 1 and (not y == 0):
				# Connect to top right diagonal
				_connect_points(_map, Vector2(x, y), Vector2(x + 1, y - 1))
			# All except furthest right OR furthest down
			if x < _map.size() - 1 and y < _map[x].size():
				# Connect to the bottom-right diagonal
				_connect_points(_map, Vector2(x, y), Vector2(x + 1, y + 1))
	
	for x in range(_map.size() - 1):
		for y in range(_map[x].size() - 1):
			astar.set_point_weight_scale(_cantor_pair(x, y), MapGenUtil.get_movement_cost(_map[x][y]))

func get_vector_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var v3_array = astar.get_point_path(_cantor_pair(from.x, from.y), _cantor_pair(to.x, to.y))
	var v2_array = PoolVector2Array([])
	for v3 in v3_array:
		v2_array.append(Vector2(v3.x, v3.y))
	v2_array.remove(0) # First position is the entities position, we don't need that
	return v2_array

func delete_movement_path() -> void:
	for ti in _path_tile_indicators:
		remove_child(ti)
	_path_tile_indicator_points = PoolVector2Array([])
	_path_tile_indicators = []

func redraw_movement_path(path: PoolVector2Array, distance: int) -> void:
	delete_movement_path()
	for i in range(path.size()):
		if i < distance:
			var point = path[i]
			var p = TileIndicator.instance()
			p.init(point.x, point.y)
			add_child(p)
			_path_tile_indicators.push_back(p)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var map_position = DungeonMap.world_to_map(event.position)
		
		# Cursor updates
		if is_player_entity_at_position(map_position):
			Input.set_custom_mouse_cursor(selection_cursor)
		
		if not is_entity_at_position(map_position):
			Input.set_custom_mouse_cursor(cursor)
		
		if selected_entity and is_enemy_entity_at_position(map_position):
			Input.set_custom_mouse_cursor(attack_cursor)
		
		# Path indicator updates
		if selected_entity and not is_entity_at_position(map_position):
			var path = get_vector_path(
				Vector2(selected_entity.gridX, selected_entity.gridY), 
				map_position
			)
			if not path == _path_tile_indicator_points:
				_path_tile_indicator_points = path
				redraw_movement_path(path, selected_entity.current_movement_points)
	
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_RIGHT \
	and event.is_pressed():
		_deselect_entity()
	
	if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
		var map_position = DungeonMap.world_to_map(event.position)
		
		if map_position.x >= map_width or map_position.y >= map_height:
			return
		
		# Move
		if selected_entity and not is_entity_at_position(map_position) \
		and MapGenUtil.is_passable(map[map_position.x][map_position.y]):
			get_tree().set_input_as_handled()
			var path = get_vector_path(Vector2(selected_entity.gridX, selected_entity.gridY), map_position)
			selected_entity.move_along_path(path, self)
			_deselect_entity()
			delete_movement_path()
		
		# Attack
		if selected_entity and is_enemy_entity_at_position(map_position):
			get_tree().set_input_as_handled()
			var path = get_vector_path(Vector2(selected_entity.gridX, selected_entity.gridY), map_position)
			var enemy = get_entity_at_position(map_position)
			selected_entity.attack(enemy, path.size())
			_deselect_entity()

func _add_player_unit(x, y, name):
	var e = Entity.instance()
	e.init(x, y, name)
	add_child(e)
	return e

func _add_enemy_unit(x, y, name):
	var e = EnemyEntity.instance()
	e.init(x, y, name)
	add_child(e)
	return e

func get_nearest_player_unit(pos: Vector2):
	var min_distance = 9999
	var closest_entity
	for entity in entities:
		var path = get_vector_path(pos, Vector2(entity.gridX, entity.gridY))
		if path.size() < min_distance:
			closest_entity = entity
			min_distance = path.size()
	return closest_entity

func get_path_to_nearest_player_unit(pos: Vector2) -> PoolVector2Array:
	var min_distance = 9999
	var closest_path = null
	for entity in entities:
		# We have to briefly reconnect the player pos to properly pathfind
		var path = get_vector_path(pos, Vector2(entity.gridX, entity.gridY))
		if path.size() < min_distance:
			closest_path = path
			min_distance = path.size()
	
	return closest_path

func log_line(line):
	game_log.add_line(line)

func _ready():
	OS.set_window_size(Vector2(16 * map_width + 100, 16 * map_height + 100))
	
	unit_display = get_node("UnitDisplay")
	game_log = get_node("Log")
	
	map = MapGenUtil.gen_map(map_height, map_width, 0)
	_initialize_astar(map)
	DungeonMap.draw_map(map)
	
	entities.push_back(_add_player_unit(0, 0, "Bob"))
	entities.push_back(_add_player_unit(1, 0, "Rick"))
	entities.push_back(_add_player_unit(29, 0, "Stan"))
	
	for i in range(10):
		var x = randi() % map_width
		var y = randi() % map_height
		if  not is_entity_at_position(Vector2(x, y)) and MapGenUtil.is_passable(map[x][y]):
			enemy_entities.push_back(_add_enemy_unit(x, y, "Skeleton"))

func kill_entity(entity):
	unblock_pathing_to_point(Vector2(entity.gridX, entity.gridY))
	remove_child(entity)
	if not (enemy_entities.find(entity) == -1):
		enemy_entities.remove(enemy_entities.find(entity))
	
	if not (entities.find(entity) == -1):
		entities.remove(entities.find(entity))

func all_entities():
	return entities + enemy_entities

func _deselect_entity():
	delete_movement_path()
	selected_entity = null
	unit_display.clear_entity_details()

func _select_entity(node):
	selected_entity = node
	unit_display.show_entity_details(node)

func child_clicked(node):
	_select_entity(node)

func end_turn_button_pressed():
	_deselect_entity()
	for entity in all_entities():
		entity.end_turn(self)