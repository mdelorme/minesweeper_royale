extends Node2D
class_name Map

@onready var numbers := $Numbers
@onready var terrain := $Terrain


func snap_to_grid(_global_position: Vector2) -> Vector2:
	return to_global(terrain.map_to_local(
		terrain.local_to_map(to_local(_global_position)).clamp(
			Vector2i(0, 0),
			Vector2i(GameState.map.width - 1, GameState.map.height - 1)
		)
	))

func update_tile(coords: Vector2i) -> void:
	## Numbers
	var cell_state : CellState = GameState.map.grid[coords.y][coords.x]
	var interaction : CellState.Interaction = cell_state.interaction
	var atlas_coords := Vector2i(0, 3)
	## Hide the number if not dug
	if interaction == CellState.Interaction.DUG:
		var secret: CellState.Secret = cell_state.secret
		if secret == 0:
			atlas_coords = Vector2i(0, 3)
		elif secret == 9:
			atlas_coords = Vector2i(0, 3)
		else:
			atlas_coords = Vector2i(1 + secret, cell_state.owner_id-1)

	numbers.set_cell(coords, 0, atlas_coords)
	
	## Terrain
	if interaction == CellState.Interaction.DUG:
		atlas_coords = Vector2i(0, 0)
	else:
		atlas_coords = Vector2i(0, 1)
	terrain.set_cell(coords, 0, atlas_coords)


func update_tiles() -> void:
	var map := GameState.map
	for y in map.height:
		for x in map.width:
			update_tile(Vector2i(x, y))

func pos_to_tile(_global_position: Vector2) -> Vector2i:
	return terrain.local_to_map(to_local(snap_to_grid(_global_position)))

func _ready() -> void:
	EventBus.on_game_reset.connect(update_tiles)
	EventBus.on_tile_update.connect(update_tile)
	GameState.reset()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		GameState.reset()
