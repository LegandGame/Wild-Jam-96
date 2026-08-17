## Container class mapping an unit type to a count.
## Used in wave construction for denoting wave
class_name UnitCount extends Resource

@export var unit_type: Types.UnitType
@export var count: int = 1

func _init(p_unit_type: Types.UnitType, p_count: int):
	unit_type = p_unit_type
	count = p_count
	
	assert(count > 0)
