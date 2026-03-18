extends Node3D
class_name CarWeapon

@onready var direction_marker_1: Marker3D = %DirectionMarker1
@onready var direction_marker_2: Marker3D = %DirectionMarker2

var _cooldown_time : float = cooldown

@export_group("Weapon Details")
@export var targeting_texture : Texture2D = preload("uid://bqtn0ysoidc1i")

@export_group("Weapon Armament")
## The packed scene that will be used as the bullet for this weapon.
@export var projectile : PackedScene
## How long between shots.
@export var cooldown : float = 0.1
## How many [code]Projectile[/code]s to spawn per shot.
@export var amount : int = 1
## An array containing all spawn positions. [code]amount[/code] number of [code]Projectile[/code]s will be spawned at each position.
@export var spawn_positions : Array[Marker3D]
## How much spread to have.
@export var spread : float = 0.0:
	get():
		return spread*spread_strength
## Strength of the spread.
@export var spread_strength : float = 0.08

## Whether [code]spawn_positions[/code] should take turns for each shot instead of firing all at once.
@export var alternate_shots : bool = false
#@export var shots_per_alternation : int = 1
var spawner_index : int = 0

## The range of this weapons auto-targeting.
@export var weapon_range : float = 50.0
@export_range(0, 180) var weapon_cone_degrees : float = 20
var curr_target : Targetable3D

# The current velocity of the car.
var velocity : Vector3

func tick_weapon(delta : float, _velocity : Vector3, targets : Dictionary[Targetable3D, float]):
	
	for target : Targetable3D in targets.keys():
		if targets[target] <= weapon_range and not curr_target:
			curr_target = target
			curr_target.targetable(self)
		elif targets[target] > weapon_range and target.targeter == self:
			target.targetable(null)
			curr_target = null
			
	_cooldown_time = max(_cooldown_time - delta, 0)
	velocity = _velocity

func fire():
	owner.reparent(get_tree().root.get_node("/root/SplitScreenRoot/GridContainer/SubViewportContainer2/SubViewport"))
	if _cooldown_time <= 0:
		for i : int in amount:
			# Gets the "forward" direction relative to the weapon and adjusts the position based on 

			if curr_target:
				var forward : Vector3 = (direction_marker_1.global_position- direction_marker_2.global_position).normalized()
				var direction_to_target : Vector3 = (curr_target.global_position - direction_marker_2.global_position).normalized()
				

				if forward.dot(direction_to_target) >= cos(deg_to_rad(weapon_cone_degrees)):
					direction_marker_1.look_at(curr_target.global_position)
				
			var spread_vector : Vector3 = Vector3(direction_marker_2.global_position.x + randf_range(-spread, spread), direction_marker_2.global_position.y + randf_range(-spread, spread), direction_marker_2.global_position.z)
			var direction = direction_marker_1.global_position - (spread_vector)

				
			if not alternate_shots:
				for marker : Marker3D in spawn_positions:
					_spawn_projectile(marker, direction)
			else:
				_spawn_projectile(spawn_positions[spawner_index], direction)
				spawner_index = wrap(spawner_index+1,0, spawn_positions.size())
				
			direction_marker_1.rotation = Vector3.ZERO
			
		_cooldown_time = cooldown
	
	pass

func _spawn_projectile(marker : Marker3D, direction : Vector3):
	var spawned_projectile : CarWeaponProjectile = projectile.instantiate()
	get_tree().current_scene.add_child(spawned_projectile)
	spawned_projectile.global_position = marker.global_position + direction
	spawned_projectile.speed += velocity.length()
	spawned_projectile.direction = direction.normalized()
