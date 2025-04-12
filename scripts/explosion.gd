extends AnimatedSprite2D

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rotate(rng.randf()*PI)
	play('default')

func _on_animation_finished() -> void:
	queue_free()



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
