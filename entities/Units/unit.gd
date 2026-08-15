class_name Unit extends CharacterBody3D

@export var stats : UnitStats
@export var model : Node3D
@export var health : Counter
@export var hurtbox : Hurtbox

func _ready() -> void:
	_init_stats()
	_connect_signals()

func _init_stats() -> void:
	health.max_value = stats.health
	health.reset()

func _connect_signals() -> void:
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	health.value_empty.connect(_die)

func _on_hurtbox_hurt(hitbox : Hitbox) -> void:
	health.value -= hitbox.damage

func _die() -> void:
	queue_free()
