@tool
extends Node3D
class_name CheckpointGate
@onready var top: MeshInstance3D = %Top
@onready var top_checkered: MeshInstance3D = %TopCheckered

signal sig_car_crossed(car : CarBuiltInPhysics, gate : CheckpointGate)

@export var is_finish_line : bool = false

@onready var car_detector: Area3D = %CarDetector

@export var checkpoint_index : int = 0
var checkpoint_position_on_track : float = 0
@export var is_key_checkpoint : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top.visible = not is_finish_line
	top_checkered.visible = not top.visible
	if not Engine.is_editor_hint():
		car_detector.body_entered.connect(_on_body_entered)
	pass # Replace with function body.

func _on_body_entered(body : Node3D):
	if body is CarBuiltInPhysics:
		sig_car_crossed.emit(body as CarBuiltInPhysics, self)
