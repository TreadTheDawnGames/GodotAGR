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

func any_input() -> bool:
	return(
	my_rotation != 0 or
	pitch != 0 or
	roll != 0 or
	strafe != 0 or
	elevation != 0 or
	acceleration != 0 or
	brake != 0 or
	fire_primary or
	fire_secondary
	)
