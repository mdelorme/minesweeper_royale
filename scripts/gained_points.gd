extends Label
class_name PointsGained


@export var value: int = 1
@export var owner_id: int = 1


func _ready():
	var player_state := GameState.players[owner_id]
	modulate = player_state.color
	
	text = "%+d" % value

	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", -10.0, 0.5).as_relative()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
