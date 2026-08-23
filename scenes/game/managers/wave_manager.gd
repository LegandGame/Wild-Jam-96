## Wave Manager, handles starting waves, stopping waves, and spawning units
class_name WaveManager extends Node

#region UnitScenes
## Map of UnitType to preloaded unit scene
var unit_type_to_preload: Dictionary[Types.UnitType, Resource] = {
	Types.UnitType.ENEMY_GUARD: preload("res://entities/Units/all_units/evil_guard_unit.tscn"),
	Types.UnitType.ENEMY_SPEARMAN: preload("res://entities/Units/all_units/evil_spearman_unit.tscn"),
	Types.UnitType.ENEMY_CAVALRY: preload("res://entities/Units/all_units/evil_cavalry_unit.tscn")
}
#endregion

#region WaveState
## Current wave state. Modifying emits a signal with updated state and current wave number
var wave_state: Types.WaveState = Types.WaveState.SPAWNING:
	set(state):
		wave_state = state
		change_wave_state.emit(wave_state, wave_number)

signal change_wave_state(wave_state: Types.WaveState, wave_number: int)
#endregion

#region WaveFields
@export var wave_spawn_delay: float = 2.0

## Downtime between waves in seconds
@export var wave_downtime: float = 8.0

## Statically defined first 5 waves - after this, they are generated.
var starting_waves = [
	# Wave 1
	{
		Types.UnitType.ENEMY_GUARD: 3
	},
	# Wave 2
	{
		Types.UnitType.ENEMY_GUARD: 2,
		Types.UnitType.ENEMY_SPEARMAN: 1
	},
	# Wave 3
	{
		Types.UnitType.ENEMY_GUARD: 2,
		Types.UnitType.ENEMY_SPEARMAN: 2
	},
	# Wave 4
	{
		Types.UnitType.ENEMY_SPEARMAN: 4
	},
	# Wave 5
	{
		Types.UnitType.ENEMY_GUARD: 2,
		Types.UnitType.ENEMY_SPEARMAN: 2,
		Types.UnitType.ENEMY_CAVALRY: 1
	},
]

## Wave number, beginning at 1
var wave_number: int

## Remaining units to spawn in current wave
var units_to_spawn: Array[Types.UnitType]
var total_unit_count: int
var remaining_unit_count: int

signal enemy_died

#endregion

#region Process
func _ready():
	# wire up timers
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	$DowntimeTimer.timeout.connect(_on_downtime_timer_timeout)
	
	# set initial wave number
	wave_number = 1
	
	# start initial wave
	_start_wave_spawn()

func _process(_delta):
	# update wave label
	match wave_state:
		Types.WaveState.SPAWNING, Types.WaveState.CLEARING:
			var text = "[b]Wave {0}[/b]: {1} / {2} Remaining".format([wave_number, remaining_unit_count, total_unit_count])
			$Label.text = text
		Types.WaveState.DOWNTIME:
			var text = "[b]Wave {0}[/b] Completed, Next in {1}s".format([wave_number, "%.0f" % $DowntimeTimer.time_left])
			$Label.text = text
	
	if wave_state == Types.WaveState.CLEARING:
		if remaining_unit_count == 0:
			_handle_wave_clear()
#endregion

#region Spawning
func _load_wave_from_starting_waves() -> Array[Types.UnitType]:
	var units: Array[Types.UnitType] = []
	var starting_wave = starting_waves[wave_number - 1]
	for unit_type in starting_wave.keys() as Array[Types.UnitType]:
		for i in range(starting_wave[unit_type]):
			units.append(unit_type)
	units.shuffle()
	return units

func _generate_wave() -> Array[Types.UnitType]:
	if wave_number <= starting_waves.size():
		return _load_wave_from_starting_waves()
	
	var units = []
	var unit_budget = wave_number
	
	# first add guards
	for i in randi_range(0, unit_budget):
		units.append(Types.UnitType.ENEMY_GUARD)
		unit_budget -= 1
	
	# then spearmen
	for i in randi_range(0, ceil(unit_budget/2.0)):
		units.append(Types.UnitType.ENEMY_SPEARMAN)
		unit_budget = max(0, unit_budget - 2)
	
	# finally fill remaining with cavalry
	for i in range(0, ceil(unit_budget/3.0)):
		units.append(Types.UnitType.ENEMY_CAVALRY)
	
	# shuffle and return
	units.shuffle()
	return units

func _start_wave_spawn():
	wave_state = Types.WaveState.SPAWNING

	# Set wave unit variables
	units_to_spawn = _generate_wave()
	total_unit_count = units_to_spawn.size()
	remaining_unit_count = total_unit_count
	
	# Start the spawn delay timer - every x seconds, a unit will be spawned
	if not $SpawnTimer.is_stopped():
		print("Spawn timer already running on start wave call")
	$SpawnTimer.start(wave_spawn_delay)

func _on_spawn_timer_timeout():
	if units_to_spawn.is_empty():
		wave_state = Types.WaveState.CLEARING
		$SpawnTimer.stop()
	else:
		_spawn_unit(units_to_spawn[0])
		
		# restart spawn timer
		$SpawnTimer.start(wave_spawn_delay)

func _spawn_unit(unit_type: Types.UnitType):
	# spawn unit based on type
	var spawn_point = get_tree().get_nodes_in_group("enemy_spawn").pick_random()
	var unit = unit_type_to_preload.get(unit_type).instantiate()
	add_child(unit)
	unit.global_position = spawn_point.global_position
	unit.unit_died.connect(_on_unit_death)
	
	# remove from spawn list
	units_to_spawn.pop_front()

func _on_unit_death():
	remaining_unit_count -= 1
	
	enemy_died.emit()
#endregion

#region Clearing
func _handle_wave_clear():
	wave_state = Types.WaveState.DOWNTIME
	if $DowntimeTimer.is_stopped():
		$DowntimeTimer.start(wave_downtime)
#endregion

#region Downtime
func _on_downtime_timer_timeout():
	$DowntimeTimer.stop()
	
	# bump wave number and start next
	wave_number += 1
	_start_wave_spawn()
#endregion
