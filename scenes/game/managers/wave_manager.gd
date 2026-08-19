## Wave Manager, handles starting waves, stopping waves, and spawning units
class_name WaveManager extends Node3D

signal wave_started
signal wave_ended

## Map of UnitType to preloaded unit scene
var unit_type_to_preload: Dictionary[Types.UnitType, Resource] = {
	Types.UnitType.ALLY_DEBUG: preload("res://entities/Units/debug_unit/debug_unit.tscn"),
	Types.UnitType.ENEMY_DEBUG: preload("res://entities/Units/debug_unit/debug_unit.tscn")
}

@export var wave_list: Array[Wave]
var wave_index = 0

## Remaining units to spawn in current wave
var units_to_spawn: Array[UnitCount]

func _ready():
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)

func _start_wave():
	wave_started.emit()
	
	if not $SpawnTimer.is_stopped():
		print("Spawn timer already running on start wave call")
	
	units_to_spawn = wave_list[wave_index].unit_counts.duplicate_deep()
	
	# Start the spawn delay timer - every x seconds, a unit will be spawned
	$SpawnTimer.start(wave_list[wave_index].spawn_delay)

func _on_spawn_timer_timeout():
	if units_to_spawn.is_empty():
		# TODO: wait for lingering enemies to die before ending wave
		_end_wave()
	
	_spawn_unit(units_to_spawn[0].unit_type)
	
	# restart spawn timer
	$SpawnTimer.start(wave_list[wave_index].spawn_delay)

func _spawn_unit(unit_type: Types.UnitType):
	# spawn unit based on type
	var unit = unit_type_to_preload.get(units_to_spawn[0].unit_type)
	add_child(unit.instantiate())
	
	# update remaining unit counts to spawn
	units_to_spawn[0].count -= 1
	if units_to_spawn[0].count == 0:
		units_to_spawn.pop_front()

func _end_wave():
	# TODO: handle wave finish, check for final wave
	wave_ended.emit()
	
	# Bump wave index and start next
	wave_index += 1
	_start_wave()
