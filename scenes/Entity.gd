extends Node2D

# Signals
signal entity_moved
signal update_ui

# Audio
var move_audio
var take_damage_audio
var miss_audio
var hit_audio
var death_audio

# Sprites
var health_bar_sprite
var movement_bar_sprite

var grid_pos: Vector2
var display_name
var id
var player_controlled = true

var current_movement_points setget _set_current_movement_points
var current_health setget _set_current_health
var current_attack_points

var statuses = []
var abilities = []

# Stats
var max_movement_points = 5
var max_health = 10
var max_attack_points = 1
var dexterity = 5
var willpower = 3
var evade = 5
var strength = 3
var max_damage = 6
var min_damage = 3
var attack_range = 1

func init(x, y, _display_name):
	grid_pos = Vector2(x, y)
	display_name = _display_name

func _set_current_movement_points(n):
	if movement_bar_sprite:
		if max_movement_points == 0:
			movement_bar_sprite.scale = Vector2(0, 1)
		else:
			movement_bar_sprite.scale = Vector2(float(n) / float(max_movement_points) ,1)
	current_movement_points = n

func _set_current_health(n):
	if health_bar_sprite:
		health_bar_sprite.scale = Vector2(float(n) / float(max_health), 1)
	current_health = n

func move_along_path(path: Array, pathing_delegate):
	if self.current_movement_points == 0:
		yield(get_tree(), "idle_frame")
		return
	
	var affordable_path = []
	var path_cost = 0
	while path_cost <= self.current_movement_points and path.size() > 0:
		var next_point_cost = pathing_delegate.get_movement_cost_for_point(path[0])
		path_cost += next_point_cost
		affordable_path.push_back(path[0])
		path.remove(0)
	
	if path_cost > self.current_movement_points:
		affordable_path.pop_back()

	self.current_movement_points -= path_cost
	
	for point in affordable_path:
		_move(point, pathing_delegate)
		yield(get_tree().create_timer(0.1), "timeout")
	
	yield(get_tree(), "idle_frame")

func log_line(line):
	get_parent().log_line(line)

func take_damage(damage: int) -> bool:
	if damage >= self.current_health:
		death_audio.play()
		get_parent().units.kill_unit(self)
		return true
	else:
		take_damage_audio.play()
		self.current_health -= damage
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
	
	var dex_difference = self.dexterity - entity.evade
	var final_total = die_total + dex_difference
	log_line("Rolled " + String(die_total) + " + " + String(dex_difference) + " = " + String(final_total) + " need 8")
	if final_total > 7:
		hit_audio.play()
		var damage = (randi() % (max_damage - min_damage)) + min_damage + strength
		var killed = entity.take_damage(damage)
		if killed:
			log_line("Killed " + entity.display_name)
		else:
			log_line("Hit " + entity.display_name + " for " + String(damage) + ", now has " + String(entity.current_health))
	else:
		miss_audio.play()
		log_line("Missed " + entity.display_name)
	
	current_attack_points -= 1

func _move(pos: Vector2, pathing_delegate):
	_move_without_sound(pos, pathing_delegate)
	emit_signal("entity_moved", self)
	move_audio.play_audio()

func _move_without_sound(pos: Vector2, pathing_delegate):
	var old_pos = grid_pos
	grid_pos = pos
	self.position.x = grid_pos.x * 16
	self.position.y = grid_pos.y * 16
	pathing_delegate.unblock_pathing_to_point(old_pos)
	pathing_delegate.block_pathing_to_point(grid_pos)

func on_click():
	get_parent().child_clicked(self)

func end_turn(pathing_delegate):
	yield(get_tree(), "idle_frame")
	for status in statuses:
		status.end_turn()
	for ability in abilities:
		ability.end_turn()
	self.current_movement_points = max_movement_points
	self.current_attack_points = max_attack_points

func ability_used(ability):
	emit_signal("update_ui")

func _ready():
	# Audio
	move_audio = get_node("MoveAudio")
	take_damage_audio = get_node("TakeDamageAudio")
	miss_audio = get_node("MissAudio")
	hit_audio = get_node("HitAudio")
	death_audio = get_node("DeathAudio")
	
	# Sprites
	health_bar_sprite = get_node("HealthBarSprite")
	movement_bar_sprite = get_node("MovementBarSprite")
	
	self.current_health = max_health
	self.current_movement_points = max_movement_points
	current_attack_points = max_attack_points
	
	for ability in abilities:
		ability.connect("ability_used", self, "ability_used", [ability])
	
	_move_without_sound(grid_pos, get_parent())
