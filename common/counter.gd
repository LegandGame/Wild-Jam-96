class_name Counter extends Node
## Generic Component used for keeping track of an Integer Value

@export var max_value : int = 100:
	get:
		return max_value
	set(new_max_value):
		max_value = new_max_value
		_util_clamp_value()
		max_value_updated.emit(new_max_value)
@export var min_value : int = 0:
	get:
		return min_value
	set(new_min_value):
		min_value = new_min_value
		_util_clamp_value()
		min_value_updated.emit(new_min_value)
@onready var value : int = max_value:
	get:
		return value
	set(new_value):
		value = clampi(new_value, min_value, max_value)
		_util_check_value_range()
		value_updated.emit(value)

@export var regen_timer : Timer
@export var regen_per_tick : int = 1

signal value_updated(new_value)
signal max_value_updated(new_max_value)
signal min_value_updated(new_min_value)
signal value_empty
signal value_full

func _ready() -> void:
	if regen_timer:
		regen_timer.timeout.connect(func(): value += regen_per_tick)

func _util_clamp_value() -> void:
	value = clampi(value, min_value, max_value)

func _util_check_value_range() -> void:
	if value <= min_value:
		value_empty.emit()
	elif value >= max_value:
		value_full.emit()

func reset() -> void:
	value = max_value
