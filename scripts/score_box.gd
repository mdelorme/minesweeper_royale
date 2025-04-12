extends HBoxContainer

var player_scores : Array[ColorRect]
var width : float
var total_scores : int

func _ready() -> void:
	for i in range(4):
		var color_rect := get_node('Score_p%d' % [i+1])
		#color_rect.color = GameState.players[i].color
		player_scores.append(color_rect)
	width = size.x
	EventBus.on_player_score.connect(on_player_score)
	total_scores = 0
	
func on_player_score(_player_id: int, score: int) -> void:
	total_scores += score
	for i in range(4):
		var player := GameState.players[i]
		var frac = width * player.score / total_scores
		player_scores[i].custom_minimum_size.x = frac  
