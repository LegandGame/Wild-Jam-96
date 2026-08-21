@tool
class_name AnimatedCharacter extends Node3D

@export var animation_tree: AnimationTree

@export_enum("Idle", "Walking", "Dead") var state := "Idle":
	set(value):
		state = value
		if animation_tree:
			animation_tree.set("parameters/State/transition_request", state)

func play_one_shot(anim_name: String) -> void:
	animation_tree.set(str("parameters/", anim_name, "/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
