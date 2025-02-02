extends "res://scenes/scene.gd"

func _ready():
	call_deferred("_setup_players")
	call_deferred("gong")
	
func _setup_players():
	$player1.other_player = $player2
	$player2.other_player = $player1
	if game.game_mode==game.MODE_1PVSCPU:
		$player1.player_num = 1
		$player2.player_num = 0
	elif game.game_mode==game.MODE_1PVS2P:
		$player1.player_num = 1
		$player2.player_num = 2
	elif game.game_mode==game.MODE_CPUVSCPU:
		$player1.player_num = -1
		$player2.player_num = 0

func gong():
	$mplayer.mplay(preload("res://sfx/gong.wav"))
