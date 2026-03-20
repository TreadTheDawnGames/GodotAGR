# https://www.youtube.com/watch?v=mcIRppv80Dw
extends CharacterBody3D
class_name CarWeaponProjectile

@export var hitbox : ProjectileHitbox

@export var initial_speed : float = 240.0
@export var target_speed : float = 240.0
@export var acceleration : float = 0.0
@export var lifespan : float = 1.0

var speed : float = 0
var direction : Vector3 = Vector3.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = initial_speed
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	await get_tree().create_timer(lifespan).timeout
	await _before_lifespan_expired()
	queue_free()
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	speed = lerp(speed, target_speed, acceleration*delta)
	velocity = direction * speed * delta
	var collision = move_and_collide(velocity)
	if collision:
		queue_free()

func _before_lifespan_expired():
	pass

func _on_hitbox_area_entered(_area : Area3D):
	pass
