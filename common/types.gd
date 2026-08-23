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

static func get_name_from_unit_type(unit_type: UnitType) -> String:
	match(unit_type):
		UnitType.ALLY_GUARD, UnitType.ENEMY_GUARD: return "Guard"
		UnitType.ALLY_SPEARMAN, UnitType.ENEMY_SPEARMAN: return "Spearman"
		UnitType.ALLY_CAVALRY, UnitType.ENEMY_CAVALRY: return "Cavalry"
		_: return "Unit"

## Used by [WaveManager] to track state within wave.
enum WaveState {
	SPAWNING, # Enemies actively being spawned
	CLEARING, # Waiting for player to kill enemies
	DOWNTIME, # Waiting for next wave to begin
}
