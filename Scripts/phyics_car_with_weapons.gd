extends CarBuiltInPhysics
class_name CarWithWeapons

@export var weapons_manager : CarWeaponManager

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	weapons_manager.handle_weapons.call_deferred(delta, velocity, c_input_manger)
