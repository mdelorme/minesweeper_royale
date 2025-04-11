extends Node
class_name PlayerState


static var COLORS: Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
]
static var INITIAL_POSITIONS: Array[Vector2] = [
	Vector2(64, 64),
	Vector2(64, 512),
	Vector2(1024, 64),
	Vector2(1024, 512),
]


var id: int:
	set(value):
		id = value
		label = "Player %s" % id
		color = COLORS[id - 1]
		position = INITIAL_POSITIONS[id - 1]
var label: String:
	set(value):
		label = value
		EventBus.on_player_rename.emit(id, value)
var color: Color
var position: Vector2


func _init(_id: int):
	id = _id
