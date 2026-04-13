extends Node
class_name DamageManager

## The maximum number of hitpoints the damage manager can have
@export var max_hitpoints : float = 50.0

## The hurtbox this manager uses to determine whether it was hit
@export var hurtbox : Area3D

## The amount of time (in seconds) you must not take damage in order to start healing
@export var regen_time : float = 5.0
## How fast your health regenerates.
@export var regen_rate : float = 0.2
var regen_timer : Timer

@export var impact_damage_rate : float = 0.01
@export var damage_rate : float = 0.001

## The number of hitpoints the damage manager currently has
var curr_hitpoints : float = 50.0:
	set(new_val):
		
		var new_damage_state = int((1-clamp((new_val/max_hitpoints),0.0,1.0)) * (DamageState.keys().size()-1)) as DamageState
		
		if new_damage_state!=curr_damage_state:
			curr_damage_state = new_damage_state
			sig_next_damage_state.emit(curr_damage_state)
		
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
	hurtbox.body_entered.connect(func(n): 
		if n is StaticBody3D:
			take_damage(get_parent().velocity.length()*impact_damage_rate))
	regen_timer = Timer.new()
	add_child(regen_timer)
	regen_timer.one_shot = true
	regen_timer.wait_time = regen_time
	
func _physics_process(_delta: float) -> void:
	if hurtbox.get_overlapping_bodies().filter(func(n): return n is StaticBody3D).size() > 0 and get_parent().velocity.length() > 0.1:
		take_damage(get_parent().velocity.length() * damage_rate)
		pass
	else:
		if curr_hitpoints < max_hitpoints and regen_timer.time_left == 0:
			heal_damage(1*regen_rate)

func take_damage(amount : float):
	curr_hitpoints = clamp(curr_hitpoints - amount, 0.0, max_hitpoints)
	sig_damaged.emit(curr_damage_state, curr_hitpoints)
	regen_timer.wait_time = regen_time
	regen_timer.start()

func heal_damage(amount : float):
	curr_hitpoints = clamp(curr_hitpoints + amount, 0.0, max_hitpoints)
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
	if projectile.my_owner == owner:
		#Skip if I shot this projectile
		return
	take_damage(projectile.damage)
