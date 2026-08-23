## Class for a tile button that spawns a unit when pressed.
class_name UnitTile extends Control

signal tile_pressed(unit_type: Types.UnitType, cost: float)

@export var unit_type: Types.UnitType

var cost: float
var can_afford: bool = false
var hovered: bool = false

@export var default_texture: Texture2D = preload("res://assets/ui/buttons/guard.png")
@export var unit_type_to_button_texture: Dictionary[Types.UnitType, Texture2D] = {
	Types.UnitType.ALLY_GUARD: preload("res://assets/ui/buttons/guard.png"),
	Types.UnitType.ALLY_SPEARMAN: preload("res://assets/ui/buttons/spearman.png"),
	Types.UnitType.ALLY_CAVALRY: preload("res://assets/ui/buttons/cavalry.png"),
}

func _init(p_unit_type: Types.UnitType = Types.UnitType.ALLY_GUARD):
	unit_type = p_unit_type

func _ready():
	cost = Upgrades.UNIT_TYPE_COSTS[unit_type]
	$TextureButton.texture_normal = unit_type_to_button_texture.get(unit_type, default_texture)
	_set_tooltip()

func _process(_delta):
	var multiplier = 1.0 if not hovered else 0.8
	if can_afford:
		$TextureButton.modulate = Color(1,1,1,1) * multiplier
	else:
		$TextureButton.modulate = Color(1,0.5,0.5,0.6)

func _set_tooltip():
	$TextureButton.tooltip_text = '''
	Spawn {0}: {1}
	Spawns a {0} unit to fight for you!
	'''.format([Types.get_name_from_unit_type(unit_type), "%.0f" % cost])

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _on_charge_modified(value):
	can_afford = value >= cost

func _on_texture_button_pressed():
	tile_pressed.emit(unit_type, cost)
