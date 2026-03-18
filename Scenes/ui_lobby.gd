extends Control
const DEFAULT_TEXT : String = "Add Player"
const JOINING_TEXT : String = "Searching for Player"
const JOINED_TEXT : String = "Player %d joined"

@onready var bt_debug_button: Button = %Debug_button
@onready var bt_second_player_join: Button = %SecondPlayerJoin
@onready var vbox_current_players: VBoxContainer = %CurrentPlayers


enum JoinState {AWAY, JOINING, JOINED}

var player_joining : JoinState = JoinState.AWAY

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bt_second_player_join.pressed.connect(_on_second_player_join_pressed)
	bt_debug_button.pressed.connect(_debug_action)
	PlayerManager.sig_player_joined.connect(_on_player_joined)
	pass # Replace with function body.

func _on_second_player_join_pressed():
	if player_joining == JoinState.AWAY:
		player_joining = JoinState.JOINING
		bt_second_player_join.text = JOINING_TEXT

	elif player_joining == JoinState.JOINING:
		player_joining = JoinState.AWAY
		bt_second_player_join.text = DEFAULT_TEXT
	pass
	
func _input(event: InputEvent) -> void:
	if player_joining != JoinState.JOINING: return
	print("awaiting input")
	
	if PlayerManager.get_unjoined_devices().has(event.device):
		PlayerManager.join(event.device)
		

func _on_player_joined(player_index : int):
	player_joining = JoinState.JOINED
	bt_second_player_join.text = JOINED_TEXT % player_index
	await get_tree().create_timer(1).timeout
	player_joining = JoinState.AWAY
	bt_second_player_join.text = DEFAULT_TEXT
		
	
	var remove_button : Button = Button.new()
	remove_button.text = "Player " + str(player_index)
	remove_button.pressed.connect(func():
		PlayerManager.leave(player_index)
		remove_button.queue_free())
	remove_button.disabled = player_index == 0
	vbox_current_players.add_child(remove_button)
	
func _debug_action():
	pass
