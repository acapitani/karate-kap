extends Node


#enum CONTROL_TYPE { CONTROL_MOUSE, CONTROL_GAMEPAD }
const CONTROL_GAMEPAD = 1
const GRAVITY = 1500
const TERMINAL_VELOCITY = 220
const FLOOR_Y = 142
const LIMIT_LEFT = 20
const LIMIT_RIGHT = 300

var player = null setget _set_player, _get_player
var main = null
var gamestate setget _set_gamestate
#===========================
func _set_player( v ):
	player = weakref( v )
func _get_player():
	if player == null: return null
	return player.get_ref()
#===========================
func set_initial_gamestate():
	gamestate = {
		"cur_scene": ""
		}
func _set_gamestate( v ):
	gamestate = v
	if main != null:
		main.update_hud()
#===========================


func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.pause_mode = PAUSE_MODE_PROCESS
	set_initial_gamestate()
	Engine.set_target_fps(Engine.get_iterations_per_second())

var songs = [preload( "res://music/titlesong.ogg" )]

var cursong = -1
func play_music( no ):
	if main == null: return
	if no == cursong: return
	cursong = no
	main.play_music( songs[no] )

#func _process(delta):
#	if Input.is_action_pressed( "btn_quit" ):
#		get_tree().quit()




#enum SFX { \
#		SFX_PLAYER_SHOOT_1, \
#		SFX_EXPLOSION_SMALL }
#const SFXS = [ \
#		preload( "res://sfx/player_shoot_1.wav" ), \
#		preload( "res://sfx/explosion_small.wav" ) ]
#
#
#func play_sfx( no, randompitch = true  ):
#	if main != null:
#		if randompitch:
#			main.get_node( "sfx" ).set_pitch( rand_range( -0.3, 0.3 ) + 1 )
#		else:
#			main.get_node( "sfx" ).set_pitch( 1 )
#		main.get_node( "sfx" ).mplay( SFXS[no] )
