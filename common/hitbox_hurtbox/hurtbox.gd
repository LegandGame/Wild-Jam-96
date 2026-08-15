class_name Hurtbox extends Area3D

@export var invuln_time : float = 1.0
@onready var cur_invuln_time : float = invuln_time
var _is_invuln : bool = false

signal hurt(hitbox : Hitbox)

## Called by Hitbox3D
func take_hit(hitbox : Hitbox) -> void:
	hurt.emit(hitbox)
	_is_invuln = true

func _process(delta: float) -> void:
	if _is_invuln:
		cur_invuln_time -= delta
		if cur_invuln_time <= 0.0:
			_is_invuln = false
			cur_invuln_time = invuln_time
