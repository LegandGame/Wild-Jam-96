extends Node3D

func _on_charge_modified(value):
	$NavigationRegion3D/Terrain3D/castle_test/shield_visual.get_surface_override_material(0).set_shader_parameter("health", value / Constants.MAX_CHARGE)
