class_name Unit extends CharacterBody3D

@export_category("Node References")
@export var stats : UnitStats
@export var model : Node3D
@export var health : Counter
@export var hurtbox : Hurtbox
@export var navigator : NavigationAgent3D

## dictionary that keeps track of all currently active units based on their alignment
static var unit_list := {
	"ALLY" : [],
	"ENEMY" : []
}

func _ready() -> void:
	_bug_checker()
	_init_stats()
	_connect_signals()
	_update_targets()
	if stats.alignment == "ALLY":
		_find_new_target("ENEMY")
	elif stats.alignment == "ENEMY":
		_find_new_target("ALLY")

func _bug_checker() -> void:
	assert(stats)
	assert(model)
	assert(health)
	assert(hurtbox)
	assert(navigator)

func _init_stats() -> void:
	health.max_value = stats.health
	health.reset()
	self.add_to_group(stats.alignment)
	unit_list[stats.alignment].append(self)

func _connect_signals() -> void:
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	health.value_empty.connect(_die)

func _update_targets() -> void:
	match stats.alignment:
		"ALLY":
			for u in unit_list["ENEMY"]:
				u._find_new_target("ALLY")
		"ENEMY":
			for u in unit_list["ALLY"]:
				u._find_new_target("ENEMY")

# -------------
func _on_hurtbox_hurt(hitbox : Hitbox) -> void:
	health.value -= hitbox.damage

func _die() -> void:
	unit_list[stats.alignment].erase(self)
	_update_targets()
	queue_free()

# Nav mesh Stuff
func _find_new_target(unit_alignment : String) -> void:
	## unit that spawned/died shares our alignemnt, in which no need to do anything
	print("Alignment Check: ", stats.alignment, " ", unit_alignment, " ", self)
	if unit_alignment == stats.alignment:
		return
	var temp_sorted = unit_list[unit_alignment]	# we only need to create a temprary shallow array
	if len(temp_sorted) < 1:
		return
	temp_sorted.sort_custom(pos_sort)
	var closest_target = temp_sorted[0]
	
	navigator.target_position = closest_target.position

func update_target_location(target_pos : Vector3) -> void:
	navigator.target_position = target_pos

func _physics_process(delta: float) -> void:
	var cur_location := global_transform.origin
	var next_location := navigator.get_next_path_position()
	var move_dir := (next_location - cur_location).normalized()
	velocity = velocity.move_toward(move_dir * stats.move_speed, stats.ACCEL * delta)
	
	if not is_on_floor():
		velocity.y += get_gravity().y
	
	move_and_slide()

# --- misc and utils
func pos_sort(a : Node3D, b : Node3D) -> bool:
	var da := a.global_position.distance_squared_to(self.global_position)
	var db := b.global_position.distance_squared_to(self.global_position)
	return da <= db
