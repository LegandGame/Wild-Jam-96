class_name Types

enum UnitType {
	## Ally Units
	ALLY_DEBUG,
	
	## Enemy Units
	ENEMY_DEBUG,
}

## Used by [WaveManager] to track state within wave.
enum WaveState {
	SPAWNING, # Enemies actively being spawned
	CLEARING, # Waiting for player to kill enemies
	DOWNTIME, # Waiting for next wave to begin
}
