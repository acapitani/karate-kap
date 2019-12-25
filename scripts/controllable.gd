extends KinematicBody2D

var vel = Vector2()



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


# get a direction based on player input
func motion_input():
	var dir = Vector2()
	var is_moving = false
	if Input.is_action_pressed( "btn_left" ):
		dir.x -= 1
		is_moving = true
	if Input.is_action_pressed( "btn_right" ):
		dir.x += 1
		is_moving = true
	if Input.is_action_pressed( "btn_up" ):
		dir.y -= 1
		is_moving = true
	if Input.is_action_pressed( "btn_down" ):
		dir.y += 1
		is_moving = true
	dir = dir.normalized()
	return [ is_moving, dir ]

# translate a direction into movement
func motion( delta, dir, max_vel, accel, decel ):
	var hv = vel
	var new_pos = dir * max_vel
	var accel_f = decel
	if dir.dot( hv ) > 0:
		accel_f = accel
	vel = hv.linear_interpolate( new_pos, accel_f * delta )
	if vel.length_squared() < 0.5 * 0.5:
		vel *= 0
	vel = move_and_slide( vel )
	if get_slide_count() > 0:
		return get_slide_collision(0)
	return null