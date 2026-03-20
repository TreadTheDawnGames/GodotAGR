extends Node3D
class_name CarWeaponManager

@export var weapons : Dictionary[StringName, CarWeapon] = {&"primary" : null, &"secondary" : null}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("child count: " + str(get_child_count()))
	if get_child_count() > 0:
		set_primary(get_child(0))
	if get_child_count() > 1:
		set_secondary(get_child(1))
		
	pass # Replace with function body.

# Called every frame from scene root
func handle_weapons(delta : float, velocity : Vector3, input_manager : InputManager):
	
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
	
	for weapon : CarWeapon in weapons.values():
		if weapon:
			weapon.tick_weapon(delta, velocity, targets_with_distance_away)
	
	if input_manager.fire_primary and weapons[&"primary"]:
		if weapons.size() > 0:
			weapons[&"primary"].fire()
		pass
	if input_manager.fire_secondary and weapons[&"secondary"]:
		if weapons.size() > 1:
			weapons[&"secondary"].fire()
		pass
	pass

func set_primary(weapon : CarWeapon):
	weapons[&"primary"] = weapon
	pass

func set_secondary(weapon : CarWeapon):
	weapons[&"secondary"] = weapon
	pass
