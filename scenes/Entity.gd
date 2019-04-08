extends Node2D

var move_audio
var take_damage_audio
var miss_audio
var hit_audio
var death_audio

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

func move_along_path(path: Array, pathing_delegate):
	if current_movement_points == 0:
		yield(get_tree(), "idle_frame")
		return
	
	var affordable_path = []
	var path_cost = 0
	while path_cost <= current_movement_points and path.size() > 0:
		var next_point_cost = pathing_delegate.get_movement_cost_for_point(path[0])
		path_cost += next_point_cost
		affordable_path.push_back(path[0])
		path.remove(0)
	
	if path_cost > current_movement_points:
		affordable_path.pop_back()

	current_movement_points -= path_cost
	
	for point in affordable_path:
		_move(point.x, point.y, pathing_delegate)
		yield(get_tree().create_timer(0.1), "timeout")
	
	yield(get_tree(), "idle_frame")

func log_line(line):
	get_parent().log_line(line)

func take_damage(damage: int) -> bool:
	if damage >= current_health:
		death_audio.play()
		get_parent().kill_entity(self)
		return true
	else:
		take_damage_audio.play()
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
		hit_audio.play()
		var damage = (randi() % (max_damage - min_damage)) + min_damage
		var killed = entity.take_damage(damage)
		if killed:
			log_line("Killed " + entity.display_name)
		else:
			log_line("Hit " + entity.display_name + " for " + String(damage) + ", now has " + String(entity.current_health))
	else:
		miss_audio.play()
		log_line("Missed " + entity.display_name)
	
	current_attack_points -= 1

func _move(x: int, y: int, pathing_delegate):
	_move_without_sound(x, y, pathing_delegate)
	move_audio.play_audio()

func _move_without_sound(x: int, y: int, pathing_delegate):
	var oldX = gridX
	var oldY = gridY
	gridX = x
	gridY = y
	self.position.x = gridX * 16
	self.position.y = gridY * 16
	pathing_delegate.unblock_pathing_to_point(Vector2(oldX, oldY))
	pathing_delegate.block_pathing_to_point(Vector2(gridX, gridY))

func on_click():
	get_parent().child_clicked(self)

func end_turn(pathing_delegate):
	yield(get_tree(), "idle_frame")
	current_movement_points = max_movement_points
	current_attack_points = max_attack_points

func _ready():
	move_audio = get_node("MoveAudio")
	take_damage_audio = get_node("TakeDamageAudio")
	miss_audio = get_node("MissAudio")
	hit_audio = get_node("HitAudio")
	death_audio = get_node("DeathAudio")
	
	current_health = max_health
	current_movement_points = max_movement_points
	current_attack_points = max_attack_points
	_move_without_sound(gridX, gridY, get_parent())
