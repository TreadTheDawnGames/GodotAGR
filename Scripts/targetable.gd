extends Node3D
class_name Targetable3D

@onready var sprite_3d: Sprite3D = %Sprite3D

var targeter : CarWeapon = null

func _ready():
	add_to_group(&"Targetables")
	targetable(null)

func targetable(_targeter : CarWeapon):
	sprite_3d.visible = _targeter != null
	
	if targeter and _targeter != targeter:
		targeter.curr_target = null
		pass
	targeter = weakref(_targeter).get_ref()
	if targeter:
		sprite_3d.texture = targeter.targeting_texture
	
