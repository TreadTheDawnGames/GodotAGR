@tool
extends Node3D
class_name Track

signal sig_lap_completed(car:CarBuiltInPhysics, lap_number:int) 

@onready var FLDR_checkpoints: Node3D = %Checkpoints
@onready var FLDR_start_pads: Node3D = %StartPads

@export var checkpoints : Array[CheckpointGate]
@export var start_pads : Array[StartPad]

var car_checkpoints : Dictionary[CarBuiltInPhysics, Array] = {} #Dict of CarBuiltInPhysics and Array[CheckpointGate]

var car_laps : Dictionary[CarBuiltInPhysics, int] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if checkpoints.size() == 0:
		for gate : CheckpointGate in FLDR_checkpoints.find_children("*", "CheckpointGate"):
			checkpoints.append(gate)
	if start_pads.size() == 0:
		for gate : StartPad in FLDR_start_pads.find_children("*", "StartPad"):
			start_pads.append(gate)
	for checkpoint : CheckpointGate in checkpoints:
		checkpoint.sig_car_crossed.connect(_handle_car_crossed)
		

func populate_arrays():
	checkpoints.clear()
	start_pads.clear()
	for gate : CheckpointGate in FLDR_checkpoints.find_children("*", "CheckpointGate"):
		checkpoints.append(gate)
	for gate : StartPad in FLDR_start_pads.find_children("*", "StartPad"):
		start_pads.append(gate)


func _handle_car_crossed(car : CarBuiltInPhysics, gate : CheckpointGate):
	car_checkpoints.get_or_add(car, [])
	if not car_checkpoints[car].has(gate):
		car_checkpoints[car].append(gate)
		
	if checkpoints.all(func(x): return car_checkpoints[car].has(x) and gate.is_finish_line):
		print("lap completed: " + str(car_checkpoints))
		car_laps.get_or_add(car, 0)
		car_laps[car] += 1
		car_checkpoints[car].clear()
		sig_lap_completed.emit(car, car_laps[car])
	pass

func fill_next_pad(car : CarBuiltInPhysics):
	var unfilled_pads : Array[StartPad] = start_pads.filter(func(a : StartPad): return not a.filled)
	if unfilled_pads.size()>0:
		unfilled_pads[0].fill_pad(car)
