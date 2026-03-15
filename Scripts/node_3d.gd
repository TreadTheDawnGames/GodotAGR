extends Node3D
class_name CarWeapon

@onready var direction_marker_1: Marker3D = %DirectionMarker1
@onready var direction_marker_2: Marker3D = %DirectionMarker2

@export var cooldown : float = 0.1
var _cooldown_time : float = cooldown

@export var projectile : PackedScene

@export var spawn_positions : Array[Marker3D]
@export var amount : int = 1
@export var spread : float = 0.0:
	get():
		return spread*spread_strength
@export var spread_strength : float = 0.08

var velocity : Vector3

func tick_cooldown(delta : float, _velocity : Vector3):
	_cooldown_time = max(_cooldown_time - delta, 0)
	velocity = _velocity

func fire():
	if _cooldown_time <= 0:
		
		for i : int in amount:
			# I absolutely detest this implementation but it works so I'm rolling with it. 
			# Basically just gets the "forward" direction relative to the weapon. Rotation wasn't working because I don't know why. It's really annoying.
			var spread_vector : Vector3 = Vector3(direction_marker_2.global_position.x + randf_range(-spread, spread), direction_marker_2.global_position.y + randf_range(-spread, spread), direction_marker_2.global_position.z)
			var direction = direction_marker_1.global_position - (spread_vector)
			
			for marker : Marker3D in spawn_positions:
				var spawned_projectile : CarWeaponProjectile = projectile.instantiate()
				get_tree().current_scene.add_child(spawned_projectile)
				spawned_projectile.global_position = marker.global_position+direction
				print("velocity: " + str(velocity.normalized().z))
				spawned_projectile.speed += velocity.length()
				spawned_projectile.direction = direction.normalized()
			
		_cooldown_time = cooldown
	
	pass
