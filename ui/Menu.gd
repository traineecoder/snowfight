extends Control

onready var device_ip_address = $Device_ip
var _player_name = ""
var _ip_address = ""

func _ready() -> void:
	device_ip_address.text = Network.ip_address


func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_released(): # this doesn't care about IP typed.
	if _player_name == "": 
		return
	Network.create_server(_player_name)
	_load_game()

func _on_JoinButton_released():
	if _player_name == "" || _ip_address == "": # both IP and player name must be typed
		return
	Network.ip_address = _ip_address
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene('res://Game.tscn')


func _on_server_ip_text_changed(new_text: String) -> void:
	_ip_address = new_text
