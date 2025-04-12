extends Label
class_name GainedPoints


@export var value: int = 1:
	set(_value):
		value = _value
		text = "%+d" % value
@export var owner_id: int = 1


func _ready():
	var player_state := GameState.players[owner_id - 1]
	modulate = player_state.color

	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", -32.0, 1.0).as_relative()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
