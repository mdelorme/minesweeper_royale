extends Node

var streams: Array[AudioStreamPlayer2D]
var nstream_max := 10
var rng : RandomNumberGenerator
var mid_point : Vector2

func _ready() -> void:
	var vis_rect := get_viewport().get_visible_rect()
	mid_point = vis_rect.position + 0.5 * vis_rect.size
	rng = RandomNumberGenerator.new()
	for i in range(nstream_max):
		var asp2d := AudioStreamPlayer2D.new()
		streams.append(asp2d)
		add_child(asp2d)
		asp2d.bus = "Effects"
		
func play_sound(sound: AudioStreamWAV, position: Vector2 = mid_point, variation:float = 0.5, playback_speed: float = 1.0) -> void:
	for i in range(nstream_max):
		if not streams[i].playing:
			streams[i].global_position = position
			streams[i].stream = sound
			streams[i].pitch_scale = playback_speed + (rng.randf() - 0.5) * variation 
			streams[i].play()
			break
