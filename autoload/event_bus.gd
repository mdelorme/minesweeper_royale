extends Node

signal on_game_reset()
signal on_player_dig(position: Vector2, player_id: int)
signal on_player_rename(id: int, new_name: String)
signal on_player_score(player_id: int, score: int)
signal on_tile_update(coord: Vector2i)
