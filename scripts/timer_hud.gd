extends Control

@onready var label: Label = $label
var timer: Timer

func _process(_dt: float):
	label.text = "%d" % timer.time_left
