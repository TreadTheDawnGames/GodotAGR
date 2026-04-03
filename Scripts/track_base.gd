extends Node3D
class_name Track

@onready var FLDR_checkpoints: Node3D = %Checkpoints

@export var checkpoints : Array[CheckpointGate] = []

var car_checkpoints : Dictionary[CarBuiltInPhysics, Array] = {} #Dict of CarBuiltInPhysics and Array[CheckpointGate]

var car_laps : Dictionary[CarBuiltInPhysics, int] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if checkpoints.size() == 0:
		for gate : CheckpointGate in FLDR_checkpoints.find_children("*", "CheckpointGate"):
			checkpoints.append(gate)
			gate.sig_car_crossed.connect(_handle_car_crossed)

func _handle_car_crossed(car : CarBuiltInPhysics, gate : CheckpointGate):
	car_checkpoints.get_or_add(car, [])
	
	if not car_checkpoints[car].has(gate):
		car_checkpoints[car].append(gate)
		
	if checkpoints.all(func(x): return car_checkpoints[car].has(x) and gate.is_finish_line):
		print("lap completed: " + str(car_checkpoints))
		car_laps.get_or_add(car, 0)
		car_laps[car] += 1
		car_checkpoints[car].clear()
		
	pass
