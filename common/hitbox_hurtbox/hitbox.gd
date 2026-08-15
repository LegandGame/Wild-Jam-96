class_name Hitbox extends Area3D
## the one doing the hitting. set the Layer

@export var damage : int = 1
@export var cooldown : float = 0.2		## in seconds
@onready var cur_cooldown : float = cooldown
var _on_cooldown : bool = false

signal hit(hurtbox : Hurtbox)

func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area : Node3D) -> void:
	if area is not Hurtbox:
		return
	var hurtbox : Hurtbox = area as Hurtbox
	if hurtbox._is_invuln or _on_cooldown:
		return
	
	hit.emit(area)
	hurtbox.take_hit(self)
	_on_cooldown = true

func _process(delta: float) -> void:
	if _on_cooldown:
		cur_cooldown -= delta
		if cur_cooldown <= 0.0:
			_on_cooldown = false
			cur_cooldown = cooldown
