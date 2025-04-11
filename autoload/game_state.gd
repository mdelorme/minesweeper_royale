extends Node


var map: MapState
var players: Array[PlayerState]


func _init():
	reset()


func reset():
	map = MapState.new(28, 14, 40)
	players = [
		PlayerState.new(1),
		PlayerState.new(2),
		PlayerState.new(3),
		PlayerState.new(4),
	]
	EventBus.on_game_reset.emit()
