extends Node2D
class_name Map

static var gained_points_scene := preload("res://scenes/gained_points.tscn")

@onready var numbers: TileMapLayer = $Numbers
@onready var terrain: TileMapLayer = $Terrain


func pos_to_tile(_global_position: Vector2) -> Vector2i:
	return terrain.local_to_map(to_local(_global_position)).clamp(
		Vector2i(0, 0),
		Vector2i(GameState.map.width - 1, GameState.map.height - 1)
	)

func tile_to_pos(_coord: Vector2i) -> Vector2:
	return to_global(terrain.map_to_local(_coord))
	
func snap_to_grid(_global_position: Vector2) -> Vector2:
	return to_global(terrain.map_to_local(pos_to_tile(_global_position)))

func add_gained_points(cell_state: CellState) -> void:
	var gained_points: GainedPoints = gained_points_scene.instantiate()
	gained_points.value = cell_state.secret
	gained_points.owner_id = cell_state.owner_id
	add_child(gained_points)
	gained_points.position = (
		terrain.map_to_local(cell_state.position) - Vector2(terrain.tile_set.tile_size) / 2.0
	)

func update_tile(cell_state: CellState) -> void:
	## Numbers
	var atlas_coords := Vector2i(0, 3)
	var source_id := 0
	## Hide the number if not dug
	if cell_state.dug():
		var secret: CellState.Secret = cell_state.secret
		if secret == 0:
			atlas_coords = Vector2i(0, 3)
		elif secret == 9:
			atlas_coords = Vector2i(1, 0)
		else:
			atlas_coords = Vector2i(1 + secret, cell_state.owner_id-1)
			if cell_state.owner_id < 5:
				add_gained_points(cell_state)
	elif cell_state.flagged():
		source_id = 0
		atlas_coords = Vector2i(14, cell_state.owner_id - 1)

	numbers.set_cell(cell_state.position, source_id, atlas_coords)
	
	## Terrain
	if cell_state.dug():
		atlas_coords = Vector2i(0, 0)
	else:
		atlas_coords = Vector2i(0, 1)
	terrain.set_cell(cell_state.position, 0, atlas_coords)


func update_tiles() -> void:
	for cell_state: CellState in GameState.map.cells.values():
		update_tile(cell_state)


func _ready() -> void:
	EventBus.on_game_reset.connect(update_tiles)
	EventBus.on_tile_update.connect(update_tile)
	GameState.reset()
