## Class for a tile button that upgrades charge production when pressed.
class_name ChargeUpgradeTile extends Control

signal charge_upgrade_tile_pressed(charge_level: int, cost: float)

var charge_level = 0
var can_afford: bool = false
var hovered: bool = false

@export var default_texture: Texture2D = preload("res://assets/ui/buttons/charge_1.png")
@export var charge_level_to_button_texture: Dictionary[int, Texture2D] = {
	0: preload("res://assets/ui/buttons/charge_1.png"),
	1: preload("res://assets/ui/buttons/charge_2.png"),
	2: preload("res://assets/ui/buttons/charge_3.png"),
	3: preload("res://assets/ui/buttons/charge_4.png"),
	4: preload("res://assets/ui/buttons/charge_4.png"),
}

func _ready():
	$TextureButton.texture_normal = charge_level_to_button_texture.get(charge_level, default_texture)
	_set_tooltip()

func _process(_delta):
	var multiplier = 1.0 if not hovered else 0.8
	if can_afford:
		$TextureButton.modulate = Color(1,1,1,1) * multiplier
	else:
		$TextureButton.modulate = Color(1,0.5,0.5,0.6)

func _set_tooltip():
	$TextureButton.tooltip_text = '''
	Charge Production Level {0}: {1}
	Increase how much charge is generated per second!
	'''.format([charge_level + 1, "%.0f" % Upgrades.CHARGE_PRODUCTION_NEXT_LEVEL_COSTS[charge_level]])

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _on_texture_button_pressed():
	charge_upgrade_tile_pressed.emit(charge_level + 1, Upgrades.CHARGE_PRODUCTION_NEXT_LEVEL_COSTS[charge_level])

#region ChargeManager event handling
func _on_charge_modified(value):
	can_afford = value >= Upgrades.CHARGE_PRODUCTION_NEXT_LEVEL_COSTS[charge_level]

func _on_charge_level_changed(level):
	charge_level = level
	
	# hide the button if we maxed out the levels
	if charge_level + 1 == Upgrades.CHARGE_PRODUCTION_LEVELS:
		visible = false
	
	# otherwise update texture and tooltip
	else:
		$TextureButton.texture_normal = charge_level_to_button_texture.get(charge_level)
		_set_tooltip()
#endregion
