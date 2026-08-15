class_name UnitStats extends Resource

@export var name : String
enum UNIT_ALIGN {ALLY, ENEMY}
const UNIT_COLORS = {
	UNIT_ALIGN.ALLY : Color(0.0, 0.525, 0.875, 1.0),
	UNIT_ALIGN.ENEMY : Color(0.45, 0.104, 0.072, 1.0)
}
@export var alignment : UNIT_ALIGN	## which side this enemy is on
@export_category("Data")
@export var health : int
@export var cost : int
