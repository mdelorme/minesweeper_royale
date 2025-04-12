extends Node
class_name PlayerState


static var COLORS: Array[Color] = [
	Color("#076598"),
	Color("#43871a"),
	Color("#b06f18"),
	Color("#8d1f85"),
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
		color = COLORS[id - 1]
		position = INITIAL_POSITIONS[id - 1]
var color: Color
var position: Vector2
var score: int = 1


func _init(_id: int):
	id = _id
	score = 1
