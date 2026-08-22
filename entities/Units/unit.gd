class_name Unit extends CharacterBody3D

@export_enum("ALLY", "ENEMY") var alignment := "ALLY"

@export_category("Node References")
@export var stats : UnitStats
@export var model : AnimatedCharacter
@export var health : Counter
@export var navigator : NavigationAgent3D
@export var line_of_sight : RayCast3D

## dictionary that keeps track of all currently active units based on their alignment
static var unit_list := {
	"ALLY" : [],
	"ENEMY" : []
}

var attacking := false
var time_alive := 0.0
var time_since_path_update := 0.0
var look_direction := Vector3.FORWARD
var path_location := self.position
var target_reached := false
var target : Unit	# enemy unit we are currently moving towards

func _ready() -> void:
	_bug_checker()
	_init_stats()
	_connect_signals()
	_update_targets()
	if alignment == "ALLY":
		_find_new_target("ENEMY")
	elif alignment == "ENEMY":
		_find_new_target("ALLY")

func _bug_checker() -> void:
	assert(stats)
	assert(model)
	assert(health)
	assert(navigator)

func _init_stats() -> void:
	health.max_value = stats.health
	health.reset()
	model.move_speed = stats.move_speed
	self.add_to_group(alignment)
	unit_list[alignment].append(self)

func _connect_signals() -> void:
	#hurtbox.hurt.connect(_on_hurtbox_hurt)
	health.value_empty.connect(_die)

func _update_targets() -> void:
	match alignment:
		"ALLY":
			for u in unit_list["ENEMY"]:
				u._find_new_target("ALLY")
		"ENEMY":
			for u in unit_list["ALLY"]:
				u._find_new_target("ENEMY")

# -------------
func hurt(attacker: Unit) -> void:
	if !is_instance_valid(attacker): return
	velocity *= Vector3(0.0, 1.0, 0.0)
	health.value -= attacker.stats.damage
func _on_hurtbox_hurt(hit : Hitbox) -> void:
	health.value -= hit.damage
	model.play_one_shot("HitReaction")

func _die() -> void:
	model.state = "Dead"
	unit_list[alignment].erase(self)
	_update_targets()
	queue_free()

# Nav mesh Stuff
func _find_new_target(unit_alignment : String) -> void:
	## unit that spawned/died shares our alignemnt, in which no need to do anything
	if unit_alignment == alignment:
		return
	var temp_sorted = unit_list[unit_alignment]	# we only need to create a temprary shallow array
	if len(temp_sorted) < 1:
		return
	temp_sorted.sort_custom(pos_sort)
	var closest_target = temp_sorted[0]
	
	target = closest_target

func update_target_location(target_pos : Vector3) -> void:
	navigator.target_position = target_pos

func _physics_process(delta: float) -> void:
	time_alive += delta
	time_since_path_update += delta
	
	if not is_on_floor():
		velocity.y += get_gravity().y
	
	# to let the spawn animation play out
	if time_alive <= 1.0:
		return
	
	if time_since_path_update >= 0.5:
		update_path()
	
	path_location = get_path_location()
	
	if _target_in_range() or target_reached:
		velocity = velocity.move_toward(Vector3.ZERO, stats.acceleration * delta)
		if is_instance_valid(target) and !attacking:
			look_direction = (target.global_position - self.global_position).normalized()
			attack()
	else:
		var move_dir := (path_location - self.global_position).normalized()
		look_direction = move_dir
		velocity = velocity.move_toward(move_dir * stats.move_speed, stats.acceleration * delta)
	
	global_rotation.y = lerp_angle(global_rotation.y, atan2(look_direction.x, look_direction.z), stats.acceleration * delta)
	
	if !flatten_vector(velocity).is_zero_approx():
		model.state = "Walking"
	else:
		model.state = "Idle"
	
	move_and_slide()

func update_path():
	time_since_path_update = 0.0
	if can_see_enemy(true): return
	
	if is_instance_valid(target) and navigator.target_position.distance_squared_to(target.global_position) >= 36.0:
		navigator.target_position = target.global_position

func get_path_location():
	if can_see_enemy(true):
		target_reached = _target_in_range()
		return target.position
	target_reached = navigator.is_target_reached()
	return navigator.get_next_path_position()

func can_see_enemy(override_target := false):
	if !line_of_sight or !is_instance_valid(target): return false
	line_of_sight.look_at(target.position, Vector3.UP, true)
	var colliding_with: Node3D = line_of_sight.get_collider()
	if is_instance_valid(colliding_with) and colliding_with is Unit and colliding_with.alignment != self.alignment:
		if override_target:
			target = colliding_with
		return colliding_with
	return false

# --- misc and utils
func attack() -> void:
	if attacking: return
	attacking = true
	model.play_one_shot("Attack")
	target.hurt(self)
	await model.attack_finished
	attacking = false

func pos_sort(a : Node3D, b : Node3D) -> bool:
	var da := a.global_position.distance_squared_to(self.global_position)
	var db := b.global_position.distance_squared_to(self.global_position)
	return da <= db

func flatten_vector(x: Vector3) -> Vector3:
	return x * Vector3(1.0, 0.0, 1.0)

func _target_in_range() -> bool:
	return self.global_position.distance_to(target.position) <= stats.attack_range if is_instance_valid(target) else false
