extends Node


var map: MapState


func reset():
	map = MapState.new(28, 14, 40)
	EventBus.on_game_reset.emit()
