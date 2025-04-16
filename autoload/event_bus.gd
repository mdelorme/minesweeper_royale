extends Node

signal on_game_reset()
signal on_game_ended()
signal on_score_screen_finish()
signal on_player_die(player_id: int)
signal on_player_dig(position: Vector2, player_id: int)
signal on_player_flag(position: Vector2, player_id: int)
signal on_player_score(player_id: int, score: int)
signal on_update_player_score(player_id: int)
signal on_tile_update(cell_state: CellState)
signal on_explosion(coord: Vector2i)

func _input(ev: InputEvent):
	if ev.is_action_pressed("dev_end_game"):
		on_game_ended.emit()
