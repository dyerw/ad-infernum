extends Node2D

# Resources
var selection_cursor = load("res://selection_cursor.png")
var cursor = load("res://cursor.png")
var attack_cursor = load("res://attack_cursor.png")

const MapGenUtil = preload("utils/MapGen.gd")
const Rand = preload("utils/Rand.gd")
const Map = preload("res://scripts/Map.gd")
const Units = preload("res://scripts/Units.gd")

const map_height = 31
const map_width = 51

var map
var astar
var units
var unit_display
var game_log

var user_input_blocked = false

var _path_tile_indicator_points = []
var _path_tile_indicators = []

onready var DungeonMap = get_node("DungeonMap")
onready var FogOfWar = get_node("FogOfWar")
onready var Entity = preload("res://scenes/Entity.tscn")
onready var EnemyEntity = preload("res://scenes/EnemyEntity.tscn")
onready var TileIndicator = preload("res://scenes/TileIndicator.tscn")
onready var UnitDisplay = preload("res://scenes/UnitDisplay.tscn")
onready var Log = preload("res://scenes/Log.tscn")

# Generates a unique int for a given pair, a uuid for a Vector2
func _cantor_pair(a, b):
	return (a + b) * (a + b + 1) / 2 + a

func pos_is_unobstructed(pos: Vector2) -> bool:
	return not units.is_unit_at_position(pos) and MapGenUtil.is_passable(map.get_tile(pos))

func block_pathing_to_point(pos: Vector2) -> void:
	astar.set_point_weight_scale(_cantor_pair(pos.x, pos.y), 99998)

func unblock_pathing_to_point(pos: Vector2) -> void:
	astar.set_point_weight_scale(
		_cantor_pair(pos.x, pos.y), 
		MapGenUtil.get_movement_cost(map.get_tile(pos))
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
	var v2_array = []
	for v3 in v3_array:
		v2_array.append(Vector2(v3.x, v3.y))
	v2_array.remove(0) # First position is the entities position, we don't need that
	return v2_array

func delete_movement_path() -> void:
	for ti in _path_tile_indicators:
		remove_child(ti)
	_path_tile_indicator_points = []
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
	if user_input_blocked:
		return
	
	if event is InputEventMouseMotion:
		var map_position = DungeonMap.world_to_map(event.position)
		
		# Cursor updates
		if units.is_player_unit_at_position(map_position):
			Input.set_custom_mouse_cursor(selection_cursor)
		
		if not units.is_unit_at_position(map_position):
			Input.set_custom_mouse_cursor(cursor)
		
		if units.selected_unit and units.is_enemy_unit_at_position(map_position):
			Input.set_custom_mouse_cursor(attack_cursor)
		
		# Path indicator updates
		if units.selected_unit and not units.is_unit_at_position(map_position):
			var path = get_vector_path(
				units.selected_unit.grid_pos, 
				map_position
			)
			if not path == _path_tile_indicator_points:
				_path_tile_indicator_points = path
				redraw_movement_path(path, units.selected_unit.current_movement_points)
	
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_RIGHT \
	and event.is_pressed():
		_deselect_entity()
	
	if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
		var map_position = DungeonMap.world_to_map(event.position)
		
		if map_position.x >= map.width or map_position.y >= map.height:
			return
		
		# Move
		if units.selected_unit and not units.is_unit_at_position(map_position) \
		and MapGenUtil.is_passable(map.get_tile(map_position)):
			get_tree().set_input_as_handled()
			var path = get_vector_path(units.selected_unit.grid_pos, map_position)
			user_input_blocked = true
			yield(units.selected_unit.move_along_path(path, self), "completed")
			user_input_blocked = false
			_deselect_entity()
			delete_movement_path()
		
		# Attack
		if units.selected_unit and units.is_enemy_unit_at_position(map_position):
			get_tree().set_input_as_handled()
			var path = get_vector_path(units.selected_unit.grid_pos, map_position)
			var enemy = units.get_unit_at_position(map_position)
			units.selected_unit.attack(enemy, path.size())
			_deselect_entity()

func get_nearest_player_unit(pos: Vector2):
	var min_distance = 9999
	var closest_entity
	for entity in units.get_player_units():
		var path = get_vector_path(pos, entity.grid_pos)
		if path.size() < min_distance:
			closest_entity = entity
			min_distance = path.size()
	return closest_entity

func get_path_to_nearest_player_unit(pos: Vector2) -> PoolVector2Array:
	var min_distance = 999999
	var closest_path = null
	for entity in units.get_player_units():
		var path = get_vector_path(pos, entity.grid_pos)
		if path.size() < min_distance:
			closest_path = path
			min_distance = path.size()
	
	return closest_path

func get_movement_cost_for_point(pos: Vector2) -> int:
	return astar.get_point_weight_scale(_cantor_pair(pos.x, pos.y))

func log_line(line):
	game_log.add_line(line)

func _ready():
	randomize()
	OS.set_window_size(Vector2(16 * map_width + 150, 16 * map_height + 100))
	
	unit_display = get_node("UnitDisplay")
	game_log = get_node("Log")
	
	map = Map.new()
	map.init(map_width, map_height)
	
	units = Units.new()
	units.init(self)
	
	var map_gen = MapGenUtil.new()
	map.tiles = map_gen.generate(map_width, map_height)
	
	DungeonMap.draw_map(map.tiles)
	_initialize_astar(map.tiles)
	
	var rooms = map_gen.rooms.duplicate()
	units.place_player_units_in_rect(rooms[0])
	rooms.pop_front()
	for room in rooms:
		if Rand.one_in(2):
			units.place_enemy_units_in_rect(room)
	
	FogOfWar.draw_fog_of_war(map, units.get_player_units())
	FogOfWar.connect_entities(units.units)

func _deselect_entity():
	delete_movement_path()
	units.selected_unit = null
	unit_display.clear_entity_details()

func _select_entity(node):
	units.selected_unit = node
	unit_display.show_entity_details(node)

func child_clicked(node):
	_select_entity(node)

func end_turn_button_pressed():
	_deselect_entity()
	user_input_blocked = true
	for unit in units.units:
		yield(unit.end_turn(self), "completed")
	user_input_blocked = false