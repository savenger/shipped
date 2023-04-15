extends Node

var game_is_over : bool = false

var score : int = 0

func scored():
	score += 1
	get_node("/root/Game/HUD/Score").text = str(score)
