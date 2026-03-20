extends InputManager
class_name InputManager_Player

func _physics_process(_delta: float) -> void:
	my_rotation = input.get_action_strength("Left") - input.get_action_strength("Right")
	pitch = input.get_action_strength("PitchUp") - input.get_action_strength("PitchDown")
	roll = input.get_action_strength("RollLeft") - input.get_action_strength("RollRight")
	strafe = input.get_action_strength("StrafeLeft") - input.get_action_strength("StrafeRight")
	elevation = 1 if input.is_action_just_pressed("ElevationUp") else -1 if input.is_action_just_pressed("ElevationDown") else 0 
	acceleration = input.get_action_strength("Forward")
	brake = input.get_action_strength("Brake")
	fire_primary = input.is_action_pressed("FirePrimary")
	fire_secondary = input.is_action_pressed("FireSecondary")
