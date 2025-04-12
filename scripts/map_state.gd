extends Node
class_name MapState


# TODO: Replace with Array[Array[CellState]] when Godot supports it.
var grid: Array[Array]
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
	grid = []
	grid.resize(height)
	for y in range(height):
		var row: Array[CellState] = []
		row.resize(width)
		grid[y] = row
		for x in range(width):
			row[x] = CellState.new()


func increment_neighbors(x: int, y: int):
	for dy: int in [-1, 0, 1]:
		for dx: int in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var x2 := x + dx
			var y2 := y + dy
			if x2 < 0 or x2 >= width or y2 < 0 or y2 >= height:
				continue
			var cell_state: CellState = grid[y2][x2]
			cell_state.secret = min(cell_state.secret + 1, CellState.Secret.MINED)


func add_mines() -> void:
	assert(
		mines_count <= width * height,
		"ERROR: More mines than cells in this map!"
	)
	
	while mines_count > 0:
		var x := randi_range(0, width - 1)
		var y := randi_range(0, height - 1)
		var cell_state: CellState = grid[y][x]
		if cell_state.secret == CellState.Secret.MINED:
			continue
		cell_state.secret = CellState.Secret.MINED
		increment_neighbors(x, y)
		mines_count -= 1

func get_cell(position: Vector2i) -> CellState:
	return grid[position.y][position.x]

func player_digs(position: Vector2i, player_id: int, propagate: bool = true) -> bool:
	## Returns true if the player is still alive, false otherwise
	var cell_state : CellState = grid[position.y][position.x]
	cell_state.interaction = CellState.Interaction.DUG
	cell_state.owner_id = player_id
	
	## Propagate if cell is empty
	if propagate and cell_state.secret == 0:
		for i in range(-1, 2):
			var nx := position.x + i
			if nx < 0 or nx > width-1:
				continue
				
			for j in range(-1, 2):
				var ny := position.y + j
				if ny < 0 or ny >= height-1:
					continue
				
				var new_pos := Vector2i(nx, ny)
				if is_cell_diggable(new_pos):
					player_digs(new_pos, player_id, false)
	EventBus.on_tile_update.emit(position)
	var dead := cell_state.secret == CellState.Secret.MINED
	var score := cell_state.secret if not dead else 0
	EventBus.on_player_score.emit(player_id, score)
	return not dead 

func player_flag(position: Vector2i, player_id: int) -> bool:
	var cell := get_cell(position)
	var changed := cell.toggle_flag(player_id)
	if changed:
		EventBus.on_tile_update.emit(position)
	return changed

func get_score_at(position: Vector2i) -> int:
	var cell_state : CellState = grid[position.y][position.x]
	if cell_state.secret == CellState.Secret.MINED:
		return 0
	else:
		return cell_state.secret
