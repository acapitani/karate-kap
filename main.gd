extends Node2D

#const FIRST_SCN = "res://scenes/scene_china.tscn"
#const MENU_SCN = "res://scenes/scene_china.tscn"

const FIRST_SCN = "res://scenes/start_menu/start_menu.tscn"
const MENU_SCN = "res://scenes/start_menu/start_menu.tscn"

func _ready():
	game.main = self
	#game.music = $music
	call_deferred( "_first_screen" )

func _first_screen():
	_load_scene( FIRST_SCN )

var load_state = 0
var cur_scn = ""
func _load_scene( scn ):
	print( "Loading level: ", scn, "   State: ", load_state )
	#print( game.gamestate )
	if load_state == 0:
		#get_tree().paused = true
		# set current scene
		cur_scn = scn
		# fade out
		$fade_layer/fadeanim.play( "fade_out" )
		load_state = 1
		$loadtimer.set_wait_time( 0.3 )
		$loadtimer.start()
	elif load_state == 1:
		# hide hud
		# $hud_layer/hud.hide()
		# clear current act
		var children = $levels.get_children()
		if not children.empty():
			_disconnect_level( children[0] )
			children[0].queue_free()
		load_state = 2
		$loadtimer.set_wait_time( 0.1 )
		$loadtimer.start()
	elif load_state == 2:
		# load new act
		var act = load( cur_scn ).instance()
		$levels.add_child( act )
		_connect_level( act )
		#if act is preload( "res://levels/level.gd" ):
		#	$hud_layer/hud.show()
		
		load_state = 3
		$loadtimer.set_wait_time( 0.1 )
		$loadtimer.start()
	elif load_state == 3:
		#show hud
		"""		
		if cur_scn != MENU_SCN:
			$hud_layer/hud.show()
			$hud_layer/mouse.show()
		else:
			$hud_layer/mouse.hide()
		#$hud_layer/hud.show()
		"""
		# fade in
		$fade_layer/fadeanim.play( "fade_in" )
		# play stuff
		load_state = 4
		$loadtimer.set_wait_time( 0.3 )
		$loadtimer.start()
		get_tree().paused = false
	elif load_state == 4:
		print( "finished loading" )
		load_state = 0

func update_hud():
	# $hud_layer/hud/coinmgr/coincount/coincount.text = "%d" % game.gamestate.coins
	#if game.gamestate.coins > oldcoins:
	#	oldcoins = game.gamestate.coins
		# $hud_layer/hud/coinget.play( "cycle" )
	pass
	

func _on_loadtimer_timeout():
	_load_scene( cur_scn )

func _connect_level( v ):
	v.connect( "restart_level", self, "_restart_level" )
	v.connect( "finished_level", self, "_finished_level" )
	v.connect( "game_over", self, "_game_over" )

func _disconnect_level( v ):
	v.disconnect( "restart_level", self, "_restart_level" )
	v.disconnect( "finished_level", self, "_finished_level" )
	v.disconnect( "game_over", self, "_game_over" )

func _restart_level():
	_load_scene( cur_scn )

func _finished_level( nxt_scn):
	_load_scene( nxt_scn )

func _game_over():
	print( cur_scn, " ", MENU_SCN )
	if cur_scn == MENU_SCN:
		get_tree().quit()
	else:
		_load_scene( MENU_SCN )
		
var mstate = 0
var curmusic = null
func play_music( res ):
	#print( " play music ", mstate )
	#print( curmusic, " ", res )
	match mstate:
		0:
			curmusic = res
			mstate = 1
			$music/musicfade.play( "fadeout" )
		1:
			#print( "STARTING MUSIC" )
			
			$music.stream = curmusic
			$music.play()
			$music/musicfade.play( "fadein" )
			mstate = 2
		2:
			mstate = 0


func _on_musicfade_animation_finished(anim_name):
	play_music( null )
