# Translated from C#: https://github.com/Gravityhamster/Godot_AGR/blob/main/CarBuiltInPhysics.cs
extends CharacterBody3D
class_name CarBuiltInPhysics


@export var input_device_index : int = 0
var input : DeviceInput

@export_category("Car stats")
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
var raycasts : Array[RayCast3D]= []

@export var friction : float = 0.125/10

@export var ground_dist : float = 1 :
	set(new_val):
		ground_dist = new_val
		for raycast : RayCast3D in raycasts:
			raycast.target_position.y = -ground_dist


@export var adjustable_ground_distance : bool = false
@export var max_elevation : float = 3


var mesh : MeshInstance3D

# https://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
func align_with_y(xfrom : Transform3D, newy : Vector3) ->  Transform3D:
	xfrom.basis.y = newy
	xfrom.basis.x = -xfrom.basis.z.cross(newy)
	xfrom.basis = xfrom.basis.orthonormalized()
	return(xfrom)

func snap_to_track() -> void:
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

func _ready():
	for child : RayCast3D in get_children(true).filter(func(a:Node): return a is RayCast3D):
		raycasts.append(child)
		child.target_position.y = -ground_dist

func set_input_device(device_index : int):
	input = DeviceInput.new(device_index)
	pass

func is_raycast_colliding() -> bool:
	for  ray in raycasts:
		if (ray.is_colliding()):
			return true
	return false

var target_elevation : float 

func _physics_process(delta: float) -> void:
	input.is_known()
	# Create temp velocity vector
	var vel : Vector3 = velocity
	# Get inputs
	var my_rotation : float = input.get_action_strength("Left") - input.get_action_strength("Right")
	var pitch : float = input.get_action_strength("PitchUp") - input.get_action_strength("PitchDown")
	var roll : float = input.get_action_strength("RollLeft") - input.get_action_strength("RollRight")
	var strafe : float = input.get_action_strength("StrafeLeft") - input.get_action_strength("StrafeRight")
	
	
	if adjustable_ground_distance:
		var elevation : float = 1 if input.is_action_just_pressed("ElevationUp") else -1 if input.is_action_just_pressed("ElevationDown") else 0 
		target_elevation += elevation
		if target_elevation < 1:
			target_elevation = 1
		elif target_elevation > max_elevation:
			target_elevation = max_elevation
		ground_dist = lerp(ground_dist, target_elevation, 0.25)
		
	
	
	
	# Snap the machine to the track
	snap_to_track()
	
	# Get movement forces
	vel += global_transform.basis.z * speed *  input.get_action_strength("Forward") 
	vel += global_transform.basis.x * strafe_speed * strafe 
	
	# Brakes (Only on ground)
	if is_raycast_colliding():
		#DoBrake
		vel -= vel*brake_strength * input.get_action_strength("Brake")
		
	# Get turning
	rotate_change = 0
	pitch_change = 0
	roll_change = 0
	rotate_change = rotate_speed * clamp(my_rotation,-1,1) * delta
	
	# Air controls
	if (!is_raycast_colliding()): pitch_change = pitch_speed * clamp(pitch,-1,1) * delta
	if (!is_raycast_colliding()): roll_change = -roll_speed * clamp(roll,-1,1) * delta
	
	# Apply rotation
	rotate(global_transform.basis.y, rotate_change)
	rotate(global_transform.basis.x, pitch_change)
	rotate(global_transform.basis.z, roll_change)
	
	# Handle passive forces
	if !is_raycast_colliding():
		vel += Vector3(0, -1 * gravity, 0)
	else:
		was_y_vel = global_transform.basis.y.dot(vel)
		vel -= global_transform.basis.y*global_transform.basis.y.dot(vel) # Cancel downward movement
		vel += vel * (-1 * friction) # Friction force

	# Apply velocity
	velocity = vel
	# Get updated ray cast information
	move_and_slide()
