extends CharacterBody2D
class_name Player

@export var id: int = 1
@export var map: Map
var state: PlayerState
var poot_sound := preload("res://sounds/poooot.wav")
var base_scale : Vector2
var time : float = 0.0
var squish_scale : float = 0.1
var time_scale   : float = 10.0
var active: bool

## Input and actions
const INPUT_SCALE := 100.0
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

func _ready() -> void:
	var index := id - 1
	active = true
	state = GameState.players[index]
	rng = RandomNumberGenerator.new()
	poot_cooldown = rng.randf_range(1.0, 20.0)

	EventBus.on_player_rename.connect(on_rename)
	on_rename(id, state.label)
	$PlayerName.modulate = state.color
	%Highlight.modulate = state.color
	%Sprite.region_rect.position.y += index * 16

	action_map.append('move_left_p%d'  % [index])
	action_map.append('move_right_p%d' % [index])
	action_map.append('move_up_p%d'    % [index])
	action_map.append('move_down_p%d'  % [index])
	action_map.append('dig_p%d'   % [index])
	action_map.append('flag_p%d'  % [index])

	base_scale = %Sprite.scale
	time = rng.randf()*PI

func _physics_process(_delta: float) -> void:
	if not active:
		return
		
	velocity = Input.get_vector(
		action_map[Actions.ACTION_LEFT],
		action_map[Actions.ACTION_RIGHT],
		action_map[Actions.ACTION_UP],
		action_map[Actions.ACTION_DOWN],
	) * INPUT_SCALE
	if velocity.x != 0:
		%Sprite.flip_h = velocity.x < 0
	move_and_slide()

	%Highlight.global_position = map.snap_to_grid(global_position)

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
		
	if event.is_action_pressed(action_map[Actions.ACTION_DIG]):
		EventBus.on_player_dig.emit(position, id)
		dig()

func _process(delta: float) -> void:
	if not active:
		return
		
	poot_cooldown = max(0.0, poot_cooldown - delta)
	if poot_cooldown == 0.0:
		AudioBus.play_sound(poot_sound, 1.0, 1.5)
		poot_cooldown = rng.randf_range(1.0, 10.0)

	## Squish
	var new_scale = base_scale + Vector2(cos(time*time_scale), sin(time*time_scale))*squish_scale
	%Sprite.scale = new_scale
	time += delta


func on_rename(_id: int, new_name: String) -> void:
	if _id == id:
		$PlayerName.text = new_name

func dig() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(%Sprite, "rotation", PI*0.5, 0.05)
	tween.tween_property(%Sprite, "rotation", 0.0, 0.05)


func die() -> void:
	active = false
	
	global_position = map.snap_to_grid(global_position)
	
	var shake_tween := get_tree().create_tween().set_loops(20)
	shake_tween.tween_property(%Sprite, "rotation", PI/8, 0.015)
	shake_tween.tween_property(%Sprite, "rotation", -PI/8, 0.015)

	var explode_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(%Sprite, "scale", Vector2(5.0, 5.0), 0.3)
	explode_tween.parallel().tween_property(%Sprite, "modulate:a", 0.0, 0.2).set_delay(0.1)
	
	explode_tween.tween_property(%Sprite, "scale", base_scale, 0.3)
	explode_tween.parallel().tween_property(%Sprite, "modulate:a", 1.0, 0.2).set_delay(0.1)
	await explode_tween.finished
	
	%Sprite.rotation = 0.0
	%Sprite.region_rect.position = Vector2(192, 0)
	%Highlight.hide()
	
	active = false
