extends Node

var Entity = preload("res://scenes/Entity.tscn")
var Crusader = preload("res://scenes/classes/Crusader.tscn")
var EnemyEntity = preload("res://scenes/EnemyEntity.tscn")
const Rand = preload("res://utils/Rand.gd")
const StatusHelper = preload("res://scripts/status/StatusHelper.gd")

var units = []
var selected_unit
var _game

func init(game):
	_game = game

func get_enemy_units():
	var e_units = []
	for unit in units:
		if not unit.player_controlled:
			e_units.push_back(unit)
	return e_units

func get_player_units():
	var p_units = []
	for unit in units:
		if unit.player_controlled:
			p_units.push_back(unit)
	return p_units

func get_unit_at_position(pos: Vector2):
	for unit in units:
		if unit.grid_pos == pos:
			return unit

func is_enemy_unit_at_position(pos: Vector2) -> bool:
	for unit in units:
		if unit.grid_pos == pos and not unit.player_controlled:
			return true
	return false

func is_player_unit_at_position(pos: Vector2) -> bool:
	for unit in units:
		if unit.grid_pos == pos and unit.player_controlled:
			return true
	return false

func is_unit_at_position(pos: Vector2) -> bool:
	return is_enemy_unit_at_position(pos) or is_player_unit_at_position(pos)

func _get_all_positions_in_rect(rect: Rect2) -> Array:
	var positions = []
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			positions.push_back(Vector2(x, y))
	return positions

func place_enemy_units_in_rect(rect: Rect2) -> void:
	var positions = _get_all_positions_in_rect(rect)
	for i in range(Rand.int_range(3, 5)):
		var p = Rand.choose(positions)
		_add_enemy_unit(p.x, p.y, "Pagan")
		positions.remove(positions.find(p))

func place_player_units_in_rect(rect: Rect2) -> void:
	var names = ["Matt", "Liam", "Dave", "Beth", "Tommy", "Harold", "Pikachu"]
	var positions = _get_all_positions_in_rect(rect)
	for i in range(3):
		var p = Rand.choose(positions)
		var n = Rand.choose(names)
		_add_player_unit(p.x, p.y, n)
		positions.remove(positions.find(p))

func _add_player_unit(x, y, name):
	var e = Crusader.instance()
	e.init(x, y, name)
	_game.add_child(e)
	e.connect("update_ui", _game, "_update_unit_display", [e])
	units.push_back(e)
	return e

func _add_enemy_unit(x, y, name):
	var e = EnemyEntity.instance()
	e.init(x, y, name)
	_game.add_child(e)
	units.push_back(e)
	return e

func kill_unit(unit):
	_game.unblock_pathing_to_point(unit.grid_pos)
	_game.remove_child(unit)
	if not (units.find(unit) == -1):
		units.remove(units.find(unit))