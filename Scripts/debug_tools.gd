extends Node3D

@export var track_paths : Array[String] = [
	"res://Scenes/gym.tscn",
	"res://Scenes/Tracks/track3.tscn",
	]

@export var CAR : PackedScene = preload("uid://uhlj08qhmfqr")

@export var first_player_viewport : Node
@export var loaded_track : Track

@export var spawn_position : Marker3D

var loading : bool = false

@onready var curr_screens: GridContainer = %Screens
var viewport_associations : Dictionary[int, SubViewportContainer] = {}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Debug-Reload"):
		get_tree().reload_current_scene();
		
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	curr_screens.child_order_changed.connect(_update_screen_sizes)
	
	PlayerManager.sig_player_joined.connect(_spawn_ship)
	PlayerManager.sig_player_left.connect(_remove_player)
	await get_tree().create_timer(0.1).timeout
	PlayerManager.join(-1)
	pass # Replace with function body.

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

func _spawn_ship(player_index : int):
	var car : CarWithWeapons = CAR.instantiate()
	if spawn_position:
		car.global_position = spawn_position.global_position
	
	car.ready_for_spawn(player_index)
	var car_viewport : SubViewportContainer = curr_screens.get_child(0)
	if player_index == 0:
		first_player_viewport.add_child(car)
	else:
		car_viewport = _add_viewport(car)
	loaded_track.fill_next_pad(car)
	
	viewport_associations.get_or_add(player_index, car_viewport)
	
	pass

func _remove_player(player_index : int):
	if viewport_associations.has(player_index):
		viewport_associations[player_index].queue_free()
		viewport_associations.erase(player_index)
		
	pass

#https://www.youtube.com/watch?v=V7eXQhqPt2Y
func _add_viewport(for_car : CarBuiltInPhysics) -> SubViewportContainer:
	var new_viewportcontainer : SubViewportContainer = SubViewportContainer.new()
	var new_subviewport : SubViewport = SubViewport.new()
	var new_label : Label = Label.new()
	
	new_label.text = str(for_car.player_index)
	new_label.add_theme_font_size_override("normal", 50)
	
	new_subviewport.add_child(for_car)
	new_viewportcontainer.add_child(new_subviewport)
	new_viewportcontainer.add_child(new_label)
	curr_screens.add_child(new_viewportcontainer)
	
	print("(viewport) Child count : " + str(curr_screens.get_child_count()))
	
	_update_screen_sizes()
	return new_viewportcontainer

#https://www.youtube.com/watch?v=V7eXQhqPt2Y
func _update_screen_sizes():
	@warning_ignore("integer_division")
	curr_screens.columns = ceil(curr_screens.get_child_count()/2.0)
	print("(screen sizes) Child count : " + str(curr_screens.get_child_count()))
	for viewport_viewer in curr_screens.get_children():
		var viewport : SubViewport = viewport_viewer.get_child(0)
		var viewport_size : Vector2 = get_viewport().get_visible_rect().size
		@warning_ignore("narrowing_conversion")
		viewport.size.x = viewport_size.x/curr_screens.columns
		viewport.size.y = viewport_size.y/ceil(float(curr_screens.get_child_count()/float(curr_screens.columns)))
		
	pass
