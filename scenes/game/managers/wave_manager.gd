## Wave Manager, handles starting waves, stopping waves, and spawning units
class_name WaveManager extends Node3D

#region UnitScenes
## Map of UnitType to preloaded unit scene
var unit_type_to_preload: Dictionary[Types.UnitType, Resource] = {
	Types.UnitType.ALLY_DEBUG: preload("res://entities/Units/debug_unit/debug_unit.tscn"),
	Types.UnitType.ENEMY_DEBUG: preload("res://entities/Units/debug_unit/debug_unit.tscn")
}
#endregion

#region WaveState
## Current wave state. Modifying emits a signal with updated state and current wave number
var wave_state: Types.WaveState = Types.WaveState.SPAWNING:
	set(state):
		wave_state = state
		change_wave_state.emit(wave_state, wave_index + 1)

signal change_wave_state(wave_state: Types.WaveState, wave_number: int)
#endregion

#region WaveFields
## Full list of waves to iterate through
@export var wave_list: Array[Wave]

## Downtime between waves in seconds
@export var wave_downtime: float = 15.0

## Index of currently processed wave, wave number minus 1
var wave_index: int

## Remaining units to spawn in current wave
var units_to_spawn: Array[UnitCount]
var total_unit_count: int
var remaining_unit_count: int
#endregion

#region Engine
func _ready():
	# wire up timers
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	$DowntimeTimer.timeout.connect(_on_downtime_timer_timeout)
	
	# set initial wave index
	wave_index = 0

func _process(_delta):
	if wave_state == Types.WaveState.CLEARING:
		if not get_children().any(func(child): return child is Unit):
			_handle_wave_clear()
#endregion

#region Spawning
func _start_wave_spawn():
	wave_state = Types.WaveState.SPAWNING
	
	# Set wave unit variables
	units_to_spawn = wave_list[wave_index].unit_counts.duplicate_deep()
	total_unit_count = units_to_spawn.reduce(func(count, next): return count + next.count, 0)
	remaining_unit_count = total_unit_count
	
	# Start the spawn delay timer - every x seconds, a unit will be spawned
	if not $SpawnTimer.is_stopped():
		print("Spawn timer already running on start wave call")
	$SpawnTimer.start(wave_list[wave_index].spawn_delay)

func _on_spawn_timer_timeout():
	if units_to_spawn.is_empty():
		wave_state = Types.WaveState.CLEARING
	else:
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
	remaining_unit_count -= 1
#endregion

#region Clearing
func _handle_wave_clear():
	# check for final wave
	if (wave_index + 1) == wave_list.size():
		# TODO process final wave
		pass
	
	# otherwise, kick off downtime
	wave_state = Types.WaveState.DOWNTIME
	$DowntimeTimer.start(wave_downtime)
#endregion

#region Downtime
func _on_downtime_timer_timeout():
	# bump wave index and start next
	wave_index += 1
	_start_wave_spawn()
#endregion
