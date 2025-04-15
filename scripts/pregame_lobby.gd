extends Node2D

signal start_game(player_ids)

@onready var _start_area: Area2D = %Area2D_StartGame
@onready var _label_above_start_area: Label = %label_above_start_area
@onready var _timer_game_start: Timer = $TimerGameStart
@onready var _timer_duration: float = $TimerGameStart.wait_time

var _will_start_when_timer_ends := false
var _freeze_starting_players := false
var _players_ready_ids := []
var _nb_players_ready = 0
const _freeze_duration_before_start: float = 1.

func _enter_tree():
	# When returning to the lobby after having played a game with <4 players,
	# we need to display 4 players just like before the first game.
	# Since we share player.tscn with game.tscn, and since player.tscn
	# reads GameState.players during _ready, then we need to reset the players before that.
	# Yup, the principles of encapsulation and single-responsiblity sob silently.
	GameState.players_to_start_next_game_with = [1,2,3,4]
	GameState.reset()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_timer_game_start.timeout.connect(_on_timer_end)
	# this signal listener could be moved outside of this script
	start_game.connect(func(player_ids):
		GameState.players_to_start_next_game_with = player_ids
		get_tree().change_scene_to_file("res://scenes/game.tscn"))

func _physics_process(_dt: float) -> void:
	if not _freeze_starting_players:
		_players_ready_ids = _start_area.get_overlapping_bodies().map(func(p: Player): return p.id)
	var _prev_nb = _nb_players_ready
	_nb_players_ready = len(_players_ready_ids)
	
	if _nb_players_ready <= 1:
		_label_above_start_area.text = "v Start v"
		_will_start_when_timer_ends = false # ignore timer
	else:
		if not _will_start_when_timer_ends or _prev_nb != _nb_players_ready:
			_will_start_when_timer_ends = true
			_timer_game_start.start(_timer_duration)
		var time_left = ceil(_timer_game_start.time_left)
		if time_left > 0:
			_label_above_start_area.text = "Starting in %d" % time_left
		else:
			_label_above_start_area.text = "Starting..."

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_quit"):
		get_tree().quit()

func _on_timer_end():
	if not _will_start_when_timer_ends:
		return
	_freeze_starting_players = true
	await get_tree().create_timer(_freeze_duration_before_start).timeout	
	start_game.emit(_players_ready_ids)
