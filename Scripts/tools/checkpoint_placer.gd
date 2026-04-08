@tool
extends Node3D
class_name CheckpointPlacer
@onready var checkpoints: Node3D = %Checkpoints
@onready var start_pads: Node3D = %StartPads

@export_tool_button("Populate Track Vars") var pop_track : Callable = func(): (get_parent() as Track).populate_arrays()
@export var do_placing : bool = false 
@export var start_pad_distance_from_center : float = 5
@export var start_pad_distance_from_others : float = 10


const CHECKPOINT_GATE = preload("uid://cwc2c3lsm2dkt")
const START_PAD = preload("uid://blqmatuyy1tev")

var is_mouse_down : bool = false

func _ready():
	if not Engine.is_editor_hint():
		queue_free()

func _process(_delta):
	if not Engine.is_editor_hint():
		return
	do_placing = Input.is_key_pressed(KEY_C)
	if not do_placing:
		return
	
	var editor_viewport : Viewport = EditorInterface.get_editor_viewport_3d(0)
	var camera = editor_viewport.get_camera_3d()
	var mouse_pos = editor_viewport.get_mouse_position()
	# Get ray origin and direction from the 3D camera
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_position(mouse_pos, 1000)
	
	var world : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_direction)
	query.collide_with_bodies = true
	#DebugDraw3D.draw_points([ray_origin])
	var result = world.intersect_ray(query)
	var track_mesh : TrackMesh
	if result:
		var collider = result["collider"].get_parent()
		if collider.get_parent() is TrackMesh:
			track_mesh = collider.get_parent()
			track_mesh.set_to_nearest_point(result["position"])
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_mouse_down and result:
		is_mouse_down = true
		if do_placing:
			add_checkpoint(track_mesh.checkpoint_path_follower)
			set_checkpoint_indexes.call_deferred(track_mesh)
			
		print("thinging")
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_mouse_down = false

func add_checkpoint(checkpoint_path_follower : PathFollow3D):
	var new_checkpoint : CheckpointGate = CHECKPOINT_GATE.instantiate()
	if checkpoints.get_children().size() == 0:
		new_checkpoint.is_finish_line = true
		add_spawnpoints(checkpoint_path_follower)
	else:
		new_checkpoint.is_finish_line = false
	checkpoints.add_child(new_checkpoint)
	new_checkpoint.global_position = checkpoint_path_follower.global_position
	new_checkpoint.rotation = checkpoint_path_follower.rotation
	new_checkpoint.owner = get_tree().edited_scene_root
	pass

func set_checkpoint_indexes(track_mesh : TrackMesh):
	var sorted_checkpoints : Array[CheckpointGate] = []
	var first_checkpoint : CheckpointGate = null
	for checkpoint : CheckpointGate in checkpoints.find_children("*", "CheckpointGate"):
		sorted_checkpoints.append(checkpoint)
		if checkpoint.is_finish_line:
			first_checkpoint = checkpoint
		track_mesh.set_to_nearest_point(checkpoint.global_position)
		checkpoint.checkpoint_position_on_track = track_mesh.checkpoint_path_follower.progress
	sorted_checkpoints.sort_custom(func(a : CheckpointGate, b : CheckpointGate): 
		return a.checkpoint_position_on_track > b.checkpoint_position_on_track)
	var before_finish_line : Array[CheckpointGate] =  sorted_checkpoints.slice(0, sorted_checkpoints.find(first_checkpoint))
	var after_finish_line : Array[CheckpointGate] =  sorted_checkpoints.slice(sorted_checkpoints.find(first_checkpoint))
	after_finish_line.append_array(before_finish_line)
	sorted_checkpoints = after_finish_line
	
	for i : int in sorted_checkpoints.size():
		sorted_checkpoints[i].checkpoint_index = i
		
	pass

func add_spawnpoints(checkpoint_path_follower : PathFollow3D):
	for i : int in 8:
		var new_start_pad : StartPad = START_PAD.instantiate()
		start_pads.add_child(new_start_pad)
		checkpoint_path_follower.h_offset = start_pad_distance_from_center if i % 2==1 else start_pad_distance_from_center * -1
		checkpoint_path_follower.progress -= start_pad_distance_from_others
		new_start_pad.global_position = checkpoint_path_follower.global_position
		
		new_start_pad.rotation = checkpoint_path_follower.rotation
		new_start_pad.owner = get_tree().edited_scene_root
	checkpoint_path_follower.h_offset = 0
	
	pass
