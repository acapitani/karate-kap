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

var fsm = null
var other_player = null
var vel = Vector2()

var is_jump = false
var on_hit = false
var hit_playing = false
var anim_cur = ""
var anim_nxt = ""

var is_cutscene = false

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
	if player_num==1:
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
	
func _check_hit():
	var hit = false
	var dir = DIRHIT_MED
	var iskick = true
	if on_hit and other_player!=null and other_player.is_ingame():
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
	if player_num==1 and Input.is_action_pressed("btn_rotate"):
		rot = true
	elif player_num==2 and Input.is_action_pressed("btn_rotate2"):
		rot = true 
	return rot
		
func set_block():
	fsm.state_nxt = fsm.STATES.block

func check_block():
	var block = false 
	if fsm.state_cur==fsm.STATES.ingame:
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
	
	if player_num==1:
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
		# interact
		#_interact( delta )
		
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
	
	
	
	
	
	