extends Node

static func int_range(from: int, to: int) -> int:
	if from == to:
		return from
	return (randi() % (to - from)) + from

static func one_in(n: int) -> bool:
	return int_range(0, n) == 0

static func choose(a: Array):
	return a[int_range(0, a.size() -1)]