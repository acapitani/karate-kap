extends AudioStreamPlayer

export var no_players = 10
var players = []
var cur_player = 0
var cur_pitch = 1.0
func _ready():
	players.append( self )
	for n in range( no_players - 1 ):
		var a = AudioStreamPlayer.new()
		players.append( a )
		add_child( a )
		a.bus = self.bus
		a.volume_db = self.volume_db

func get_player():
	cur_player = ( cur_player + 1 ) % no_players
	return players[ cur_player ]

func set_pitch( p ):
	cur_pitch = p

func mplay( s, random_pitch = true ):
	var p = get_player()
	if p.stream != s:
		p.stream = s
	p.pitch_scale = cur_pitch
	if random_pitch:
		p.pitch_scale = 1 + rand_range( -0.1, 0.1 )
	p.play()
