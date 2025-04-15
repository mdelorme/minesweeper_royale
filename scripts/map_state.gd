extends Node
class_name MapState

const NEIGHBORS_DELTAS: Array[Vector2i] = [
	Vector2i(-1, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(1, -1),
	Vector2i(1, 0),
	Vector2i(1, 1),
]

var cells: Dictionary[Vector2i, CellState]
var width: int
var height: int
var mines_count: int

func _init(_width: int, _height: int, _mines_count: int) -> void:
	width = _width
	height = _height
	mines_count = _mines_count
	fill_empty()
	add_mines()


func fill_empty() -> void:
	for y in range(height):
		for x in range(width):
			cells[Vector2i(x, y)] = CellState.new()


func increment_neighbors(position: Vector2i):
	for delta in NEIGHBORS_DELTAS:
		var neighbor_position := position + delta
		if cells.has(neighbor_position):
			var cell_state := cells[neighbor_position]
			cell_state.secret = min(cell_state.secret + 1, CellState.Secret.MINED)


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
		increment_neighbors(position)
		mines_count -= 1

func player_digs(position: Vector2i, player_id: int, propagate: bool = true) -> bool:
	## Returns true if the player is still alive, false otherwise
	var cell_state : CellState = cells[position]
	cell_state.interaction = CellState.Interaction.DUG
	cell_state.owner_id = player_id
	print("player digs called at pos %d %d; with id %d" % [position.x, position.y, player_id])
	## Propagate if cell is empty
	if propagate and cell_state.empty():
		for delta in NEIGHBORS_DELTAS:
			var new_pos := position + delta
			if cells.has(new_pos) and cells[new_pos].diggable():
				player_digs(new_pos, player_id, false)
	EventBus.on_tile_update.emit(position)
	var cell_exploded := cell_state.mined()
	
	if not cell_exploded and player_id < 5:
		var score := cell_state.secret if not cell_exploded else 0
		EventBus.on_player_score.emit(player_id, score)
	elif cell_exploded:
		EventBus.on_reveal_mine.emit(position)
		for delta in NEIGHBORS_DELTAS:
			var new_pos := position + delta
			if cells.has(new_pos) and not cells[new_pos].dug():
				player_digs(new_pos, 5, false)
			EventBus.on_explosion.emit(new_pos)
	return not cell_exploded

func player_flag(position: Vector2i, player_id: int) -> bool:
	var changed := cells[position].toggle_flag(player_id)
	if changed:
		EventBus.on_tile_update.emit(position)
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
