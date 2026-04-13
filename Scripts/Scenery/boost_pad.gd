extends Node3D
@onready var detection_area: Area3D = %DetectionArea
@export var boost_power : float = 50.0
@export var boost_time : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(detected : Node3D):
	if detected is not CarBuiltInPhysics:
		return
	var car : CarBuiltInPhysics = detected as CarBuiltInPhysics
	car.c_track_snapper.boost(boost_power, boost_time)
