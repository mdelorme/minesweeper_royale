extends Node
class_name MapState

const NEIGHBORS_DELTAS: Array[Vector2i] = [
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 1),
	Vector2i(1, -1),
	Vector2i(1, 1),
]

var cells: Dictionary[Vector2i, CellState]
var width: int
var height: int
var mines_count: int
var default_mine_probability: float

func _init(_width: int, _height: int, _mines_count: int) -> void:
	width = _width
	height = _height
	mines_count = _mines_count
	default_mine_probability = mines_count / float(width * height)
	fill_empty()
	assign_neighbors()
	add_mines()
	update_probabilities()
	EventBus.on_tile_update.connect(update_cell_probabilities)


func fill_empty() -> void:
	for y in range(height):
		for x in range(width):
			var cell_state := CellState.new()
			cell_state.map_state = self
			cell_state.position = Vector2i(x, y)
			cells[cell_state.position] = cell_state

func assign_neighbors():
	for position in cells:
		for neighbor_delta in NEIGHBORS_DELTAS:
			var neighbor_position := position + neighbor_delta
			if neighbor_position in cells:
				cells[position].neighbors.append(cells[neighbor_position])

func increment_neighbors(cell_state: CellState):
	for neighbor in cell_state.neighbors:
		neighbor.secret = min(neighbor.secret + 1, CellState.Secret.MINED)

func add_mines() -> void:
	assert(
		mines_count <= width * height,
		"ERROR: More mines than cells in this map!"
	)
	while mines_count > 0:
		var position := Vector2i(
			randi_range(0, width - 1),
			randi_range(0, height - 1),
		)
		var cell_state: CellState = cells[position]
		if cell_state.mined():
			continue
		cell_state.secret = CellState.Secret.MINED
		
		increment_neighbors(cell_state)
		mines_count -= 1

func update_probabilities() -> void:
	for cell: CellState in cells.values():
		cell.update_probabilities()

func player_digs(position: Vector2i, player_id: int, propagate: bool = true) -> bool:
	## Returns true if the player is still alive, false otherwise
	var cell_state : CellState = cells[position]
	cell_state.interaction = CellState.Interaction.DUG
	cell_state.owner_id = player_id
	EventBus.on_tile_update.emit(cell_state)

	var cell_exploded := cell_state.mined()
	
	if cell_exploded:
		EventBus.on_explosion.emit(position)
		for neighbor in cell_state.neighbors:
			if not neighbor.dug():
				player_digs(neighbor.position, 5, false)
			EventBus.on_explosion.emit(neighbor.position)
	elif player_id < 5:
		var score := cell_state.secret if not cell_exploded else 0
		EventBus.on_player_score.emit(player_id, score)

	if cell_state.empty() and propagate:
		for neighbor in cell_state.neighbors:
			if neighbor.diggable():
				player_digs(neighbor.position, player_id, false)

	return not cell_exploded

func player_flag(position: Vector2i, player_id: int) -> bool:
	var cell_state := cells[position]
	var changed := cell_state.toggle_flag(player_id)
	if changed:
		EventBus.on_tile_update.emit(cell_state)
	return changed

func get_score_at(position: Vector2i) -> int:
	var cell_state : CellState = cells[position]
	if cell_state.mined():
		return 0
	return cell_state.secret

func count_valid_flags(player_id: int) -> int:
	var total := 0
	for cell_state: CellState in cells.values():
		if cell_state.owner_id != player_id:
			continue

		if cell_state.flagged() and cell_state.mined():
			total += 1
	return total
	
func count_invalid_flags(player_id: int) -> int:
	var total := 0
	for cell_state: CellState in cells.values():
		if cell_state.owner_id != player_id:
			continue

		if cell_state.flagged() and not cell_state.mined():
			total += 1
	return total


func update_cell_probabilities(cell_state: CellState) -> void:
	cell_state.update_probabilities()


func get_ai_target_weight(cell_state: CellState, distance: float) -> float:
	if cell_state.ai_excluded():
		return INF
	if cell_state.should_flag():
		return log(distance)
	if cell_state.mine_probability == 0.0:
		return distance
	return (
		1.0 + PostgameScoreCard.valid_flag_bonus * cell_state.mine_probability
	) * (1.0 + distance)

func get_ai_target(coords: Vector2i, sampling: float = 0.1) -> CellState:
	var cells_states: Array[CellState] = cells.values()
	var max_samples := int(ceil(len(cells_states) * sampling))
	var agent_cell := (
		cells[coords] if coords in cells
		# Take a cell around the middle of the map by default.
		else cells_states[int(len(cells_states) / 2.0)]
	)
	var best_weight: float = get_ai_target_weight(agent_cell, 0.0)
	cells_states = cells_states.filter(
		func (cell_state: CellState): return not cell_state.ai_excluded()
	)
	if best_weight == 0.0 or len(cells_states) == 0:
		return agent_cell

	var best_cell := agent_cell
	cells_states.shuffle()
	for cell_state: CellState in cells_states.slice(0, max_samples):
		var distance := (cell_state.position - coords).length()
		var weight := get_ai_target_weight(cell_state, distance)
		if weight < best_weight:
			if weight == 0.0:
				return cell_state
			best_weight = weight
			best_cell = cell_state

	return best_cell
