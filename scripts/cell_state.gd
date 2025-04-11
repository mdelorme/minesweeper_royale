extends Node
class_name CellState


enum Secret {
	EMPTY = 0,
	ONE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	MINED = 9,
}
enum Interaction { UNTOUCHED, DUG, FLAGGED }


var secret: Secret = Secret.EMPTY
var owner_id: int = -1
var interaction: Interaction = Interaction.UNTOUCHED
