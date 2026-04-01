extends Node
class_name TrackSnapper

@export var use_acceleration : bool = true
@export var speed : float = 1.0
@export var strafe_speed : float = 0.5

@export var jump_velocity : float = 4.5

@export var brake_strength : float = 1.0/48.0

@export var pitch_speed : float = 3
var pitch_change : float = 0

@export var roll_speed : float = 3
var roll_change : float = 0

@export var rotate_speed: float = 3
var rotate_change : float = 0
var was_y_vel : float = 0

@export_category("Physics")
@export var gravity : float= 1.0/4.0
@export var raycasts : Array[RayCast3D]= []

@export var friction : float = 0.125/10

@export var ground_dist : float = 1 :
	set(new_val):
		ground_dist = new_val
		for raycast : RayCast3D in raycasts:
			raycast.target_position.y = -ground_dist


@export var adjustable_ground_distance : bool = false
@export var max_elevation : float = 3
var target_elevation : float 

var curr_boost_power : float = 0.0

func assign_raycasts(rays : Array[RayCast3D]):
	raycasts = rays
	for ray in raycasts:
		ray.target_position.y = -ground_dist


# https://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
func align_with_y(xfrom : Transform3D, newy : Vector3) ->  Transform3D:
	xfrom.basis.y = newy
	xfrom.basis.x = -xfrom.basis.z.cross(newy)
	xfrom.basis = xfrom.basis.orthonormalized()
	return(xfrom)

## Modifies global_transform and global_position and returns them as a tuple [Transform3D, Vector3]
func snap_to_track(global_transform : Transform3D, global_position : Vector3) -> Array:
	var n : Vector3 = Vector3(0,0,0)
	var count = 0
	var np : Vector3
	var dif : float = 0
	var look : Vector3 = Vector3(0,0,0)
	for ray in raycasts:
		ray.force_raycast_update()
		if (ray.is_colliding()):
			n += ray.get_collision_normal()
			count += 1

	if (is_raycast_colliding()):
		n /= count
		n = n.normalized()
		var xform = align_with_y(global_transform, n)
		global_transform = xform
		
		for ray in raycasts:
			ray.force_raycast_update()
			if (ray.is_colliding()):
				np = ray.get_collision_point()
				dif = ray.global_position.distance_to(global_position)
				look = ray.global_position.direction_to(global_position)
				break
		if np != null:
			global_position = np + look * dif + n * ground_dist
	return [global_transform, global_position]

func is_raycast_colliding() -> bool:
	for  ray in raycasts:
		if (ray.is_colliding()):
			return true
	return false

## (Theoretically) snaps a CharacterBody3D to a collisionshape. 
## [br]character_body : The body to snap
## [br]input_manager : The how to control the body
## [br]delta : delta time
func perform_snap(character_body : CharacterBody3D, acceleration : float, strafe : float, brake : float, rotation_change : float, pitch : float, roll : float, elevation : float, delta : float) -> void:
	if raycasts.size() == 0:
		push_error("There are no rays in the raycasts array for " + name+". Owner: " + owner.name + ". It is impossible for this node to snap. Disabling process.")
		set_physics_process(false)
	# Create temp velocity vector
	var vel : Vector3 = character_body.velocity
	
	var global_transform : Transform3D = character_body.global_transform
	var global_position : Vector3 = character_body.global_position
	
	if adjustable_ground_distance:
		#var elevation : float = 1 if input.is_action_just_pressed("ElevationUp") else -1 if input.is_action_just_pressed("ElevationDown") else 0 
		target_elevation += elevation
		if target_elevation < 1:
			target_elevation = 1
		elif target_elevation > max_elevation:
			target_elevation = max_elevation
		ground_dist = lerp(ground_dist, target_elevation, 0.25)
		
	# Snap the machine to the track
	var snapped_vars : Array = snap_to_track(global_transform, global_position)
	global_transform = snapped_vars[0]
	global_position = snapped_vars[1]
	
	# Get movement forces
	#if use_acceleration:
	vel += global_transform.basis.z * speed * (acceleration + curr_boost_power)
	vel += global_transform.basis.x * strafe_speed * strafe 
	

	# Brakes (Only on ground)
	if is_raycast_colliding():
		#DoBrake
		vel -= vel*brake_strength * brake
		
	# Get turning
	rotate_change = 0
	pitch_change = 0
	roll_change = 0
	rotate_change = rotate_speed * clamp(rotation_change,-1,1) * delta
	# Air controls
	if (!is_raycast_colliding()): pitch_change = pitch_speed * clamp(pitch,-1,1) * delta
	if (!is_raycast_colliding()): roll_change = -roll_speed * clamp(roll,-1,1) * delta
	
	# Apply rotation
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.y, rotate_change)
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.x, pitch_change)
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.z, roll_change)
	
	# Handle passive forces
	if !is_raycast_colliding():
		vel += Vector3(0, -1 * gravity, 0)
	else:
		was_y_vel = global_transform.basis.y.dot(vel)
		vel -= global_transform.basis.y*global_transform.basis.y.dot(vel) # Cancel downward movement
		vel += vel * (-1 * friction) # Friction force

	# Apply velocity
	character_body.global_transform = global_transform
	character_body.global_position = global_position
	character_body.velocity = vel
	character_body.move_and_slide()
	
func boost(boost_amount : float, boost_time : float = 1.0):
	curr_boost_power += boost_amount
	await get_tree().create_timer(boost_time).timeout
	curr_boost_power-=boost_amount
	pass
