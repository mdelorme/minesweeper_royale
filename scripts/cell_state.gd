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

func dug() -> bool:
	return interaction == Interaction.DUG

func diggable() -> bool:
	return interaction != Interaction.DUG

func flagged() -> bool:
	return interaction == Interaction.FLAGGED

func empty() -> bool:
	return secret == Secret.EMPTY

func mined() -> bool:
	return secret == Secret.MINED

func toggle_flag(player_id: int) -> bool:
	if not diggable():
		return false
	if flagged():
		if player_id == owner_id:
			interaction = Interaction.UNTOUCHED
			owner_id = -1
			return true
		return false
	interaction = Interaction.FLAGGED
	owner_id = player_id
	return true
