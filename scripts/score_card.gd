extends MarginContainer

var init_pos := -273
@onready var score_containers := [$HBoxContainer/ScoreContainer, $HBoxContainer/ScoreContainer2, $HBoxContainer/ScoreContainer3, $HBoxContainer/ScoreContainer4]
var tween : Tween
var cooldown : float

func _ready() -> void:
	EventBus.on_game_reset.connect(on_game_reset)
	
func _process(delta: float) -> void:
	cooldown -= delta
	
func on_game_reset() -> void:
	visible = false
	position.y = init_pos
	
func on_show() -> void:
	visible = true
	for score_container in score_containers:
		score_container.reset()
		
	tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	
	for score_container in score_containers:
		await score_container.update()
		
func _unhandled_input(event: InputEvent) -> void:
	if not visible or cooldown > 0.0:
		return
	for i in range(4):
		if event.is_action_pressed("dig_p%d" % [i]):
			if tween.is_running():
				tween.set_speed_scale(10000.0)
			else:
				tween = get_tree().create_tween()
				tween.tween_property(self, "position", Vector2(0.0, init_pos), 0.25).set_ease(Tween.EASE_OUT)
				await tween.finished
				EventBus.on_game_restarted.emit()
			cooldown = 0.5
