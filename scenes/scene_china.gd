extends "res://scenes/scene.gd"

func _ready():
	call_deferred("_setup_players")
	call_deferred("gong")
	
func _setup_players():
	$player1.other_player = $player2
	$player2.other_player = $player1

func gong():
	$mplayer.mplay(preload("res://sfx/gong.wav"))
