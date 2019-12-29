extends Node2D

export( int ) var player_num = 1
export (int) var dir_cur = 1

const VEL_PLAYER = 100

const JUMP_VEL = 220
const JUMP_GRAVITY = 700
const JUMP_MAXTIME = 0.25

const DIR_NONE = 0
const DIR_UP = 1
const DIR_UPRIGHT = 2
const DIR_RIGHT = 3
const DIR_DOWNRIGHT = 4
const DIR_DOWN = 5
const DIR_DOWNLEFT = 6
const DIR_LEFT = 7
const DIR_UPLEFT = 8

const HIT_STOMACH = 1
const HIT_FRONT = 2
const HIT_BACK = 3

const DIRHIT_HIGH = 1
const DIRHIT_MED = 2
const DIRHIT_LOW = 3

const ACTION_NONE = 0
const ACTION_FORW = 1
const ACTION_BACK = 2
const ACTION_JUMP = 3
const ACTION_SHINKICK = 4
const ACTION_FOOTSWEEPKICK = 5
const ACTION_STOMACHPUNCH = 6
const ACTION_REVFACEPUNCH = 7
const ACTION_FLYINGKICK = 8
const ACTION_HEADBUTT = 9
const ACTION_STOMACHKICK = 10
const ACTION_FACEKICK = 11
const ACTION_REVFOOTSWEEPKICK = 12
const ACTION_REVFACEKICK = 13
const ACTION_BACKFLIP = 14
const ACTION_DOUBLEKICK = 15
const ACTION_FACEPUNCH = 16

const STATUS_IDLE = 0
const STATUS_WAIT = 1
const STATUS_MOVE = 2
const STATUS_ATTACK = 3
const STATUS_DEFENSE = 4

var cpu_next_action = 0
var cpu_status = 0
var cpu_block = false

var fsm = null
var other_player = null
var vel = Vector2()

var is_jump = false
var is_attack = false
var is_fall = false
var is_ingame = false
var on_hit = false
var hit_playing = false
var anim_cur = ""
var anim_nxt = ""

var is_cutscene = false
var shield = false

onready var rotate = $rotate

func _ready():
	# register with game
	#game.player = self
	# Initialize states machine
	fsm = preload( "res://scripts/fsm.gd" ).new( self, $states, $states/ready, false )
	_set_belt_color()
	#call_deferred("_set_belt_color")
	
func _set_belt_color():
	var mat = $rotate/player.get_material().duplicate()
	if player_num<0:
		mat.set_shader_param("belt_color", Color(1.0, 1.0, 1.0, 1.0))
	elif player_num==0:
		mat.set_shader_param("belt_color", Color(1.0, 0.0, 0.0, 1.0))
	elif player_num==1:
		mat.set_shader_param("belt_color", Color(0.0, 0.0, 1.0, 1.0))
	else:
		mat.set_shader_param("belt_color", Color(0.0, 1.0, 0.0, 1.0))
	$rotate/player.set_material(mat)
	
func set_cutscene():
	is_cutscene = true
	
func reset_cutscene():
	is_cutscene = false
	
func fight():
	fsm.state_nxt = fsm.STATES.ingame
	
func is_ingame():
	if fsm.state_cur==fsm.STATES.ingame:
		return true
	return false 
	
func attack(anim):
	anim_nxt = anim
	fsm.state_nxt = fsm.STATES.attack
	
func fall(hit_type):
	if hit_type==HIT_STOMACH:
		anim_nxt = "fall1"
	elif hit_type==HIT_FRONT:
		anim_nxt = "fall2"
	else:
		anim_nxt = "fall3"
	fsm.state_nxt = fsm.STATES.fall

func hit_on():
	on_hit = true
	
func hit_off():
	# disattiva tutti i punti di hit
	on_hit = false
	hit_playing = false
	
func weak_on():
	# todo!!! attiva tutte le aree di collisione di difesa
	pass
	
func weak_off():
	# disattiva tutte le aree di collisione difesa
	# $rotate/weak_areas.set_process(false)
	pass
	
func shield_on():
	shield = true
	
func activate_shield_timer():
	$shield_timer.start()
	
func _check_hit():
	var hit = false
	var dir = DIRHIT_MED
	var iskick = true
	if on_hit and other_player!=null and other_player.is_ingame() and other_player.shield==false:
		var areas = []
		if anim_cur=="footsweep_kick":
			dir = DIRHIT_LOW
			areas = $rotate/hit_areas/footsweep.get_overlapping_areas()
		elif anim_cur=="front_punch":
			iskick = false
			dir = DIRHIT_HIGH
			areas = $rotate/hit_areas/front_punch.get_overlapping_areas()
		elif anim_cur=="shin_kick":
			dir = DIRHIT_LOW
			areas = $rotate/hit_areas/shin_kick.get_overlapping_areas()
		elif anim_cur=="stomach_punch":
			iskick = false
			dir = DIRHIT_MED
			areas = $rotate/hit_areas/stomach_punch.get_overlapping_areas()
		elif anim_cur=="head_butt":
			iskick = false
			dir = DIRHIT_HIGH
			areas = $rotate/hit_areas/head.get_overlapping_areas()
		elif anim_cur=="stomach_kick":
			dir = DIRHIT_MED
			areas = $rotate/hit_areas/stomach_kick.get_overlapping_areas()
		elif anim_cur=="face_kick":
			dir = DIRHIT_HIGH
			areas = $rotate/hit_areas/face_kick.get_overlapping_areas()
		elif anim_cur=="flying_kick":
			dir = DIRHIT_HIGH
			areas = $rotate/hit_areas/flying_kick.get_overlapping_areas()
		elif anim_cur=="double_kick":
			dir = DIRHIT_HIGH
			areas = $rotate/hit_areas/double_kick.get_overlapping_areas()
		
		for a in areas:
			if a.get_parent().get_name()=="weak_areas":
				# print("HIT")
				hit = true
				if dir_cur==other_player.dir_cur:
					other_player.fall(HIT_BACK)
				else:
					if dir==DIRHIT_MED:
						other_player.fall(HIT_STOMACH)
					elif dir==DIRHIT_HIGH:
						if other_player.check_block():
							other_player.set_block()
						else:
							other_player.fall(HIT_FRONT)
					else:
						other_player.fall(HIT_FRONT)
		if not hit:
			if iskick:
				whoosh1()
			else:
				whoosh2()
		else:
			if iskick:
				kick()
			else:
				if (randi()%2)==0:
					punch1()
				else:
					punch2()
	return hit
	
func check_rotate():
	var rot = false
	if player_num<=0:
		return cpu_check_rotate()
	elif player_num==1 and Input.is_action_pressed("btn_rotate"):
		rot = true
	elif player_num==2 and Input.is_action_pressed("btn_rotate2"):
		rot = true 
	return rot
		
func set_block():
	fsm.state_nxt = fsm.STATES.block

func check_block():
	var block = false 
	if fsm.state_cur==fsm.STATES.ingame:
		if player_num<=0:
			return cpu_check_block()
		if dir_cur==1:
			if player_num==1:
				if Input.is_action_pressed("btn_left"):
					block = true
			else:
				if Input.is_action_pressed("btn_left2"):
					block = true
		else:
			if player_num==1:
				if Input.is_action_pressed("btn_right"):
					block = true
			else:
				if Input.is_action_pressed("btn_right2"):
					block = true
	return block
		
func check_move():
	var dir = Vector2()
	var direction = DIR_NONE
	var moving = false
	var action = false
	
	if player_num<=0:
		return cpu_check_move()
	elif player_num==1:
		if Input.is_action_pressed("btn_left"):
			dir.x = -1
			moving = true
		elif Input.is_action_pressed("btn_right"):
			dir.x = 1
			moving = true
		if Input.is_action_pressed("btn_up"):
			dir.y = 1
			moving = true
		elif Input.is_action_pressed("btn_down"):
			dir.y = -1
			moving = true
		if Input.is_action_pressed("btn_action"):
			action = true
	else:
		if Input.is_action_pressed("btn_left2"):
			dir.x = -1
			moving = true
		elif Input.is_action_pressed("btn_right2"):
			dir.x = 1
			moving = true
		if Input.is_action_pressed("btn_up2"):
			dir.y = 1
			moving = true
		elif Input.is_action_pressed("btn_down2"):
			dir.y = -1
			moving = true
		if Input.is_action_pressed("btn_action2"):
			action = true
			
	if moving:
		if dir.y==1:
			direction = DIR_UP
			if dir.x==1:
				direction = DIR_UPRIGHT
			elif dir.x==-1:
				direction = DIR_UPLEFT
		elif dir.y==-1:
			direction = DIR_DOWN
			if dir.x==1:
				direction = DIR_DOWNRIGHT
			elif dir.x==-1:
				direction = DIR_DOWNLEFT
		elif dir.x==1:
			direction = DIR_RIGHT
		elif dir.x==-1:
			direction = DIR_LEFT
	return [moving, direction, action]
	
func _check_limits():
	if position.x<=game.LIMIT_LEFT:
		position.x = game.LIMIT_LEFT
	elif position.x>=game.LIMIT_RIGHT:
		position.x = game.LIMIT_RIGHT
	if position.y>game.FLOOR_Y:
		position.y = game.FLOOR_Y
		
func _shadow():
	$rotate/shadow.frame = $rotate/player.frame

func _physics_process( delta ):
	if is_cutscene:
		pass
	else:
		# update states machine
		fsm.run_machine( delta )
		# direction
		$rotate.scale.x = dir_cur
		# update animations
		if anim_nxt != anim_cur:
			anim_cur = anim_nxt
			$anim.play( anim_cur )
	_check_limits()
	_check_hit()
	_shadow()

# ------------------------ CPU AI --------------------------------------
var cpu_move_time = 0.0
var cpu_wait_time = 0.0
var cpu_move_dir = 1

func do_wait(delta):
	cpu_wait_time -= delta
	if cpu_wait_time<=0.0:
		cpu_wait_time = 0.0
		cpu_status = STATUS_IDLE

func do_move(delta):
	cpu_move_time -= delta
	if cpu_move_time<=0.0:
		cpu_move_time = 0.0
		cpu_status = STATUS_IDLE
	else:
		if dir_cur==cpu_move_dir:
			cpu_next_action = ACTION_FORW
		else:
			cpu_next_action = ACTION_BACK
			
func do_direct_attack():
	var actions = [ACTION_FACEPUNCH, ACTION_SHINKICK, ACTION_STOMACHPUNCH, ACTION_HEADBUTT, ACTION_STOMACHKICK, ACTION_FACEKICK]
	cpu_next_action = actions[randi()%6]
	
func do_reverse_attack():
	var actions = [ACTION_REVFACEPUNCH, ACTION_REVFACEKICK]
	cpu_next_action = actions[randi()%2]
	
func do_action1(delta):
	# near, attacca, difende o si back-flip
	var other_pos = other_player.get_position()
	var pos = get_position()
	if other_player.is_ingame:
		# attacca o attende
		var prob = randf()
		if prob>0.3:
			if (dir_cur==1 and other_pos.x>pos.x) or (dir_cur==-1 and other_pos.x<=pos.x):
				do_direct_attack()
			else:
				do_reverse_attack()
		else:
			cpu_wait_time = 0.2
			do_wait(delta)
	else:
		# si difende o attende
		if not other_player.is_fall:
			# si difende
			var prob =randf()
			if prob>0.5:
				cpu_block = true
			elif prob>0.3:
				cpu_next_action = ACTION_JUMP
			elif prob>0.2:
				cpu_next_action = ACTION_BACKFLIP
			else:
				cpu_wait_time = 0.1
				do_wait(delta)
		else:
			cpu_wait_time = 0.2
			do_wait(delta)
		
func do_action2(delta):
	# too near, mi devo spostare
	var prob = randf()
	var pos = get_position()
	if prob>0.7 and pos.x>32 and pos.x<300:
		cpu_move_time = 0.3
		if dir_cur==1:
			cpu_move_dir = -1
		else:
			cpu_move_dir = 1
		cpu_status = STATUS_MOVE
	elif prob>0.5 and pos.x>32 and pos.x<300:
		cpu_next_action = ACTION_BACKFLIP
	elif prob>0.3:
		cpu_wait_time = 0.1
		do_wait(delta)
	else:
		do_action1(delta)

func do_action3(delta):
	# quasi near, calci volanti, scivolata o si avvicina
	var other_pos = other_player.get_position()
	var pos = get_position()
	if (dir_cur==1 and other_pos.x>pos.x) or (dir_cur==-1 and other_pos.x<pos.x) and other_player.is_ingame:
		var prob = randf()
		if prob<0.1:
			cpu_next_action = ACTION_DOUBLEKICK
		else:
			var actions = [ACTION_FLYINGKICK, ACTION_FOOTSWEEPKICK]
			cpu_next_action = actions[randi()%2]
	else:
		var prob = randf()
		if prob>0.7:
			if other_pos.x>=pos.x:
				dir_cur = 1
			else:
				dir_cur = -1
			cpu_move_time = 0.2
			cpu_move_dir = dir_cur
			cpu_status = STATUS_MOVE
		else:
			cpu_wait_time = 0.2
			do_wait(delta)

func cpu_ai(delta):
	if player_num>0:
		return
	cpu_block = false
	cpu_next_action = ACTION_NONE
	if cpu_status==STATUS_IDLE:
		var other_pos = other_player.get_position()
		var pos = get_position()
		var dist = abs(other_pos.x-pos.x)/320.0
		if dist>0.5:
			# grande distanza
			if randf()>0.6:
				if other_pos.x<pos.x:
					dir_cur = -1
					cpu_move_dir = -1
				else:
					dir_cur = 1
					cpu_move_dir = 1
				cpu_status = STATUS_MOVE
				cpu_move_time = randf()/4.0
			else:
				cpu_wait_time = 0.2+randf()
				cpu_status = STATUS_WAIT
		elif dist>0.25:
			# media distanza
			var prob = randf()
			if prob>0.6:
				if other_pos.x<pos.x:
					dir_cur = -1
					cpu_move_dir = -1
				else:
					dir_cur = 1
					cpu_move_dir = 1
				cpu_status = STATUS_MOVE
				cpu_move_time = randf()/4.0
			elif prob>0.4:
				cpu_wait_time = randf()/4.0
				cpu_status = STATUS_WAIT
			elif prob>0.3:
				if other_pos.x<pos.x:
					dir_cur = -1
					cpu_move_dir = 1
				else:
					dir_cur = 1
					cpu_move_dir = -1
				cpu_status = STATUS_MOVE
				cpu_move_time = randf()/6.0
			if prob<0.1 and dist<0.3 and other_player.is_ingame:
					cpu_next_action = ACTION_FLYINGKICK
					if other_pos.x<pos.x:
						dir_cur = -1
					else:
						dir_cur = 1
		elif dist>0.1:
			# quasi near, calci volanti, scivolata o si avvicina
			do_action3(delta)
		elif dist>0.05:
			# near, attacca, difende o si back-flip
			do_action1(delta)
		else:
			# too near, mi devo spostare
			do_action2(delta)
				
	elif cpu_status==STATUS_WAIT:
		do_wait(delta)
	elif cpu_status==STATUS_MOVE:
		do_move(delta)

func cpu_check_move():
	var moving = true
	var direction = DIR_NONE
	var action = false
	"""
	var other_pos = other_player.get_position()
	var other_state = other_player.fsm.state_cur
	var other_anim = other_player.anim_cur
	var pos = get_position()
	
	var diff = abs(other_pos.x-pos.x)
	if other_state==other_player.fsm.STATES.ingame and (diff>64):
		if dir_cur==1 and other_pos.x>pos.x:
			moving = true
			direction = DIR_RIGHT
		elif dir_cur==-1 and other_pos.x<pos.x:
			moving = true
			direction = DIR_LEFT
	"""
	match cpu_next_action:
		ACTION_NONE:
			moving = false
		ACTION_BACK:
			if dir_cur==1:
				direction = DIR_LEFT
			else:
				direction = DIR_RIGHT
		ACTION_FORW:
			if dir_cur==1:
				direction = DIR_RIGHT
			else:
				direction = DIR_LEFT
		ACTION_JUMP:
			direction = DIR_UP
		ACTION_FACEPUNCH:
			if dir_cur==1:
				direction = DIR_UPRIGHT
			else:
				direction = DIR_UPLEFT
		ACTION_SHINKICK:
			if dir_cur==1:
				direction = DIR_DOWNRIGHT
			else:
				direction = DIR_DOWNLEFT
		ACTION_FOOTSWEEPKICK:
			direction = DIR_DOWN
		ACTION_STOMACHPUNCH:
			if dir_cur==1:
				direction = DIR_DOWNLEFT
			else:
				direction = DIR_DOWNRIGHT
		ACTION_REVFACEPUNCH:
			if dir_cur==1:
				direction = DIR_UPLEFT
			else:
				direction = DIR_UPRIGHT
		ACTION_FLYINGKICK:
			direction = DIR_UP
			action = true
		ACTION_HEADBUTT:
			action = true
			if dir_cur==1:
				direction = DIR_UPRIGHT
			else:
				direction = DIR_UPLEFT
		ACTION_STOMACHKICK:
			action = true
			if dir_cur==1:
				direction = DIR_RIGHT
			else:
				direction = DIR_LEFT
		ACTION_FACEKICK:
			action = true
			if dir_cur==1:
				direction = DIR_DOWNRIGHT
			else:
				direction = DIR_DOWNLEFT
		ACTION_REVFOOTSWEEPKICK:
			action = true
			direction = DIR_DOWN
		ACTION_REVFACEKICK:
			action = true
			if dir_cur==1:
				direction = DIR_DOWNLEFT
			else:
				direction = DIR_DOWNRIGHT
		ACTION_BACKFLIP:
			action = true
			if dir_cur==1:
				direction = DIR_LEFT
			else:
				direction = DIR_RIGHT
		ACTION_DOUBLEKICK:
			action = true
			if dir_cur==1:
				direction = DIR_UPLEFT
			else:
				direction = DIR_UPRIGHT
	return [moving, direction, action]

func cpu_check_rotate():
	var rot = false
	var pos = get_position()
	var other_pos = other_player.get_position()
	# verifica se sta dietro
	if dir_cur==1 and other_pos.x<pos.x and (pos.x-other_pos.x)>16.0:
		rot = true
	elif dir_cur==-1 and other_pos.x>pos.x and (other_pos.x-pos.x)>16.0:
		rot = true
	return rot
	
func cpu_check_block():
	if cpu_block:
		cpu_block = false
		return true
	return false
# ------------------------ CPU AI --------------------------------------
	
func wataa():
	$mplayer.mplay(preload("res://sfx/wataa.wav"))
	
func shout():
	var n = randi()%6
	if n==0:
		$mplayer.mplay(preload("res://sfx/shout1-a.wav"))
	elif n==1:
		$mplayer.mplay(preload("res://sfx/shout1-b.wav"))
	elif n==2:
		$mplayer.mplay(preload("res://sfx/shout2.wav"))
	elif n==3:
		$mplayer.mplay(preload("res://sfx/shout3.wav"))
	
func punch1():
	if hit_playing:
		return
	$mplayer.mplay(preload("res://sfx/punch.wav"))
	hit_playing = true
	
func punch2():
	if hit_playing:
		return
	$mplayer.mplay(preload("res://sfx/punch2.wav"))
	hit_playing = true
	
func kick():
	if hit_playing:
		return
	$mplayer.mplay(preload("res://sfx/kick1.wav"))
	hit_playing = true

func whoosh1():
	if hit_playing:
		return
	$mplayer.mplay(preload("res://sfx/whoosh1.wav"))
	hit_playing = true
	
func whoosh2():
	if hit_playing:
		return
	$mplayer.mplay(preload("res://sfx/whoosh2.wav"))
	hit_playing = true

func _on_shield_timer_timeout():
	shield = false
	
