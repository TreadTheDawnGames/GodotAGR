@tool
extends Node3D
class_name CheckpointPlacer
@onready var checkpoints: Node3D = %Checkpoints
@export var do_placing : bool = false

const CHECKPOINT_GATE = preload("uid://cwc2c3lsm2dkt")

var is_mouse_down : bool = false

func _ready():
	if not Engine.is_editor_hint():
		queue_free()

func _process(_delta):
	if not Engine.is_editor_hint():
		return
	
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
		
		add_checkpoint(track_mesh.checkpoint_path_follower)
		
		print("thinging")
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_mouse_down = false

func add_checkpoint(checkpoint_path_follower : PathFollow3D):
	var new_checkpoint : CheckpointGate = CHECKPOINT_GATE.instantiate()
	new_checkpoint.global_position = checkpoint_path_follower.global_position
	new_checkpoint.rotation = checkpoint_path_follower.rotation
	if checkpoints.get_children().size() == 0:
		new_checkpoint.is_finish_line = true
	else:
		new_checkpoint.is_finish_line = false
	checkpoints.add_child(new_checkpoint)
	new_checkpoint.owner = get_tree().edited_scene_root
	pass
