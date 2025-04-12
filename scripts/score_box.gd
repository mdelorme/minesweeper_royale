extends HBoxContainer

var player_scores : Array[Panel]
@onready var width : float = size.x

func _ready() -> void:
	for i in range(4):
		var color_rect := get_node('Score_p%d' % [i+1])
		player_scores.append(color_rect)
	EventBus.on_update_player_score.connect(on_update_player_score)

func on_update_player_score(player_id: int) -> void: 
	var tween := get_tree().create_tween()
	var player := GameState.players[player_id-1]
	tween.tween_property(player_scores[player_id-1], "size_flags_stretch_ratio", player.score, 0.1)
