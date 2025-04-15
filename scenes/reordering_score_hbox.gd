extends HBoxContainer

## Adapted from https://github.com/zmn-hamid/Godot-Animated-Container
var pre_sort_positions := {}

const transition_speed := 0.2

func _notification(what):
	if what == NOTIFICATION_PRE_SORT_CHILDREN:
		pre_sort_positions.clear()
		for child in get_children():
			if child is Control:
				pre_sort_positions[child] = child.position
	elif what == NOTIFICATION_SORT_CHILDREN:
		for child in get_children():
			if child is Control:
				var final_position = child.position
				create_tween().set_parallel().tween_property(
					child,
					"position",
					final_position,
					transition_speed).from(pre_sort_positions[child]).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
