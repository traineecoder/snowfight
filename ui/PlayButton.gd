extends TouchScreenButton



func _on_PlayButton_released() -> void:
	#print(Network.ip_address)
	get_tree().change_scene("res://ui/Menu.tscn")
