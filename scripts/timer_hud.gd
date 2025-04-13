extends Control

@onready var label: Label = $label
var timer: Timer

func _process(_dt: float):
	label.text = "%02d" % timer.time_left
