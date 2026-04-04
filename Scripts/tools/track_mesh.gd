@tool
extends Node3D
class_name TrackMesh
@onready var track_path: Path3D = %TrackPath
@onready var checkpoint_path_follower: PathFollow3D = %CheckpointPathFollower

func _ready():
	checkpoint_path_follower = get_node("%CheckpointPathFollower")
	if not Engine.is_editor_hint():
		checkpoint_path_follower.queue_free()

#GPT
func set_to_nearest_point(global_pos: Vector3):
	var curve := track_path.curve
	var local_pos = track_path.to_local(global_pos)
	var offset = curve.get_closest_offset(local_pos)
	checkpoint_path_follower.progress = offset
	pass
