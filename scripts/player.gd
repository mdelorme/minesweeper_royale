extends CharacterBody2D
class_name Player

@export var id: int = 1
@export var map: Map
var state: PlayerState

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

func _ready() -> void:
	var index := id - 1
	state = GameState.players[index]

	EventBus.on_player_rename.connect(on_rename)
	on_rename(id, state.label)
	$PlayerName.modulate = state.color
	modulate = state.color.blend(Color(1.0, 1.0, 1.0, 0.5))
	%Highlight.modulate = state.color

	action_map.append('move_left_p%d'  % [index])
	action_map.append('move_right_p%d' % [index])
	action_map.append('move_up_p%d'    % [index])
	action_map.append('move_down_p%d'  % [index])
	action_map.append('dig_p%d'   % [index])
	action_map.append('flag_p%d'  % [index])

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector(
		action_map[Actions.ACTION_LEFT],
		action_map[Actions.ACTION_RIGHT],
		action_map[Actions.ACTION_UP],
		action_map[Actions.ACTION_DOWN],
	) * INPUT_SCALE
	if velocity.x != 0:
		%Sprite2D.flip_h = velocity.x < 0
	move_and_slide()

	%Highlight.global_position = map.snap_to_grid(global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(action_map[Actions.ACTION_DIG]):
		EventBus.on_player_dig.emit(position, id)


func on_rename(_id: int, new_name: String) -> void:
	if _id == id:
		$PlayerName.text = new_name
