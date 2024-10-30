extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var asteroid_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(asteroid_types[randi() % asteroid_types.size()])

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
