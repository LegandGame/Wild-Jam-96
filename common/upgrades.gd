class_name Upgrades

#region Unit Purchases
'''
Unit purchases spawn a unit for a given cost.
'''
const UNIT_TYPE_COSTS: Dictionary[Types.UnitType, float] = {
	Types.UnitType.ALLY_GUARD: 30,
	Types.UnitType.ALLY_SPEARMAN: 60,
	Types.UnitType.ALLY_CAVALRY: 90,
	
	# These should not be spawnable - costs are higher than possible
	Types.UnitType.ENEMY_GUARD: 2000,
	Types.UnitType.ENEMY_SPEARMAN: 2000,
	Types.UnitType.ENEMY_CAVALRY: 2000,
}
#endregion

#region Charge Production Upgrades
'''
Charge Production upgrades determine how much charge your castle
generates per second. Starts out with 1.
'''
const CHARGE_PRODUCTION_LEVELS = 5
const CHARGE_PRODUCTION_LEVEL_AMOUNTS: Dictionary[int, float] = {
	0: 1,
	1: 2,
	2: 4,
	3: 8,
	4: 16
}
const CHARGE_PRODUCTION_NEXT_LEVEL_COSTS: Dictionary[int, float] = {
	0: 100, # Going from level 0 to 1
	1: 200, # Going from level 1 to 2
	2: 400, # Going from level 2 to 3
	3: 800, # Going from level 3 to 4
	4: 2000 # Going from level 4 to 5, unreachable
}
#endregion

#region Charge Steal Upgrades
'''
Charge Steal upgrades determine how much charge you receive when
killing an enemy. Starts out with 0.
'''
const CHARGE_STEAL_LEVELS = 3
const CHARGE_STEAL_AMOUNTS: Dictionary[int, float] = {
	0: 0,
	1: 5,
	2: 10,
}
const CHARGE_STEAL_NEXT_LEVEL_COSTS: Dictionary[int, float] = {
	0: 200, # Going from level 0 to 1
	1: 400, # Going from level 1 to 2
	2: 2000 # Going from level 2 to 3, unreachable
}
#endregion
