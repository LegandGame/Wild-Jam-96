## Class for a tile button that spawns a unit when pressed.
class_name UnitTile extends Control

signal tile_pressed(unit_type: Types.UnitType, cost: float)

@export var unit_type: Types.UnitType
@export var cost: float = 50

var can_afford: bool = false
var hovered: bool = false

@export var default_texture: Texture2D = preload("res://assets/buttons/ally_base.png")
@export var unit_type_to_button_texture: Dictionary[Types.UnitType, Texture2D] = {
	Types.UnitType.ALLY_DEBUG: preload("res://assets/buttons/ally_sword.png"),
	Types.UnitType.ENEMY_DEBUG: preload("res://assets/buttons/enemy_sword.png"),
}

func _init(p_unit_type: Types.UnitType = Types.UnitType.ALLY_DEBUG):
	unit_type = p_unit_type

func _ready():
	$TextureButton.texture_normal = unit_type_to_button_texture.get(unit_type, default_texture)

func _process(_delta):
	var multiplier = 1.0 if hovered else 0.8
	if can_afford:
		$TextureButton.modulate = Color(1,1,1,1) * multiplier
	else:
		$TextureButton.modulate = Color(1,0.5,0.5,0.6)

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _on_charge_modified(value):
	can_afford = value >= cost

func _on_texture_button_pressed():
	if can_afford:
		$TextureButton.modulate = Color(0,0,1,1)
		tile_pressed.emit(unit_type, cost)
