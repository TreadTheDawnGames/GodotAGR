extends Node3D
class_name CarWeaponManager

@export var weapons : Array[CarWeapon] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame from scene root
func handle_weapons(delta : float, velocity : Vector3, input : DeviceInput):
	
	var targets_with_distance_away : Dictionary[Targetable3D, float]
	
	for target : Targetable3D in get_tree().get_nodes_in_group(&"Targetables"):
		if target.owner == owner: 
			continue
		var space_state = get_world_3d().direct_space_state
		# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters3D.create(global_position, target.global_position)
		var result = space_state.intersect_ray(query)
		if result:
			if (result["collider"] as Node).find_children("*", "Targetable3D", true, true).size() > 0:
				targets_with_distance_away.get_or_add(target, (global_position - (result["position"] as Vector3)).length())
		pass
	
	for weapon : CarWeapon in weapons:
		weapon.tick_weapon(delta, velocity, targets_with_distance_away)
	
	if input.is_action_pressed("FirePrimary"):
		if weapons.size() > 0:
			weapons[0].fire()
		pass
	if input.is_action_pressed("FireSecondary"):
		if weapons.size() > 1:
			weapons[1].fire()
		pass
	pass
