extends "res://scripts/state.gd"


func initialize( obj ):
	obj.weak_off()
	obj.is_fall = true

func run( obj, delta ):
	pass
	
func terminate(obj):
	obj.is_fall = false
	