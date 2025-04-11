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
