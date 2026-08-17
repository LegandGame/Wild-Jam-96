## Data class for wave config
class_name Wave extends Resource

@export var name: String
@export var wave_number: int

## Time in seconds between each unit spawn
@export var spawn_delay: float = 2.0

## Ordered set of units to spawn in the wave.
## Spawner will spawn unit count by unit count until complete.
@export var unit_counts: Array[UnitCount]

## Validate the wave config.
func _init():
	assert(spawn_delay > 0.0)
	assert(not unit_counts.is_empty())
