extends "res://scripts/state.gd"

var x_acc = 0

func initialize( obj ):
	obj.anim_nxt = "back_flip"
	obj.vel.y = 0
	if obj.dir_cur==1:
		x_acc = -64
	else:
		x_acc = 64
	obj.vel.x = x_acc
	
func run( obj, delta ):
	var n = obj.get_node("rotate/player")
	if n.frame<8 or n.frame>9:
		var pos = obj.get_position()
		obj.vel.x = obj.vel.x + (x_acc * delta)
		pos.x += (obj.vel.x*delta)
		# move
		obj.set_position(pos)
	