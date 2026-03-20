# Translated from C#: https://github.com/Gravityhamster/Godot_AGR/blob/DevEthan/visual_part_of_car.cs
extends MeshInstance3D
@export var ship_model: Node3D

@export var mycar :  CarBuiltInPhysics

@export var interpolation_rigidness : float = 5.0
@export var interpolation_rigidness_pitch : float = 10.0

@export var strafe_visual_speed : float = 15

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var xform : Transform3D = mycar.global_transform
	
	
	xform = xform.rotated(xform.basis.x, (float)(90 * (PI  / 180)))
	global_transform = global_transform.interpolate_with(xform, (interpolation_rigidness * delta))
	global_position = mycar.global_position
	rotate(global_transform.basis.z, -mycar.c_track_snapper.rotate_change)
	
	ship_model.rotation.y = lerp(ship_model.rotation.y, Input.get_axis("StrafeLeft","StrafeRight")/interpolation_rigidness, delta * strafe_visual_speed)
	ship_model.rotation.x = lerp(ship_model.rotation.x, Input.get_axis("PitchDown","PitchUp")/interpolation_rigidness_pitch, delta * strafe_visual_speed)
