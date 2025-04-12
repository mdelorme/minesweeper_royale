extends Node

var map_width  := 28
var map_height := 14
var nb_bombs := 40

var map: MapState
var players: Array[PlayerState]

var nb_players_alive:
	get: return len(players.filter(func(p): return p.hearts > 0))

func _init():
	randomize_next_game()
	reset()

func randomize_next_game():
	return
	# TODO: reenable once player spawns take map size into account
	#map_width = randi_range(20, 28)
	#map_height = randi_range(10, 14)
	#nb_bombs = floor(map_width*map_height / randf_range(9, 10))

func reset():
	map = MapState.new(map_width, map_height, nb_bombs)
	players = [
		PlayerState.new(1),
		PlayerState.new(2),
		PlayerState.new(3),
		PlayerState.new(4),
	]
	EventBus.on_game_reset.emit()

func compute_leaders():
	var max_so_far = -1
	var leaders = []
	for i in range(len(players)):
		var score = GameState.players[i].score
		if score > max_so_far:
			max_so_far = score
			leaders = [i]
		elif score == max_so_far:
			leaders.append(i)
	for i in range(len(players)):
		GameState.players[i].is_leader = i in leaders
