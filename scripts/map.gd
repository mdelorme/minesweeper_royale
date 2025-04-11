extends TileMapLayer
class_name Map


func snap_to_grid(_global_position: Vector2) -> Vector2:
	return to_global(map_to_local(
		local_to_map(to_local(_global_position)).clamp(
			Vector2i(0, 0),
			Vector2i(GameState.map.width - 1, GameState.map.height - 1)
		)
	))


func update_tile(coords: Vector2i) -> void:
	var atlas_coords := Vector2i(29, 6)
	var secret: CellState.Secret = GameState.map.grid[coords.y][coords.x].secret
	if secret == 0:
		atlas_coords = Vector2i(26, 9)
	else:
		atlas_coords = Vector2i(16 + secret, 9)

	set_cell(coords, 0, atlas_coords)


func update_tiles() -> void:
	var map := GameState.map
	for y in map.height:
		for x in map.width:
			update_tile(Vector2i(x, y))


func _ready() -> void:
	EventBus.on_game_reset.connect(update_tiles)
	GameState.reset()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		GameState.reset()
