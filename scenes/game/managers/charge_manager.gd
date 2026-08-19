## Manager for Charge levels, registering changes and emitting signals on events
class_name ChargeManager extends Node3D

## Minimum charge - hit this and you lose
const MIN_CHARGE: float = 0.0

## Maximum charge - hit this and you win
const MAX_CHARGE: float = 1000.0

## Starting charge - begin here on new game
const STARTING_CHARGE: float = 200.0

## Initial charge generated per second
const STARTING_RATE: float = 1.0

var charge: float
var charge_rate: float

func _init():
	charge = STARTING_CHARGE
	charge_rate = STARTING_RATE
