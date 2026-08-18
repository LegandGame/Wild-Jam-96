extends Node3D

@onready var camera_rotation_x: Node3D = $CameraRotationX
@onready var camera_zoom_pivot: Node3D = $CameraRotationX/CameraZoomPivot
@onready var camera_3d: Camera3D = $CameraRotationX/CameraZoomPivot/Camera3D

@export var move_speed : float = 10.0	# meters per second
@export var rotate_speed : float = 80.0		# degrees per second
@export var zoom_speed : float = 5.0
@onready var move_target : Vector3 = self.position
@onready var rotate_target : float = self.rotation_degrees.y
@onready var zoom_target : float = camera_3d.position.z

@export var min_zoom := -10.0
@export var max_zoom := 10.0

const SNAP : float = 0.4	# used for the lerp() function in _process()

func _process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up","move_down")
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var rot_input_dir := Input.get_axis("rotate_counter_clockwise", "rotate_clockwise")
	var zoom_input_dir := (int(Input.is_action_just_released("zoom_in")) - int(
							Input.is_action_just_pressed("zoom_out")))
	
	move_target += move_speed * move_dir * delta
	rotate_target += rot_input_dir * rotate_speed * delta
	zoom_target += zoom_input_dir * zoom_speed * delta
	zoom_target = clamp(zoom_target, min_zoom, max_zoom)
	
	position = lerp(position, move_target, SNAP)
	rotation_degrees.y = lerp(rotation_degrees.y, rotate_target, SNAP)
	camera_3d.position.z = lerp(camera_3d.position.z, zoom_target, SNAP)
