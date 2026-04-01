extends Node
class_name DamageManager

## The maximum number of hitpoints the damage manager can have
@export var max_hitpoints : float = 50.0

## The hurtbox this manager uses to determine whether it was hit
@export var hurtbox : Area3D

## The number of hitpoints the damage manager currently has
var curr_hitpoints : float = 50.0:
	set(new_val):
		
		var new_damage_state = int((1-clamp((new_val/max_hitpoints),0.0,1.0)) * (DamageState.keys().size()-1)) as DamageState
		
		if new_damage_state!=curr_damage_state:
			curr_damage_state = new_damage_state
			sig_next_damage_state.emit(curr_damage_state)
		
		print("hitpoints: " + str(new_val) + "curr state: " + str(DamageState.keys()[curr_damage_state]))
		curr_hitpoints = new_val
		return curr_hitpoints

## The the percentage of hitpoints that must be taken before the next damage state signal is emitted.
enum DamageState {FULL, HEALED, DAMAGED, TEETERING, DEAD}
var curr_damage_state : DamageState = DamageState.FULL

signal sig_damaged(damage_state : DamageState, hitpoints : float)
signal sig_next_damage_state(damage_state : DamageState)

func _ready():
	assert(hurtbox != null, "Hurtbox is not set. DamageManager will not work.")
	hurtbox.area_entered.connect(_projectile_detected)
	pass

# 
func take_damage(amount : float):
	curr_hitpoints -= amount
	sig_damaged.emit(curr_damage_state, curr_hitpoints)

func set_hitpoints(amount : float):
	curr_hitpoints = amount
	sig_damaged.emit(curr_damage_state, curr_hitpoints)

func reset_hitpoints():
	curr_hitpoints = max_hitpoints
	sig_damaged.emit(curr_damage_state, curr_hitpoints)

func _projectile_detected(area : Area3D):
	if area is not ProjectileHitbox:
		push_warning("Detected area is not a projectile.")
		return
	var projectile : ProjectileHitbox = area as ProjectileHitbox
	take_damage(projectile.damage)
