extends RigidBody3D
@onready var damage_manager: DamageManager = %DamageManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_manager.sig_next_damage_state.connect(destroy)
	pass # Replace with function body.


func destroy(damage_state : DamageManager.DamageState):
	if damage_state == DamageManager.DamageState.DEAD:
		queue_free()
