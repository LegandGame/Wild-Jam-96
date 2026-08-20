## Manager for Charge levels, registering changes and emitting signals on events
class_name ChargeManager extends Node3D

# Signals
signal min_charge_reached
signal max_charge_reached
signal charge_modified(value)

## Minimum charge - hit this and you lose
@export var min_charge: float = 0.0

## Maximum charge - hit this and you win
@export var max_charge: float = 1000.0

## Starting charge - begin here on new game
@export var starting_charge: float = 200.0

## Initial charge generated per second
@export var starting_charge_rate: float = 1.0

var charge: float
var charge_rate: float

## If true, increase charge by rate each second
var charge_rate_enabled: bool = false

func _ready():
	# set initial values
	charge = starting_charge
	charge_rate = starting_charge_rate
	
	# TODO set this to true after tutorial / on round start eventually
	charge_rate_enabled = true

func _process(delta):
	# add charge since last tick
	if charge_rate_enabled:
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

# TODO move this out of manager so that charge manager doesn't have to listen directly to buttons
func _on_unit_tile_tile_pressed(unit_type, cost):
	add_charge(-cost)
	# TODO spawn unit
