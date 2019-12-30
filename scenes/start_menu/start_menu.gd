extends "res://scenes/scene.gd"

var nxt_level = "res://scenes/scene_china.tscn"

func _ready():
	#if game.gamestate.cur_level.empty():
	#	$menu.unselectable_items.append( 1 )
	#game.play_music( 2 )
	pass
	
func _on_menu_selected_item( itemno ):
	match itemno:
		0:
			# 1P vs CPU
			print("player vs cpu")
			game.set_initial_gamestate()
			game.set_game_mode(game.MODE_1PVSCPU)
			emit_signal( "finished_level", nxt_level )
		1:
			# 1P vs 1P
			print("player vs player")
			game.set_initial_gamestate()
			game.set_game_mode(game.MODE_1PVS2P)
			emit_signal( "finished_level", nxt_level )
		2:
			# CPU vs CPU
			print("cpu vs cpu")
			game.set_initial_gamestate()
			game.set_game_mode(game.MODE_CPUVSCPU)
			emit_signal( "finished_level", nxt_level )
