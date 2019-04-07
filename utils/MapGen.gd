extends Node

var Rand = preload("res://utils/Rand.gd")

enum Tiles { FLOOR, WALL, MARK }

enum Direction { NORTH, SOUTH, EAST, WEST }

var all_directions = [Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST]

var num_room_tries: int = 100
var extra_connector_chance: int = 50
var room_extra_size: int = 0
var winding_percent: int = 50

var rooms: Array = [] # :: [Rect2]
var _regions = [] # :: [[int]]

var _current_region: int = -1

func _tiles_are_adjacent(p: Vector2, q: Vector2) -> bool:
	for dir in all_directions:
		if _get_tile_in_direction(p, dir) == q:
			return true
	return false

func _get_tile_in_direction(pos: Vector2, direction, distance = 1) -> Vector2:
	if distance == 0:
		return pos
	
	var next_tile
	match direction:
		Direction.NORTH:
			next_tile = Vector2(pos.x, pos.y - 1)
		Direction.SOUTH:
			next_tile = Vector2(pos.x, pos.y + 1)
		Direction.EAST:
			next_tile = Vector2(pos.x + 1, pos.y)
		Direction.WEST:
			next_tile = Vector2(pos.x - 1, pos.y)
	
	return _get_tile_in_direction(next_tile, direction, distance - 1)

func _fill_area(width, height, tile):
	var area = []
	for x in range(width):
		var map_col = []
		for y in range(height):
			map_col.push_back(tile)
		area.push_back(map_col)
	return area

func _can_carve(pos, direction, area):
	# Must be in bounds
	if not Rect2(0, 0, area.size(), area[0].size()).has_point(_get_tile_in_direction(pos, direction, 3)):
		return false
	
	# Destination must not be open
	var p = _get_tile_in_direction(pos, direction, 2)
	return area[p.x][p.y] == Tiles.WALL
	
func _grow_maze(area, pos: Vector2) -> void:
	var cells: Array = []
	var last_dir
	
	_current_region += 1
	_carve_point(area, pos)
	
	cells.push_back(pos)
	while cells.size() > 0:
		var cell = cells[cells.size() - 1]
		
		var unmade_cells = []
		
		for dir in all_directions:
			if _can_carve(cell, dir, area):
				unmade_cells.push_back(dir)
		
		if unmade_cells.size() > 0:
			var dir
			if last_dir and unmade_cells.find(last_dir) != -1 and Rand.int_range(0, 100) > winding_percent:
				dir = last_dir
			else:
				dir = Rand.choose(unmade_cells)
		
			var one_away = _get_tile_in_direction(cell, dir, 1)
			var two_away = _get_tile_in_direction(cell, dir, 2)
			_carve_point(area, one_away)
			_carve_point(area, two_away)
			
			cells.push_back(two_away)
			last_dir = dir
		else:
			cells.pop_back()
			last_dir = null

func _connect_regions(area):
	var connector_regions = {}
	for x in range(1, area.size() - 1):
		for y in range(1, area[x].size() - 1):
			if area[x][y] != Tiles.WALL:
				continue
			
			var regions = []
			for dir in all_directions:
				var p = _get_tile_in_direction(Vector2(x, y), dir)
				var region = _regions[p.x][p.y]
				if region != -1 and not regions.has(region):
					regions.push_back(region)
			
			if regions.size() < 2:
				continue
			
			connector_regions[Vector2(x, y)] = regions
	
	var connectors = connector_regions.keys()
	var merged = {}
	var open_regions = []
	for i in range(_current_region + 1):
		merged[i] = i
		open_regions.push_back(i)
	
	while open_regions.size() > 1:
		var connector = Rand.choose(connectors)
		area[connector.x][connector.y] = Tiles.FLOOR
		
		var regions = []
		for region in connector_regions[connector]:
			regions.push_back(merged[region])
		var dest = regions[0]
		var sources = regions.duplicate()
		sources.pop_front()
		
		for i in range(_current_region + 1):
			if sources.has(merged[i]):
				merged[i] = dest
		
		for source in sources:
			open_regions.remove(open_regions.find(source))
		
		var new_connectors = []
		for other_connector in connectors:
			if _tiles_are_adjacent(connector, other_connector):
				continue
			
			var rs = []
			for r in connector_regions[other_connector]:
				if not rs.has(merged[r]):
					rs.push_back(r)
			
			if rs.size() > 1:
				new_connectors.push_back(other_connector)
				continue
			
			if Rand.one_in(extra_connector_chance):
				area[other_connector.x][other_connector.y] = Tiles.FLOOR
		connectors = new_connectors
	print(merged)

func _remove_dead_ends(area):
	var done = false
	
	while not done:
		done = true
		
		for x in range(1, area.size() - 1):
			for y in range(1, area[x].size() - 1):
				if area[x][y] == Tiles.WALL:
					continue
				
				var exits = 0
				for dir in all_directions:
					var t = _get_tile_in_direction(Vector2(x, y), dir)
					if not area[t.x][t.y] == Tiles.WALL:
						exits += 1
				
				if exits == 1:
					done = false
					area[x][y] = Tiles.WALL

func generate(width, height):
	if width % 2 == 0 or height % 2 == 0:
		print("Map must be odd sized")
		return
	
	var area = _fill_area(width, height, Tiles.WALL)
	for x in range(area.size()):
		var region_column = []
		for y in range(area.size()):
			 region_column.push_back(-1)
		_regions.push_back(region_column)
	
	_add_rooms(area)
	
	for x in range(1, width - 1, 2):
		if x < width:
			for y in range(1, height - 1, 2):
				if y < height:
					var pos = Vector2(x, y)
					if is_passable(area[x][y]):
						continue
					_grow_maze(area, pos)
	
	_connect_regions(area)
	_remove_dead_ends(area)
	return area

func _debug_print_regions():
	var ascii_regions = ""
	for y in range(_regions[0].size()):
		var row_string = ""
		for x in range(_regions.size()):
			var region_int = _regions[x][y]
			if region_int == -1:
				row_string += "##"
				continue
			if region_int < 10:
				row_string += " "
			row_string += String(region_int)
		ascii_regions += ("\n" + row_string)
	print(ascii_regions) 

func _carve_point(area, pos: Vector2) -> void:
	area[pos.x][pos.y] = Tiles.FLOOR
	_regions[pos.x][pos.y] = _current_region

func _carve_rect(area, rect: Rect2) -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			_carve_point(area, Vector2(x, y))

func _add_rooms(area):
	for i in range(num_room_tries):
		var size = Rand.int_range(1, 3 + room_extra_size) * 2 + 1
		var rectangularity = Rand.int_range(0, 1 + floor(size / 2)) * 2
		var width = size
		var height = size
		if Rand.one_in(2):
			width += rectangularity
		else:
			height += rectangularity
		
		var x = Rand.int_range(0, floor((area.size() - width) / 2)) * 2 + 1
		var y = Rand.int_range(0, floor((area[0].size() - height) / 2)) * 2 + 1
		
		var room = Rect2(x, y, width, height)
		
		var overlaps = false
		for other in rooms:
			if room.intersects(other):
				overlaps = true
				break
		
		if overlaps:
			continue
		
		rooms.push_back(room)
		
		_current_region += 1
		_carve_rect(area, room)

static func get_movement_cost(tile) -> int:
	match tile:
		Tiles.FLOOR:
			return 1
		Tiles.WALL:
			return 99999
	print(String(tile) + " tile has no movement point value!!!")
	return -1

static func is_passable(tile) -> bool:
	if tile == Tiles.FLOOR:
		return true
	if tile == Tiles.WALL:
		return false
	else:
		return false
