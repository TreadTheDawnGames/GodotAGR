extends CarWeaponProjectile
class_name CarWeaponProjectile_TrackFollow

@onready var track_snapper: TrackSnapper = $TrackSnapper

func _ready() -> void:
	
	transform.basis = Basis.looking_at(-direction, Vector3.UP)
	track_snapper.assign_raycasts([%RayCast3D])
	super._ready()

func _physics_process(delta: float) -> void:
	
	track_snapper.perform_snap(self, 1, 0, 0, 0, 0, 0, 0, delta)
	
	pass

func _on_hitbox_area_entered(_area : Area3D):
	queue_free()
