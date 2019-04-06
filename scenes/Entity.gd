extends Node2D

var move_audio

var gridX
var gridY
var display_name
var id

var current_movement_points
var current_health
var current_attack_points

# Stats
var max_movement_points = 5
var max_health = 10
var max_attack_points = 1
var dexterity = 5
var max_damage = 6
var min_damage = 3
var attack_range = 1

func init(x, y, _display_name):
	gridX = x
	gridY = y
	display_name = _display_name

func move_along_path(path: PoolVector2Array, pathing_delegate):
	if current_movement_points == 0:
		return
	
	var new_pos
	if current_movement_points < path.size():
		new_pos = path[current_movement_points - 1]
		current_movement_points = 0
	else:
		new_pos = path[path.size() - 1]
		current_movement_points -= path.size()
	_move(new_pos.x, new_pos.y, pathing_delegate)

func log_line(line):
	get_parent().log_line(line)

func take_damage(damage: int) -> bool:
	if damage >= current_health:
		get_parent().kill_entity(self)
		return true
	else:
		current_health -= damage
		return false

func attack(entity, distance):
	if current_attack_points == 0:
		log_line("No more attacks this turn")
		return
	
	if distance > attack_range:
		log_line(entity.display_name + " is out of range")
		return
	
	log_line("----\n" + self.display_name + " attacks " + entity.display_name)
	
	var die_one = randi() % 6
	var die_two = randi() % 6
	var die_three = randi() % 6
	var die_total = die_one + die_two + die_three
	
	var dex_difference = self.dexterity - entity.dexterity
	var final_total = die_total + dex_difference
	log_line("Rolled " + String(die_total) + " + " + String(dex_difference) + " = " + String(final_total) + " need 8")
	if final_total > 7:
		var damage = (randi() % (max_damage - min_damage)) + min_damage
		var killed = entity.take_damage(damage)
		if killed:
			log_line("Killed " + entity.display_name)
		else:
			log_line("Hit " + entity.display_name + " for " + String(damage) + ", now has " + String(entity.current_health))
	else:
		log_line("Missed " + entity.display_name)
	
	current_attack_points -= 1

func _move(x: int, y: int, pathing_delegate):
	var oldX = gridX
	var oldY = gridY
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16 
	move_audio.play_audio()
	pathing_delegate.unblock_pathing_to_point(Vector2(oldX, oldY))
	pathing_delegate.block_pathing_to_point(Vector2(gridX, gridY))

func on_click():
	get_parent().child_clicked(self)

func end_turn(pathing_delegate):
	current_movement_points = max_movement_points
	current_attack_points = max_attack_points

func _ready():
	move_audio = get_node("MoveAudio")
	
	current_health = max_health
	current_movement_points = max_movement_points
	current_attack_points = max_attack_points
	_move(gridX, gridY, get_parent())
