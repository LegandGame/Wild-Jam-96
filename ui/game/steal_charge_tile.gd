## Class for a tile button that upgrades charge stolen from enemies when pressed.
class_name StealChargeTile extends Control

signal steal_charge_tile_pressed(steal_charge_level: int, cost: float)

var charge_steal_level = 0
var can_afford: bool = false
var hovered: bool = false

@export var default_texture: Texture2D = preload("res://assets/ui/buttons/charge_steal_1.png")
@export var charge_steal_level_to_button_texture: Dictionary[int, Texture2D] = {
	0: preload("res://assets/ui/buttons/charge_steal_1.png"),
	1: preload("res://assets/ui/buttons/charge_steal_2.png"),
	2: preload("res://assets/ui/buttons/charge_steal_2.png"),
}

func _ready():
	$TextureButton.texture_normal = charge_steal_level_to_button_texture.get(charge_steal_level, default_texture)
	_set_tooltip()

func _process(_delta):
	var multiplier = 1.0 if not hovered else 0.8
	if can_afford:
		$TextureButton.modulate = Color(1,1,1,1) * multiplier
	else:
		$TextureButton.modulate = Color(1,0.5,0.5,0.6)

func _set_tooltip():
	$TextureButton.tooltip_text = '''
	Steal Charge Level {0}: {1}
	Steal charge from enemies when killed!
	'''.format([charge_steal_level + 1, "%.0f" % Upgrades.CHARGE_STEAL_NEXT_LEVEL_COSTS[charge_steal_level]])

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _on_texture_button_pressed():
	steal_charge_tile_pressed.emit(charge_steal_level + 1, Upgrades.CHARGE_PRODUCTION_NEXT_LEVEL_COSTS[charge_steal_level])

#region ChargeManager event handling
func _on_charge_modified(value):
	can_afford = value >= Upgrades.CHARGE_STEAL_NEXT_LEVEL_COSTS[charge_steal_level]

func _on_charge_steal_level_changed(level):
	charge_steal_level = level
	
	# hide the button if we maxed out the levels
	if charge_steal_level + 1 == Upgrades.CHARGE_STEAL_LEVELS:
		visible = false
	
	# otherwise update texture and tooltip
	else:
		$TextureButton.texture_normal = charge_steal_level_to_button_texture.get(charge_steal_level)
		_set_tooltip()
#endregion
