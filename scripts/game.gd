extends Node2D

@onready var map : Map = $Map

const dig_sound       := preload("res://sounds/dig.wav")
const explosion_sound := preload("res://sounds/explosion.wav")

func _ready() -> void:
	## Connecting to relevant signals of the event bus
	EventBus.on_player_dig.connect(on_player_dig)
	EventBus.on_player_score.connect(on_player_score)
	
func on_player_dig(pos: Vector2, player_id: int) -> void:
	var map_position := map.pos_to_tile(pos)
	var map_state := GameState.map
	if map_state.is_cell_diggable(map_position):
		AudioBus.play_sound(dig_sound, 0.2)
		## Player is still alive, score increased
		if not map_state.player_digs(map_position, player_id):
			AudioBus.play_sound(explosion_sound)
			kill_player(player_id)

func on_player_score(player_id: int, score: int) -> void:
	GameState.players[player_id-1].score += score

func kill_player(player_id: int) -> void:
	var player: Player = get_node("Player%d" % [player_id])
	assert(player)
	player.die()
