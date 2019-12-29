extends "res://scripts/state.gd"


func initialize( obj ):
	obj.is_attack = true

func run( obj, delta ):
	pass
	
func terminate(obj):
	obj.hit_off()
	obj.is_attack = false
	