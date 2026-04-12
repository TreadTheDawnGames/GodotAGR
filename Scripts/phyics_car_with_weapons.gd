extends CarBuiltInPhysics
class_name CarWithWeapons

signal sig_processed(speed : float) 

@export var  c_weapons_manager : CarWeaponManager
@onready var c_damage_manager: DamageManager = %DamageManager
#@onready var c_track_snapper: TrackSnapper = %TrackSnapper
@export var hitpoints : float = 50.0
@onready var c_ship_hud: ShipHUD = $ShipHud

func _ready() -> void:
	c_damage_manager.max_hitpoints = hitpoints
	c_ship_hud.setup(hitpoints)
	
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	c_weapons_manager.handle_weapons.call_deferred(delta, velocity, c_input_manger)
	sig_processed.emit(velocity.dot(transform.basis.z)) 

func _on_sig_lap_completed(new_lap_count : int):
	c_ship_hud.show_completed_lap(new_lap_count)

func _on_sig_checkpoint_reached(checkpoint_index : int, is_key_checkpoint : bool):
	if is_key_checkpoint:
		c_ship_hud.show_lap_time()
