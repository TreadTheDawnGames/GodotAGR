extends Node3D
class_name StartPad

@onready var spawn_position: Marker3D = %SpawnPosition
var filled : bool = false

func fill_pad(car : CarBuiltInPhysics):
	if not spawn_position:
		spawn_position = get_node("%SpawnPosition")

	car.global_position = spawn_position.global_position
	car.rotation = spawn_position.rotation
	filled = true
