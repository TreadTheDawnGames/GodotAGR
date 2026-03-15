#Translated from C#: https://github.com/Gravityhamster/Godot_AGR/blob/DevCas/CameraDampener.cs
extends Node3D
class_name CameraDampener

@export var lerp_speed : Vector3 = Vector3(0.25,0.25,0.25)
@export var ang_lerp_speed : Vector3 = Vector3(0.15,0.15,0.15)

@export var target_node_path : NodePath
var target_node : Node3D 

func _ready():
	target_node = get_node(target_node_path)
	if not target_node:
		printerr("No target node set.")

# TODO: Make lerp use delta
func _physics_process(_delta: float) -> void:
	var cam_pos : Vector3
	cam_pos.x = lerp(global_position.x, target_node.global_position.x, lerp_speed.x)
	cam_pos.y = lerp(global_position.y, target_node.global_position.y, lerp_speed.y)
	cam_pos.z = lerp(global_position.z, target_node.global_position.z, lerp_speed.z)
	
	var camera_rotation : Vector3 
	camera_rotation.x = lerp_angle(global_rotation.x, target_node.global_rotation.x, ang_lerp_speed.x)
	camera_rotation.y = lerp_angle(global_rotation.y, target_node.global_rotation.y, ang_lerp_speed.y)
	camera_rotation.z = lerp_angle(global_rotation.z, target_node.global_rotation.z, ang_lerp_speed.z)
	
	global_position = cam_pos
	global_rotation = camera_rotation
