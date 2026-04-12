extends Node
class_name TrackEventSignaler

signal sig_lap_completed(new_lap_count : int)
signal sig_checkpoint_reached(checkpoint_index : int, is_key_checkpoint : bool)
signal sig_left_track


func update_laps(laps : int):
	sig_lap_completed.emit(laps)

func checkpoint_reached(index : int, is_key_checkpoint : bool):
	sig_checkpoint_reached.emit(index, is_key_checkpoint)
	pass

func lost_grip_on_track():
	sig_left_track.emit()
