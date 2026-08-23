class_name Types

enum UnitType {
	## Ally Units
	ALLY_GUARD,
	ALLY_SPEARMAN,
	ALLY_CAVALRY,
	
	## Enemy Units
	ENEMY_GUARD,
	ENEMY_SPEARMAN,
	ENEMY_CAVALRY,
}

## Used by [WaveManager] to track state within wave.
enum WaveState {
	SPAWNING, # Enemies actively being spawned
	CLEARING, # Waiting for player to kill enemies
	DOWNTIME, # Waiting for next wave to begin
}
