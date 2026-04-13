# Translated from C#: https://github.com/Gravityhamster/Godot_AGR/blob/main/CarBuiltInPhysics.cs
extends CharacterBody3D
class_name CarBuiltInPhysics

@export var c_input_manger: InputManager
@onready var c_track_snapper: TrackSnapper = %TrackSnapper
@onready var c_visual_part_of_car: CarVisuals = $VisualPartOfCar


var player_index : int = 0

var mesh : MeshInstance3D

func ensure_components():
	if not c_input_manger:
		c_input_manger = get_node("%InputManager_Player")
	if not c_track_snapper:
		c_track_snapper = get_node("%TrackSnapper")
	if not c_visual_part_of_car:
		c_visual_part_of_car = get_node("%VisualPartOfCar")
		

func ready_for_spawn(_player_index : int):
	player_index = _player_index
	ensure_components()
	
	var rays : Array[RayCast3D]
	for ray in get_children(true).filter(func(a:Node): return a is RayCast3D):
		rays.append(ray)
	c_track_snapper.assign_raycasts(rays)
	c_input_manger.set_input_device(PlayerManager.get_player_device(player_index))
	c_visual_part_of_car.setup(self)




func _physics_process(delta: float) -> void:
	# Cache the actual device index and check to make sure 
	#var actual_input_device : int = c_input_manger.device
	#if Input.get_connected_joypads().size() == 0:
		#c_input_manger.device = -1
	
	c_track_snapper.perform_snap(self, c_input_manger.acceleration, c_input_manger.strafe, c_input_manger.brake, c_input_manger.rotation_change, c_input_manger.pitch, c_input_manger.roll, c_input_manger.elevation, delta)
	
	#reset the input device
	#c_input_manger.input.device = actual_input_device
