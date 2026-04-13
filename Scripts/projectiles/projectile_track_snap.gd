extends CarWeaponProjectile
class_name CarWeaponProjectile_TrackFollow

@onready var track_snapper: TrackSnapper = $TrackSnapper

#func _ready() -> void:
func setup(up : Vector3):
	track_snapper.speed = initial_speed
	transform.basis = Basis.looking_at(-direction, up)
	track_snapper.assign_raycasts([%RayCast3D])
	velocity = direction.normalized() * initial_speed
	super.setup(up)

func _physics_process(delta: float) -> void:
	
	if track_snapper.perform_snap(self, 1, 0, 0, 0, 0, 0, 0, delta):
		queue_free()

	pass

func _on_hitbox_area_entered(_area : Area3D):
	queue_free()
