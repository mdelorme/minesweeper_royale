extends Node2D

@onready var map : Map = $Map
@onready var timer : Timer = $TimerGameEnd
@onready var crowns: Array[Control] = [%Score_p1/Markers/Box/Crown,%Score_p2/Markers/Box/Crown,%Score_p3/Markers/Box/Crown,%Score_p4/Markers/Box/Crown]
@onready var skulls: Array[Control] = [%Score_p1/Markers/Box/Skull,%Score_p2/Markers/Box/Skull,%Score_p3/Markers/Box/Skull,%Score_p4/Markers/Box/Skull]

const dig_sound            := preload("res://sounds/dig.wav")
const explosion_sound      := preload("res://sounds/explosion.wav")
const flag_on_sound        := preload("res://sounds/flag_on.wav")
const flag_off_sound       := preload("res://sounds/flag_off.wav")
const explosion_scene      := preload("res://scenes/explosion.tscn")
const detonated_mine_scene := preload("res://scenes/detonated_mine.tscn")

var time := 0.0
var squish_scale : float = 0.1
var time_scale   : float = 10.0

func _ready() -> void:
	## Connecting to relevant signals of the event bus
	EventBus.on_player_dig.connect(on_player_dig)
	EventBus.on_player_flag.connect(on_player_flag)
	EventBus.on_player_score.connect(on_player_score)
	EventBus.on_game_ended.connect(on_game_ended)
	EventBus.on_game_restarted.connect(on_game_restarted)
	EventBus.on_explosion.connect(on_explosion)
	EventBus.on_reveal_mine.connect(on_reveal_mine)
	timer.timeout.connect(on_timer_end)
	
	%TimerHud.timer = timer
	
	toggle_players(false)
	
	%Counter1.modulate.a = 0.0
	%Counter2.modulate.a = 0.0
	%Counter3.modulate.a = 0.0
	%Counter4.modulate.a = 0.0
	
	var tween := get_tree().create_tween()
	%FadeRect.modulate.a = 1.0
	%FadeRect.visible = true
	%GreyRect.visible = true
	tween.tween_property(%FadeRect, "modulate:a", 0.0, 0.2)
	await tween.finished
	
	const max_scale := 1.5
	for i in range(4, 0, -1):
		tween = get_tree().create_tween()
		var counter := get_node("CanvasLayer/CenterContainer/Counter%d" % i)
		tween.tween_property(counter, "modulate:a", 1.0, 0.1)
		tween.tween_property(counter, "scale", Vector2(max_scale, max_scale), 1.5)
		tween.tween_property(counter, "modulate:a", 0.0, 0.3)
		await tween.finished
		
	%GreyRect.visible = false
	toggle_players(true)
	timer.start()
	
func toggle_players(active: bool) -> void:
	for i in range(4):
		get_node("Player%d" % (i+1)).active = active

func on_player_dig(pos: Vector2, player_id: int) -> void:
	var map_position := map.pos_to_tile(pos)
	var map_state := GameState.map
	if map_state.get_cell(map_position).diggable():
		AudioBus.play_sound(dig_sound, map_position, 0.2)
		## Player is still alive, score increased
		if not map_state.player_digs(map_position, player_id):
			AudioBus.play_sound(explosion_sound)
			kill_player(player_id)


func on_player_flag(pos: Vector2, player_id: int) -> void:
	var map_position := map.pos_to_tile(pos)
	var map_state := GameState.map
	var changed := map_state.player_flag(map_position, player_id)
	if changed:
		if map_state.get_cell(map_position).flagged():
			AudioBus.play_sound(flag_on_sound, map_position, 0.2)
		else:
			AudioBus.play_sound(flag_off_sound, map_position, 0.2)

func on_player_score(player_id: int, score: int) -> void:
	GameState.players[player_id-1].score += score
	EventBus.on_update_player_score.emit(player_id)
	
func on_explosion(pos: Vector2i) -> void:
	var new_explosion := explosion_scene.instantiate()
	new_explosion.global_position = map.tile_to_pos(pos)
	add_child(new_explosion)

func kill_player(player_id: int) -> void:
	var player: Player = get_node("Player%d" % [player_id])
	assert(player)
	player.die()
	if GameState.nb_players_alive == 1:
		EventBus.on_game_ended.emit()

func on_timer_end():
	EventBus.on_game_ended.emit()

func on_game_ended() -> void:
	timer.stop()
	for i in range(4):
		get_node("Player%d" % [i+1]).active = false
	%GreyRect.material.set_shader_parameter("alpha", 0.0);
	%GreyRect.visible = true
	var tween := get_tree().create_tween()
	tween.tween_property(%GreyRect, "material:shader_parameter/alpha", 1.0, 0.5)
	await tween.finished
	$CanvasLayer/ScoreCard.on_show()
		
func on_game_restarted() -> void:
	var tween := get_tree().create_tween()
	%FadeRect.modulate.a = 0.0
	%FadeRect.visible = true
	tween.tween_property(%FadeRect, "modulate:a", 1.0, 0.2)
	await tween.finished
	GameState.randomize_next_game()
	get_tree().reload_current_scene()
	
func on_reveal_mine(pos: Vector2i) -> void:
	var new_mine := detonated_mine_scene.instantiate()
	new_mine.global_position = map.tile_to_pos(pos)
	add_child(new_mine)

func _process(_dt):
	time += _dt
	GameState.compute_leaders()
	for i in range(4):
		crowns[i].visible = GameState.players[i].is_leader
		skulls[i].visible = GameState.players[i].is_dead()
		
		crowns[i].get_node("Control/Sprite").scale = Vector2(1.0, 1.0) + Vector2(cos(time*time_scale), sin(time*time_scale))*squish_scale
		skulls[i].get_node("Control/Sprite").scale  = Vector2(1.0, 1.0) + Vector2(cos(time*time_scale+0.213), sin(time*time_scale+0.234))*squish_scale
