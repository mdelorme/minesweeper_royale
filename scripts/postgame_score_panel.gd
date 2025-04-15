extends MarginContainer

var init_pos := -273
@onready var score_containers := $ResponsiveHBox.get_children()
var tween : Tween
var cooldown : float

func _ready() -> void:
	EventBus.on_game_reset.connect(_setup)
	_setup()
	
func _process(delta: float) -> void:
	cooldown -= delta
	
func _setup() -> void:
	visible = false
	position.y = init_pos
	
func reveal() -> void:
	visible = true
	for score_container in score_containers:
		score_container.reset()
		
	tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	
	var cur_player := 0
	for score_container in score_containers:
		## Display scores
		await score_container.update()
		
		var total_counter : int = score_container.total_counter
		var final_id := 0
		
		## Calculating new position in ranking
		for i in range(cur_player): ## Todo -> Limit this to nb_players
			if $ResponsiveHBox.get_child(i).total_counter >= total_counter:
				final_id += 1
				
		print("Moving %s with score %d to position %d\n" % [score_container.name, total_counter, final_id])
		cur_player += 1
		$ResponsiveHBox.move_child(score_container, final_id)
		
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
				EventBus.on_score_screen_finish.emit()
			cooldown = 0.5
