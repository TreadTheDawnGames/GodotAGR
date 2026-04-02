extends Node3D
class_name CheckpointGate

signal sig_car_crossed(car : CarBuiltInPhysics, gate : CheckpointGate)

@onready var car_detector: Area3D = %CarDetector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car_detector.body_entered.connect(_on_body_entered)
	pass # Replace with function body.

func _on_body_entered(body : Node3D):
	if body is CarBuiltInPhysics:
		sig_car_crossed.emit(body as CarBuiltInPhysics, self)
