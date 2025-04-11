extends Node

signal on_game_reset()
signal on_player_dig(position: Vector2, player_id: int)
signal on_player_rename(id: int, new_name: String)
