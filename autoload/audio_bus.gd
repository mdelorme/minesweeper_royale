extends Node

var streams: Array[AudioStreamPlayer2D]
var nstream_max := 10
var rng : RandomNumberGenerator

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	for i in range(nstream_max):
		var asp2d := AudioStreamPlayer2D.new()
		streams.append(asp2d)
		add_child(asp2d)
		
func play_sound(sound: AudioStreamWAV, variation:float = 0.5, playback_speed: float = 1.0) -> void:
	for i in range(nstream_max):
		if not streams[i].playing:
			streams[i].stream = sound
			streams[i].pitch_scale = playback_speed + (rng.randf() - 0.5) * variation 
			streams[i].play()
			break
