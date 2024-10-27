extends Node

@export var mob_scene: PackedScene = preload("res://Scenes/Asteroid.tscn")
var score

# Base variables
const min_mob_speed = 100.0
const max_mob_speed = 250.0

# These are adjusted as game runs to increase difficulty
var score_min_mob_speed_add = 0.0
var score_max_mob_speed_add = 0.0
var max_mob_scale = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func new_game():
	"""Begins a new game
	
	When the game starts, the player is placed,
	the game timer beings, and the HUD is updated

	Note: HUD.start_game must be connected for the HUD.StartButton to call this function
	"""
	
	get_tree().call_group("asteroids", "queue_free")
	score = 0
	$Music.play()
	$Player.start($StartPosition.position)
	$StartTimer.start()

	$HUD.update_score(score)
	$HUD.show_message("Get Ready")

	score_min_mob_speed_add = 0
	score_max_mob_speed_add = 0
	max_mob_scale = 3

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

	score_min_mob_speed_add += 1
	score_max_mob_speed_add += 2

	if score % 20 == 19:
		max_mob_scale += 1

func get_mob_spawn_location():
	"""Get mob spawn location"""

	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	return mob_spawn_location

func create_new_circle_collider(scale) -> CollisionShape2D:
	# Create new collider and shape, adjust radius to fit scale
	var new_collision_shape = CollisionShape2D.new()
	new_collision_shape.position = Vector2.ZERO
	var new_circle_shape = CircleShape2D.new()
	new_circle_shape.radius = scale * 16
	new_collision_shape.shape = new_circle_shape
	return new_collision_shape

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob: RigidBody2D = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var spawn_location = get_mob_spawn_location()
	
	# Set the mob's position to a random location.
	mob.position = spawn_location.position
	
	# Set the mob's direction perpendicular to the path direction.
	# And add some randomness to the direction - [-27.5, 27.5] degrees
	var direction = spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Randomly choose a scale multiplier
	var mob_size_scalar = randf_range(1, max_mob_scale)

	# Adjust mob scale to fit collider
	var mob_scale = Vector2(mob_size_scalar, mob_size_scalar)

	# Create a new scaled CircleShape2D collider
	var new_collision_shape: CollisionShape2D = create_new_circle_collider(mob_size_scalar)
	
	# Add new Collider2D with scaled CircleShape2D to mob
	mob.add_child(new_collision_shape)

	# Change scale of Sprite to match collider
	mob.get_node("AnimatedSprite2D").scale = mob_scale

	# Change mass of mob based on scale
	mob.mass = mob_size_scalar

	# Randomly calculate the velocity for the mob
	var velocity = Vector2(
		randf_range(
			min_mob_speed + score_min_mob_speed_add,
			max_mob_speed + score_max_mob_speed_add,
			),
		0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)