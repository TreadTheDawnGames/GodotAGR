extends Control

@onready var bt_second_player_join: Button = %SecondPlayerJoin
const DEFAULT_TEXT : String = "Add Player 2"
const JOINING_TEXT : String = "Searching for Player 2"
const JOINED_TEXT : String = "Player 2 joined"

enum JoinState {AWAY, JOINING, JOINED}

var player_2_joining : JoinState = JoinState.AWAY

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bt_second_player_join.pressed.connect(_on_second_player_join_pressed)
	pass # Replace with function body.

func _on_second_player_join_pressed():
	if player_2_joining == JoinState.AWAY:
		player_2_joining = JoinState.JOINING
		bt_second_player_join.text = JOINING_TEXT
	elif player_2_joining == JoinState.JOINED:
		PlayerManager.leave(1)
	pass
	
func _input(event: InputEvent) -> void:
	if player_2_joining != JoinState.JOINING: return
	
	if PlayerManager.get_unjoined_devices().has(event.device):
		PlayerManager.join(event.device)
		player_2_joining = JoinState.JOINED
		bt_second_player_join.text = JOINED_TEXT
	
		
	
	pass
