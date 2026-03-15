extends Node3D

@export var track_paths : Array[String] = [
	"res://Scenes/test_scene.tscn",
	"",
	"res://Scenes/Tracks/track2.tscn",
	"res://Scenes/Tracks/track3.tscn",
	]
var loading : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Debug-Reload"):
		get_tree().reload_current_scene();
		
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or loading: return
	
	if event.as_text().begins_with("Kp "):
		loading = true
		var parsed_num : int = int(event.as_text()[-1])
		if track_paths.size() >= parsed_num+1:
			if get_tree().change_scene_to_file(track_paths[parsed_num]) != OK:
				printerr("Unable to load scene: \"" + (track_paths[parsed_num] if track_paths[parsed_num] != "" else "[Empty Path]")  + "\"")
			else:
				print("Loading track: " + track_paths[parsed_num])
	pass
