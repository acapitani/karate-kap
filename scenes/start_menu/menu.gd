extends Node2D

signal selected_item


var cur_pos = 0
var nxt_pos = 0
var max_pos = 0
var items = []
var unselectable_items = []
func _ready():
	print( game.gamestate )
	items = get_children()
	for idx in range( 1, items.size() ):
		items[idx].modulate.a = 0.3#set_opacity( 0.3 )
	max_pos = items.size() - 1

func set_active( v ):
	if v: set_physics_process( true )
	else: set_physics_process( false )

func set_unselectable_item( no ):
	items[no].modulate.a = 0.1#set_opacity( 0.1 )
	unselectable_items.append( no )

func _physics_process(delta):
	if Input.is_action_just_pressed( "btn_action" ):
		#SoundManager.Play("inter_confirm")
		emit_signal( "selected_item", cur_pos )
		set_physics_process( false )
		return
	if Input.is_action_just_pressed( "btn_down" ):
		if unselectable_items.find( nxt_pos + 1 ) != -1:
			if nxt_pos + 2 <= max_pos:
				nxt_pos += 2
		else:
			nxt_pos += 1
	elif Input.is_action_just_pressed( "btn_up" ):
		if unselectable_items.find( nxt_pos - 1 ) != -1:
			if nxt_pos - 2 >= 0:
				nxt_pos -= 2
		else:
			nxt_pos -= 1
	
	if nxt_pos < 0: nxt_pos = 0
	elif nxt_pos > max_pos: nxt_pos = max_pos
	
	if nxt_pos != cur_pos:
		cur_pos = nxt_pos
	_update_pos( cur_pos )

func _update_pos( pos ):
	for idx in range( items.size() ):
		if idx == pos:
			items[idx].modulate.a = 1#set_opacity( 1 )
		else:
			if unselectable_items.find( idx ) == -1:
				items[idx].modulate.a = 0.3#set_opacity( 0.3 )
			else:
				items[idx].modulate.a = 0.1#set_opacity( 0.1 )

