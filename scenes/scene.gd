extends Node

signal restart_level
signal finished_level
signal game_over
var can_input = false

func _ready():
	#call_deferred( "_connect_to_player" )
	#call_deferred( "_connect_to_finish" )
	var input_timer = Timer.new()
	input_timer.wait_time = 0.3
	input_timer.connect( "timeout", self, "_on_input_timer_timeout" )
	add_child( input_timer )
	input_timer.start()
	game.play_music( 0 )
	
func _on_input_timer_timeout():
	can_input = true

func _input(evt):
	if evt.is_action_pressed( "btn_quit" ):
		emit_signal( "game_over" )

