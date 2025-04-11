extends CharacterBody2D
class_name Player

static var player_counter: int
var player_name: String
var player_id: int

## Input and actions
const INPUT_SCALE := 250.0
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
	player_name = "Player_%d" % [player_counter]
	player_id = player_counter
	player_counter += 1
	
	$PlayerName.text = player_name
	
	action_map.append('move_left_p%d'  % [player_id])
	action_map.append('move_right_p%d' % [player_id])
	action_map.append('move_up_p%d'    % [player_id])
	action_map.append('move_down_p%d'  % [player_id])
	action_map.append('dig_p%d'   % [player_id])
	action_map.append('flag_p%d'  % [player_id])
	
func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector( action_map[Actions.ACTION_LEFT], 
								 action_map[Actions.ACTION_RIGHT], 
								 action_map[Actions.ACTION_UP], 
								 action_map[Actions.ACTION_DOWN]) * INPUT_SCALE
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(action_map[Actions.ACTION_DIG]):
		EventBus.on_player_dig.emit(position, player_id)

func rename(new_name: String) -> void:
	player_name = new_name
	$PlayerName.text = player_name
