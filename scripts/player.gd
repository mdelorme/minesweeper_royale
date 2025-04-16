extends CharacterBody2D
class_name Player

@export var id: int = 1
@export var map: Map
@export var show_highlight: bool = true
@export var show_hearts: bool = true
@export var is_ai: bool = false
var state: PlayerState
var poot_sound := preload("res://sounds/poooot.wav")
var hurt_sound := preload("res://sounds/poulou_mort.wav")
var laughing_sound := preload("res://sounds/poulou_rigoulou.wav")
var base_scale : Vector2
var time : float = 0.0
var squish_scale : float = 0.1
var time_scale   : float = 10.0
var active: bool
var ai_target: CellState

## Input and actions
const SPEED := 100.0
const ACCELERATION := 4.0
var action_map: Array[String]
enum Actions {
	ACTION_LEFT,
	ACTION_RIGHT,
	ACTION_UP,
	ACTION_DOWN,
	ACTION_DIG,
	ACTION_FLAG
}

var rng : RandomNumberGenerator
var poot_cooldown : float
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hearts_rects: Array[TextureRect] = [%Heart1, %Heart2, %Heart3]
@onready var ai_update_timer: Timer = %AiUpdateTimer
@onready var ai_action_timer: Timer = %AiActionTimer

func _ready() -> void:
	var index := id - 1
	active = true
	state = GameState.players[index]
	if state.discarded:
		visible = false
		collision_layer = 0
		return
	
	rng = RandomNumberGenerator.new()
	poot_cooldown = rng.randf_range(1.0, 20.0)

	%Highlight.modulate = state.color
	%Highlight.visible = show_highlight
	%HeartsContainer.visible = show_hearts
	%Sprite.region_rect.position.y += index * 16

	action_map.append('move_left_p%d'  % [index])
	action_map.append('move_right_p%d' % [index])
	action_map.append('move_up_p%d'    % [index])
	action_map.append('move_down_p%d'  % [index])
	action_map.append('dig_p%d'   % [index])
	action_map.append('flag_p%d'  % [index])

	base_scale = %Sprite.scale
	time = rng.randf()*PI

func is_ai_on_target() -> bool:
	return map.snap_to_grid(global_position) == nav.target_position

func _physics_process(delta: float) -> void:
	if state.is_dead() or state.discarded or not active:
		return

	if is_ai:
		if is_ai_on_target() and ai_action_timer.is_stopped():
			ai_action_timer.start(randf_range(0.025, 0.05))
		else:
			var direction := global_position.direction_to(nav.get_next_path_position())
			var new_velocity := velocity.lerp(direction * SPEED, ACCELERATION * delta)
			if nav.avoidance_enabled:
				nav.velocity = new_velocity
			else:
				_on_navigation_agent_2d_velocity_computed(new_velocity)
	else:
		velocity = Input.get_vector(
			action_map[Actions.ACTION_LEFT],
			action_map[Actions.ACTION_RIGHT],
			action_map[Actions.ACTION_UP],
			action_map[Actions.ACTION_DOWN],
		) * SPEED
	if velocity.x != 0:
		%Sprite.flip_h = velocity.x < 0
	move_and_slide()

	if show_highlight:
		%Highlight.global_position = map.snap_to_grid(global_position)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _unhandled_input(event: InputEvent) -> void:
	if state.is_dead() or state.discarded or not active:
		return

	if event.is_action_pressed(action_map[Actions.ACTION_DIG]):
		dig()
	elif event.is_action_pressed(action_map[Actions.ACTION_FLAG]):
		flag()

func _process(delta: float) -> void:
	if state.is_dead() or state.discarded or not active:
		return

	poot_cooldown = max(0.0, poot_cooldown - delta)
	if poot_cooldown == 0.0:
		AudioBus.play_sound(poot_sound, global_position, 1.0, 1.5)
		poot_cooldown = rng.randf_range(1.0, 10.0)

	## Squish
	var new_scale = base_scale + Vector2(cos(time*time_scale), sin(time*time_scale))*squish_scale
	%Sprite.scale = new_scale
	time += delta

func dig() -> void:
	EventBus.on_player_dig.emit(position, id)
	var rotation_sign: float = -1.0 if %Sprite.flip_h else 1.0
	var tween := get_tree().create_tween()
	tween.tween_property(%Sprite, "rotation", PI*0.5 * rotation_sign, 0.05)
	tween.tween_property(%Sprite, "rotation", 0.0, 0.05)


func flag() -> void:
	EventBus.on_player_flag.emit(position, id)


func hit() -> void:
	if state.invincible or state.is_dead() or state.discarded or not active:
		return

	state.hearts -= 1

	if state.hearts > 0:
		state.invincible = true
		var blink_tween := get_tree().create_tween().set_loops(5)
		blink_tween.tween_property(%Sprite, "modulate:v", 2.0, 0.2)
		blink_tween.tween_property(%Sprite, "modulate:v", 1.0, 0.2)
		blink_tween.tween_callback(state.unset_invincible)

	AudioBus.play_sound(hurt_sound, global_position)
	
	for heart in range(state.MAX_HEARTS):
		hearts_rects[heart].visible = heart < state.hearts

	if state.hearts <= 0:
		die()


func die():
	var shake_tween := get_tree().create_tween().set_loops(10)
	shake_tween.tween_property(%Sprite, "rotation", PI/8, 0.015)
	shake_tween.tween_property(%Sprite, "rotation", -PI/8, 0.015)

	var explode_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(%Sprite, "scale", Vector2(5.0, 5.0), 0.3)
	explode_tween.parallel().tween_property(%Sprite, "modulate:a", 0.0, 0.2).set_delay(0.1)

	explode_tween.tween_property(%Sprite, "scale", base_scale, 0.3)
	explode_tween.parallel().tween_property(%Sprite, "modulate:a", 1.0, 0.2).set_delay(0.1)
	explode_tween.tween_callback(set_dead_sprite)
	
	active = false

	EventBus.on_player_die.emit(id)

	if GameState.nb_players_alive == 0:
		EventBus.on_game_ended.emit()


func set_dead_sprite():
	%Sprite.rotation = 0.0
	%Sprite.region_rect = Rect2(160.0, 64.0, 16.0, 16.0)
	%Highlight.hide()

	AudioBus.play_sound(laughing_sound, global_position)


func ai_think() -> void:
	ai_update_timer.start(randf_range(0.15, 0.4))


func update_ai_target() -> void:
	ai_target = GameState.map.get_ai_target(map.pos_to_tile(global_position))
	nav.target_position = map.tile_to_pos(ai_target.position)


func _on_ai_update_timer_timeout() -> void:
	if is_ai and (ai_target == null or ai_target.ai_excluded()):
		update_ai_target()


func _on_ai_action_timer_timeout() -> void:
	if is_ai_on_target():
		if ai_target.should_flag():
			flag()
			ai_think()
		elif ai_target.should_dig():
			dig()
			ai_think()
