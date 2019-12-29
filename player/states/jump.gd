extends "res://scripts/state.gd"

var gravity_timer

func initialize( obj ):
	obj.is_jump = true
	obj.anim_nxt = "jump"
	obj.vel.y = -obj.JUMP_VEL
	gravity_timer = obj.JUMP_MAXTIME
	
func terminate(obj):
	obj.is_jump = false
	
func run( obj, delta ):
	var pos = obj.get_position()
	if gravity_timer > 0:
		gravity_timer -= delta
		# jump gravity
		obj.vel.y = min( obj.vel.y + obj.JUMP_GRAVITY * delta, game.TERMINAL_VELOCITY )
		gravity_timer = 0
		pos.y += (obj.vel.y*delta)
	else:
		# normal gravity
		obj.vel.y = min( obj.vel.y + game.GRAVITY * delta, game.TERMINAL_VELOCITY )
		pos.y += (obj.vel.y*delta)
		if pos.y>game.FLOOR_Y:
			obj.fsm.state_nxt = obj.fsm.STATES.ingame
			
	# move
	obj.set_position(pos)