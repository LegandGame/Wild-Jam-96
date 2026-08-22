@tool
class_name AnimatedCharacter extends Node3D

signal attack_finished

@export var animation_tree: AnimationTree:
	set(value):
		animation_tree = value
		animation_tree.animation_finished.connect(_on_anim_finished)
		animation_tree.set("parameters/State/transition_request", state)

@export var move_speed := 1.0:
	set(value):
		move_speed = value
		if animation_tree:
			animation_tree.set("parameters/MoveSpeed/scale", move_speed * speed_scale)

@export var speed_scale := 0.15:
	set(value):
		speed_scale = value
		if animation_tree:
			animation_tree.set("parameters/MoveSpeed/scale", move_speed * speed_scale)

@export_enum("Idle", "Walking", "Dead") var state := "Idle":
	set(value):
		state = value
		if animation_tree:
			animation_tree.set("parameters/State/transition_request", state)

func play_one_shot(anim_name: String) -> void:
	animation_tree.set(str("parameters/", anim_name, "/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		attack_finished.emit()
