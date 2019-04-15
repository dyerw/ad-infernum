const Stunned = preload("res://scripts/status/Stunned.gd")
const Fervent = preload("res://scripts/status/Fervent.gd")

static func stun(unit, duration):
	var stunned = Stunned.new()
	stunned.init(duration)
	stunned.apply(unit)

static func fervent(unit, duration):
	var fervent = Fervent.new()
	fervent.init(duration)
	fervent.apply(unit)