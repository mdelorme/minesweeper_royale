extends Node

var streams: Array[AudioStreamPlayer2D]
var nstream_max := 10
var pitch_scale_variation := 0.5
var rng : RandomNumberGenerator

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	for i in range(nstream_max):
		var asp2d := AudioStreamPlayer2D.new()
		streams.append(asp2d)
		add_child(asp2d)
		
func play_sound(sound: String) -> void:
	for i in range(nstream_max):
		if not streams[i].playing:
			streams[i].stream = load(sound)
			streams[i].pitch_scale = 1.0 + (rng.randf() - 0.5) * pitch_scale_variation 
			streams[i].play()
			break
