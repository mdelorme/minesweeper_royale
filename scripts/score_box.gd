extends HBoxContainer

var player_scores : Array[ColorRect]
@onready var width : float = size.x

func _ready() -> void:
	for i in range(4):
		var color_rect := get_node('Score_p%d' % [i+1])
		player_scores.append(color_rect)
	EventBus.on_player_score.connect(on_player_score)

func on_player_score(player_id: int, score: int) -> void:
	var tween := get_tree().create_tween()
	for i in range(4):
		var player := GameState.players[i]
		var frac = player.score
		tween.parallel().tween_property(player_scores[i], "size_flags_stretch_ratio", frac, 0.1)
