var duration
var duration_left
var unit
var display_name

func init(_duration):
	duration = _duration
	duration_left = _duration

func end_turn():
	self.duration_left -= 1
	if self.duration_left == 0:
		self.unapply()

func apply(_unit):
	unit = _unit
	unit.statuses.push_back(self)

func unapply():
	unit.statuses.remove(unit.statuses.find(self))
