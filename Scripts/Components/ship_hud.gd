extends Control
class_name ShipHUD

@onready var physics_car_with_weapons: CarWithWeapons = $".."
@onready var damage_manager: DamageManager = %DamageManager

@onready var hitpoint_bar: ProgressBar = %HitpointBar
@onready var speed_label: Label = %SpeedLabel
@onready var lap_count: Label = %LapCountLabel
@onready var lap_time_label: Label = %LapTimeLabel



func setup(max_hitpoints : float):
	hitpoint_bar.max_value = max_hitpoints
	hitpoint_bar.value = max_hitpoints
	damage_manager.sig_damaged.connect(_update_hitpoints)
	physics_car_with_weapons.sig_processed.connect(_update_speed)
	lap_time_label.modulate.a = 0.0
	pass

func _update_hitpoints(_state : DamageManager.DamageState, hitpoints : float):
	hitpoint_bar.value = hitpoints
	pass

func _update_speed(speed : float):
	speed_label.text = "Speed: " + "%.2f" % max(0, round_to_step(speed))
	pass

## GPT
func round_to_step(value : float, step : float = 0.05) -> float:
	return round(value / step) * step
	
func show_completed_lap(new_lap_count : int):
	lap_count.text = "Laps: " + str(new_lap_count)
	pass

func show_lap_time():
	var tween : Tween = create_tween()
	tween.tween_property(lap_time_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(lap_time_label, "modulate:a", 0.0, 0.5).set_delay(2.0)
	
