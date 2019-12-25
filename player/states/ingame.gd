extends "res://scripts/state.gd"

var wait_move = 0.0
var old_move = [false, 0, false]
var old_rotate = false

func initialize( obj ):
	obj.anim_nxt = "idle"
	wait_move = 0.1
	obj.weak_on()
	obj.hit_off()
	obj.is_jump = false
	
func terminate(obj):
	obj.weak_off()

func run( obj, delta ):
	wait_move -= delta
	if wait_move<0.0:
		wait_move = 0.0
	
	var pos = obj.get_position()
	var move = obj.check_move()
	var rot = obj.check_rotate()
	
	if move[0]:
		if obj.dir_cur==1:
			# TO RIGHT
			if move[2]:
				# TO RIGHT - WITH FIRE 
				if _can_action(move):
					if move[1]==obj.DIR_UP:
						obj.fsm.state_nxt = obj.fsm.STATES.flying_kick
					elif move[1]==obj.DIR_UPRIGHT:
						obj.attack("head_butt")
					elif move[1]==obj.DIR_RIGHT:
						obj.attack("stomach_kick")
					elif move[1]==obj.DIR_DOWNRIGHT:
						obj.attack("face_kick")
					elif move[1]==obj.DIR_DOWN:
						obj.dir_cur=-1
						obj.attack("footsweep_kick")
					elif move[1]==obj.DIR_DOWNLEFT:
						obj.dir_cur=-1
						obj.attack("face_kick")
					elif move[1]==obj.DIR_LEFT:
						obj.fsm.state_nxt = obj.fsm.STATES.back_flip
					elif move[1]==obj.DIR_UPLEFT:
						obj.fsm.state_nxt = obj.fsm.STATES.double_kick
			else:
				# TO RIGHT - NO FIRE
				if move[1]==obj.DIR_RIGHT:
					obj.anim_nxt = "walk_back"
					pos.x += (obj.VEL_PLAYER*delta)
				elif move[1]==obj.DIR_LEFT:
					obj.anim_nxt = "walk_back"
					pos.x -= (obj.VEL_PLAYER*delta)
				elif _can_action(move):
					if move[1]==obj.DIR_UP:
						obj.fsm.state_nxt = obj.fsm.STATES.jump
					elif move[1]==obj.DIR_UPRIGHT:
						obj.attack("front_punch")
					elif move[1]==obj.DIR_DOWNRIGHT:
						obj.attack("shin_kick")
					elif move[1]==obj.DIR_DOWN:
						obj.attack("footsweep_kick")
					elif move[1]==obj.DIR_DOWNLEFT:
						obj.attack("stomach_punch")
					elif move[1]==obj.DIR_UPLEFT:
						obj.dir_cur=-1
						obj.attack("front_punch")
		else:
			# TO LEFT
			if move[2]:
				# TO LEFT - WITH FIRE
				if _can_action(move):
					if move[1]==obj.DIR_UP:
						obj.fsm.state_nxt = obj.fsm.STATES.flying_kick
					elif move[1]==obj.DIR_UPRIGHT:
						obj.fsm.state_nxt = obj.fsm.STATES.double_kick
					elif move[1]==obj.DIR_RIGHT:
						obj.fsm.state_nxt = obj.fsm.STATES.back_flip
					elif move[1]==obj.DIR_DOWNRIGHT:
						obj.dir_cur=1
						obj.attack("face_kick")
					elif move[1]==obj.DIR_DOWN:
						obj.dir_cur=1
						obj.attack("footsweep_kick")
					elif move[1]==obj.DIR_DOWNLEFT:
						obj.attack("face_kick")
					elif move[1]==obj.DIR_LEFT:
						obj.attack("stomach_kick")
					elif move[1]==obj.DIR_UPLEFT:
						obj.attack("head_butt")
			else:
				# TO LEFT - NO FIRE
				if move[1]==obj.DIR_RIGHT:
					obj.anim_nxt = "walk_back"
					pos.x += (obj.VEL_PLAYER*delta)
				elif move[1]==obj.DIR_LEFT:
					obj.anim_nxt = "walk"
					pos.x -= (obj.VEL_PLAYER*delta)
				elif _can_action(move):
					if move[1]==obj.DIR_UP:
						obj.fsm.state_nxt = obj.fsm.STATES.jump
					elif move[1]==obj.DIR_UPRIGHT:
						obj.dir_cur=1
						obj.attack("front_punch")
					elif move[1]==obj.DIR_DOWNRIGHT:
						obj.attack("stomach_punch")
					elif move[1]==obj.DIR_DOWN:
						obj.attack("footsweep_kick")
					elif move[1]==obj.DIR_DOWNLEFT:
						obj.attack("shin_kick")
					elif move[1]==obj.DIR_UPLEFT:
						obj.attack("front_punch")
	else:
		if rot and old_rotate ==false:
			if obj.dir_cur==1:
				obj.dir_cur = -1
			else:
				obj.dir_cur = 1
		obj.anim_nxt = "idle"
	
	# move
	old_rotate = rot
	old_move = move
	obj.set_position(pos)
	
func _can_action(move):
	if wait_move==0.0 and (move[0]!=old_move[0] or move[1]!=old_move[1] or move[2]!=old_move[2]):
		return true
	return false
