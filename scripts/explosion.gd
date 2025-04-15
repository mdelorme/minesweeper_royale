extends CollisionShape2D

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rotate(rng.randf_range(0.0, PI))
	$AnimatedSprite2D.play('default')

func _on_animation_finished() -> void:
	queue_free()
