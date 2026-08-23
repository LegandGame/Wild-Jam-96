extends Unit

var charge_manager : ChargeManager
var drain_rate := 1.0
var units_overlayed : int = 0
@onready var area_3d: Area3D = $Area3D


func _ready() -> void:
	alignment = "ALLY"
	unit_list["ALLY"].append(self)
	charge_manager = get_tree().get_first_node_in_group("charge_manager")
	self.add_to_group("ALLY")
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func hurt(attacker: Unit) -> void:
	if not is_instance_valid(attacker):
		return
	charge_manager._on_shield_attack(attacker.stats.damage)

func _on_body_entered(body : Node3D) -> void:
	if body is not Unit:
		return
	body = body as Unit
	if body.alignment != "ENEMY":
		return
	units_overlayed += 1
func _on_body_exited(body : Node3D) -> void:
	if body is not Unit:
		return
	body = body as Unit
	if body.alignment != "ENEMY":
		return
	units_overlayed -= 1

func _physics_process(delta: float) -> void:
	if units_overlayed >= 1:
		charge_manager._on_shield_attack(units_overlayed * drain_rate * delta)

func _on_clear_damage_increase():
	drain_rate += 0.5

func _on_clear_damage_reset():
	drain_rate = 1.0
