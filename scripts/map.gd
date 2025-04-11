extends TileMapLayer


func update_tile(coords: Vector2i):
	var atlas_coords := Vector2i(29, 6)
	var secret: CellState.Secret = GameState.map.grid[coords.y][coords.x].secret
	if secret == 0:
		atlas_coords = Vector2i(26, 9)
	else:
		atlas_coords = Vector2i(16 + secret, 9)

	set_cell(coords, 0, atlas_coords)


func update_tiles():
	var map := GameState.map
	for y in map.height:
		for x in map.width:
			update_tile(Vector2i(x, y))


func _ready():
	EventBus.on_game_reset.connect(update_tiles)
	GameState.reset()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		GameState.reset()
