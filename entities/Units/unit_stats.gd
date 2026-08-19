class_name UnitStats extends Resource

@export var name : String = "debug"
@export_enum("ALLY", "ENEMY") var alignment : String = "ALLY"	## which side this enemy is on
const UNIT_COLORS = {
	"ALLY" : Color(0.0, 0.525, 0.875, 1.0),
	"ENEMY" : Color(0.45, 0.104, 0.072, 1.0)
}
@export_category("Data")
@export var health : int = 3
@export var cost : int = 1
@export var move_speed : float = 5.0
const ACCEL : float = 5.0
