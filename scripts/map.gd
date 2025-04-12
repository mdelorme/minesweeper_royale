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

func add_gained_points(coords: Vector2i, cell_state: CellState) -> void:
	var gained_points: GainedPoints = gained_points_scene.instantiate()
	gained_points.value = cell_state.secret
	gained_points.owner_id = cell_state.owner_id
	add_child(gained_points)
	gained_points.position = (
		terrain.map_to_local(coords) - Vector2(terrain.tile_set.tile_size) / 2.0
	)

func update_tile(coords: Vector2i) -> void:
	## Numbers
	var cell_state : CellState = GameState.map.get_cell(coords)
	var atlas_coords := Vector2i(0, 3)
	var source_id := 0
	## Hide the number if not dug
	if cell_state.dug():
		var secret: CellState.Secret = cell_state.secret
		if secret == 0:
			atlas_coords = Vector2i(0, 3)
		elif secret == 9:
			atlas_coords = Vector2i(0, 3)
		else:
			atlas_coords = Vector2i(1 + secret, cell_state.owner_id-1)
			if cell_state.owner_id < 5:
				add_gained_points(coords, cell_state)
	elif cell_state.flagged():
		source_id = 1
		atlas_coords = Vector2i(cell_state.owner_id - 1, 0)

	numbers.set_cell(coords, source_id, atlas_coords)
	
	## Terrain
	if cell_state.dug():
		atlas_coords = Vector2i(0, 0)
	else:
		atlas_coords = Vector2i(0, 1)
	terrain.set_cell(coords, 0, atlas_coords)


func update_tiles() -> void:
	var map := GameState.map
	for y in map.height:
		for x in map.width:
			update_tile(Vector2i(x, y))

func _ready() -> void:
	EventBus.on_game_reset.connect(update_tiles)
	EventBus.on_tile_update.connect(update_tile)
	GameState.reset()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		GameState.reset()
