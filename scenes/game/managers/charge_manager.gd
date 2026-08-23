## Manager for Charge levels, registering changes and emitting signals on events
class_name ChargeManager extends Node

# Signals
signal min_charge_reached
signal max_charge_reached
signal charge_modified(value)
signal charge_level_changed(new_level: int)
signal charge_steal_level_changed(new_level: int)

## Minimum charge - hit this and you lose
@export var min_charge: float = 0.0

## Maximum charge - hit this and you win
@export var max_charge: float = 1000.0

## Starting charge - begin here on new game
@export var starting_charge: float = 200.0

## Current charge level, between [member ChargeManager.min_charge] and [member ChargeManager.max_charge].
var charge: float

## Charge production level, begins at 0. See [Upgrades].
var charge_level: int = 0

## Charge produced per second
var charge_rate: float

## Charge steal level, begins at 0. See [Upgrades].
var charge_steal_level: int = 0

## Amount of charge regenerated on enemy kill
var charge_steal: float

## If true, increase charge by rate each second
var charge_production_enabled: bool = false

## Map of UnitType to preloaded unit scene
var unit_type_to_preload: Dictionary[Types.UnitType, Resource] = {
	Types.UnitType.ALLY_GUARD: preload("res://entities/Units/all_units/guard_unit.tscn"),
	Types.UnitType.ALLY_SPEARMAN: preload("res://entities/Units/all_units/spearman_unit.tscn"),
	Types.UnitType.ALLY_CAVALRY: preload("res://entities/Units/all_units/cavalry_unit.tscn")
}

func _ready():
	# set initial values
	charge = starting_charge
	charge_level = 0
	charge_rate = Upgrades.CHARGE_PRODUCTION_LEVEL_AMOUNTS[charge_level]
	charge_steal_level = 0
	charge_steal = Upgrades.CHARGE_STEAL_AMOUNTS[charge_steal_level]
	
	# TODO set this to true after tutorial / on round start eventually
	charge_production_enabled = true

func _process(delta):
	# add charge since last tick
	if charge_production_enabled:
		add_charge(charge_rate * delta)

func add_charge(amount: float):
	charge += amount
	
	# check boundaries
	if charge > max_charge:
		charge = max_charge
		max_charge_reached.emit()
	elif charge < min_charge:
		charge = min_charge
		min_charge_reached.emit()
	
	charge_modified.emit(charge)

func add_charge_rate(amount: float):
	charge_rate += amount

func multiply_charge_rate(amount: float):
	charge_rate *= amount

func _on_unit_tile_pressed(unit_type: Types.UnitType, _cost: float):
	var have_enough_charge = charge > Upgrades.UNIT_TYPE_COSTS[unit_type]
	if have_enough_charge:
		AudioManager.play_click()
		add_charge(-Upgrades.UNIT_TYPE_COSTS[unit_type])
		_spawn_unit(unit_type)

func _on_charge_upgrade_tile_pressed(_charge_level: int, _cost: float):
	var at_max_level = charge_level + 1 == Upgrades.CHARGE_PRODUCTION_LEVELS
	var have_enough_charge = charge > Upgrades.CHARGE_PRODUCTION_NEXT_LEVEL_COSTS[charge_level]
	if have_enough_charge and not at_max_level:
		AudioManager.play_click()
		add_charge(-Upgrades.CHARGE_PRODUCTION_NEXT_LEVEL_COSTS[charge_level])
		_increase_charge_level()

func _on_steal_charge_tile_pressed(_charge_steal_level: int, _cost: float):
	var at_max_level = charge_steal_level + 1 == Upgrades.CHARGE_STEAL_LEVELS
	var have_enough_charge = charge > Upgrades.CHARGE_STEAL_NEXT_LEVEL_COSTS[charge_level]
	if have_enough_charge and not at_max_level:
		AudioManager.play_click()
		add_charge(-Upgrades.CHARGE_STEAL_NEXT_LEVEL_COSTS[charge_level])
		_increase_charge_steal_level()

func _spawn_unit(unit_type: Types.UnitType):
	var spawn_point = get_tree().get_nodes_in_group("ally_spawn").pick_random()
	var unit = unit_type_to_preload.get(unit_type).instantiate()
	add_child(unit)
	unit.global_position = spawn_point.global_position

func _on_unit_death():
	# TODO hook this up
	add_charge(charge_steal)

func _on_shield_attack(amount):
	# TODO hook this up
	add_charge(-amount)

func _increase_charge_level():
	charge_level += 1
	charge_rate = Upgrades.CHARGE_PRODUCTION_LEVEL_AMOUNTS[charge_level]
	charge_level_changed.emit(charge_level)

func _increase_charge_steal_level():
	charge_steal_level += 1
	charge_steal = Upgrades.CHARGE_STEAL_AMOUNTS[charge_steal_level]
	charge_steal_level_changed.emit(charge_steal_level)
