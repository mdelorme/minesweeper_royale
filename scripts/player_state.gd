extends Node
class_name PlayerState

static var player_names: Array[String] = [
	"Jean Poule II",
	"Dead Poule", 
	"Crapoule",
	"Swimming Poule"
]

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
const MAX_HEARTS: int = 3


var id: int:
	set(value):
		id = value
		color = COLORS[id - 1]
		position = INITIAL_POSITIONS[id - 1]
var color: Color
var position: Vector2
var hearts: int = MAX_HEARTS
var invincible: bool = false
var score: int = 1
var is_leader: bool = false
var player_name: String
var discarded := false

func _init(_id: int):
	id = _id
	score = 1
	player_name = player_names[_id-1]


func unset_invincible():
	invincible = false

func is_dead():
	return hearts <= 0
