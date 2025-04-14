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

func _on_timer_end():
	if not _will_start_when_timer_ends:
		return
	_freeze_starting_players = true
	await get_tree().create_timer(_freeze_duration_before_start).timeout	
	start_game.emit(_players_ready_ids)
