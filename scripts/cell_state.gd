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

var map_state: MapState
var position: Vector2i
var secret: Secret = Secret.EMPTY
var owner_id: int = -1
var interaction: Interaction = Interaction.UNTOUCHED
var neighbors: Array[CellState] = []

# AI variables
var mine_probability: float = NAN
var neighbors_mine_probability: float = NAN

func untouched() -> bool:
	return interaction == Interaction.UNTOUCHED

func dug() -> bool:
	return interaction == Interaction.DUG

func diggable() -> bool:
	return not dug()

func flagged() -> bool:
	return interaction == Interaction.FLAGGED

func empty() -> bool:
	return secret == Secret.EMPTY

func mined() -> bool:
	return secret == Secret.MINED

func should_flag() -> bool:
	return mine_probability >= 1.0 and untouched()

func should_dig() -> bool:
	return mine_probability < 1.0 and diggable()

func ai_excluded() -> bool:
	return dug() or (mine_probability >= 1.0 and flagged())

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

func compute_neighbors_mine_probability() -> float:
	if diggable():
		return NAN
	if empty():
		return 0.0
	if mined():
		return NAN
	var mines_count := 0
	var diggable_count := 0
	for neighbor in neighbors:
		if neighbor.diggable():
			diggable_count += 1
		elif neighbor.mined():
			mines_count += 1
	return clamp((secret - mines_count) / float(diggable_count), 0.0, 1.0)

func compute_mine_probability() -> float:
	var max_probability := map_state.default_mine_probability
	for neighbor in neighbors:
		var probability := neighbor.neighbors_mine_probability
		if is_nan(probability):
			continue
		if probability == 0.0:
			return 0.0
		if probability > max_probability:
			max_probability = probability
	return max_probability

func update_mine_probability() -> void:
	mine_probability = compute_mine_probability()

func update_neighbors_mine_probability() -> void:
	neighbors_mine_probability = compute_neighbors_mine_probability()
	for neighbor in neighbors:
		neighbor.mine_probability = neighbor.compute_mine_probability()

func update_probabilities() -> void:
	for neighbor in neighbors:
		neighbor.update_neighbors_mine_probability()
