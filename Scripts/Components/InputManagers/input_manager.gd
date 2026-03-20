extends Node
class_name InputManager

@export var device : int = 0
var input : DeviceInput

@export var my_rotation : float = 0.0
@export var pitch : float = 0.0
@export var roll : float = 0.0
@export var strafe : float = 0.0
@export var elevation : float = 0.0
@export var acceleration : float = 0.0
@export var brake : float = 0.0
@export var fire_primary : bool = false
@export var fire_secondary : bool = false

func set_input_device(device_index : int):
	input = DeviceInput.new(device_index)
