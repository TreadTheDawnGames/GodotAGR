extends Node3D
class_name CarWeaponManager

@export var weapons : Array[CarWeapon] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame from scene root
func handle_weapons(delta : float, velocity : Vector3):
	
	for weapon : CarWeapon in weapons:
		weapon.tick_cooldown(delta, velocity)
	
	if Input.is_action_pressed("FirePrimary"):
		if weapons.size() > 0:
			weapons[0].fire()
		pass
	if Input.is_action_pressed("FireSecondary"):
		if weapons.size() > 1:
			weapons[1].fire()
		pass
	pass
