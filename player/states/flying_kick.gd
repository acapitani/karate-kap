extends "res://scripts/state.gd"

var gravity_timer

var x_acc = 0

func initialize( obj ):
	obj.is_jump = true
	obj.is_attack = true
	obj.anim_nxt = "flying_kick"
	obj.vel.y = -obj.JUMP_VEL
	if obj.dir_cur==1:
		x_acc = 100
	else:
		x_acc = -100
	obj.vel.x = x_acc
	gravity_timer = obj.JUMP_MAXTIME
	
func terminate(obj):
	obj.is_jump = false
	obj.is_attack = false
	
func run( obj, delta ):
	var pos = obj.get_position()
	if gravity_timer > 0:
		gravity_timer -= delta
		# jump gravity
		obj.vel.y = min( obj.vel.y + obj.JUMP_GRAVITY * delta, game.TERMINAL_VELOCITY )
		obj.vel.x = obj.vel.x + (x_acc * delta)
		gravity_timer = 0
		pos.y += (obj.vel.y*delta)
		pos.x += (obj.vel.x*delta)
	else:
		# normal gravity
		obj.vel.y = min( obj.vel.y + game.GRAVITY * delta, game.TERMINAL_VELOCITY )
		pos.y += (obj.vel.y*delta)
		obj.vel.x = obj.vel.x + (x_acc * delta)
		pos.x += (obj.vel.x*delta)
		if pos.y>game.FLOOR_Y:
			obj.fsm.state_nxt = obj.fsm.STATES.ingame
			
	# move
	obj.set_position(pos)