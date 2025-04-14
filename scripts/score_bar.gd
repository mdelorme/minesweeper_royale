extends Control

@onready var player_scores = [%Score_p1, %Score_p2, %Score_p3, %Score_p4]
@onready var width : float = size.x
@onready var crowns: Array[Control] = [%Score_p1/Markers/Box/Crown,%Score_p2/Markers/Box/Crown,%Score_p3/Markers/Box/Crown,%Score_p4/Markers/Box/Crown]
@onready var skulls: Array[Control] = [%Score_p1/Markers/Box/Skull,%Score_p2/Markers/Box/Skull,%Score_p3/Markers/Box/Skull,%Score_p4/Markers/Box/Skull]

var time := 0.0
var squish_scale : float = 0.1
var time_scale   : float = 10.0

func _ready() -> void:
	EventBus.on_update_player_score.connect(_on_update_player_score)
	for i in range(4):
		player_scores[i].visible = not GameState.players[i].discarded

func _process(dt: float):
	time += dt

func _on_update_player_score(player_id: int) -> void: 
	var tween := get_tree().create_tween()
	var player := GameState.players[player_id-1]
	tween.tween_property(player_scores[player_id-1], "size_flags_stretch_ratio", player.score, 0.1)

func render():
	for i in range(4):
		crowns[i].visible = GameState.players[i].is_leader
		skulls[i].visible = GameState.players[i].is_dead()
		
		crowns[i].get_node("Control/Sprite").scale = Vector2(1.0, 1.0) + Vector2(cos(time*time_scale), sin(time*time_scale))*squish_scale
		skulls[i].get_node("Control/Sprite").scale  = Vector2(1.0, 1.0) + Vector2(cos(time*time_scale+0.213), sin(time*time_scale+0.234))*squish_scale
