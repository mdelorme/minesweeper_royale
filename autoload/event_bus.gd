extends Node

signal on_game_reset()
signal on_game_ended()
signal on_game_restarted()
signal on_player_die()
signal on_player_dig(position: Vector2, player_id: int)
signal on_player_flag(position: Vector2, player_id: int)
signal on_player_score(player_id: int, score: int)
signal on_update_player_score(player_id: int)
signal on_tile_update(coord: Vector2i)
signal on_explosion(coord: Vector2i)
signal on_reveal_mine(coord: Vector2i)

func _input(ev: InputEvent):
	if ev.is_action_pressed("dev_end_game"):
		on_game_ended.emit()
