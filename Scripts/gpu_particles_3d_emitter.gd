@tool
extends GPUParticles3D
class_name GPUParticles3DEmitter

signal sig_all_finished()

@export var is_one_shot : bool = true

@export_tool_button("Emit")
var emit_particles : Callable = func():
	emit(false)
	emit()

@export var emitters : Array[GPUParticles3D]

var my_emitting : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if emitters.size() == 0:
		emitters.assign(find_children("*", "GPUParticles3D", true, true))
			  
	one_shot = is_one_shot
	finished.connect(_check_all_finished)
	for emitter : GPUParticles3D in emitters:
		emitter.one_shot = is_one_shot
		emitter.finished.connect(_check_all_finished)
	
	pass # Replace with function body.

func emit(should_emit : bool = true):
	my_emitting = true
	emitting = should_emit
	for emitter : GPUParticles3D in emitters:
		emitter.emitting = should_emit

func _check_all_finished():
	print("checking for emission")
	var total_emitting : int = 1 if emitting else 0
	for emitter : GPUParticles3D in emitters:
		if emitter.emitting:
			total_emitting += 1
	if total_emitting == 0:
		sig_all_finished.emit()
		my_emitting = true
	print("emittors: " + str(total_emitting))
	
