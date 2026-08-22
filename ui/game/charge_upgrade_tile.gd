## Class for a tile button that upgrades charge production when pressed.
class_name ChargeUpgradeTile extends Control

signal charge_upgrade_tile_pressed(charge_level: int, cost: float)

# TODO finalize costs
@export var charge_level_to_next_level_cost: Dictionary[int, float] = {
	# Base:   0 cps  (inf s to max)
	0: 50,  # 1 cps  (1000 s to max)
	1: 100, # 2 cps  (500 s to max)
	2: 200, # 4 cps  (250 s to max)
	3: 400, # 8 cps  (125 s to max)
	4: 600  # 16 cps (63 s to max)
}

# TODO doesn't feel cleanest here - should move
const MAX_CHARGE_LEVEL = 4 # TODO validate bounds here
var charge_level = 0

var can_afford: bool = false
var hovered: bool = false

# TODO update textures
@export var default_texture: Texture2D = preload("res://assets/buttons/ally_base.png")
@export var charge_level_to_button_texture: Dictionary[int, Texture2D] = {
	0: default_texture,
	1: default_texture,
	2: default_texture,
	3: default_texture,
	4: default_texture,
}

func _ready():
	$TextureButton.texture_normal = charge_level_to_button_texture.get(charge_level, default_texture)

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
	can_afford = value >= charge_level_to_next_level_cost[charge_level]

func _on_texture_button_pressed():
	if can_afford:
		charge_upgrade_tile_pressed.emit(charge_level + 1, charge_level_to_next_level_cost[charge_level])
		charge_level += 1
		$TextureButton.texture_normal = charge_level_to_button_texture.get(charge_level)
