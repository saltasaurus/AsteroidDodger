extends Node

var asteroid_scene: PackedScene = preload("res://Scenes/Asteroid.tscn")
var score

# Base variables
const min_asteroid_speed = 100.0
const max_asteroid_speed = 250.0

# These are adjusted as game runs to increase difficulty
var score_min_asteroid_speed_add = 0.0
var score_max_asteroid_speed_add = 0.0
var max_asteroid_scale = 3

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

	score_min_asteroid_speed_add = 0
	score_max_asteroid_speed_add = 0
	max_asteroid_scale = 3

func game_over():
	$ScoreTimer.stop()
	$AsteroidTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func _on_start_timer_timeout() -> void:
	$AsteroidTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

	score_min_asteroid_speed_add += 1
	score_max_asteroid_speed_add += 2

	if score % 20 == 19:
		max_asteroid_scale += 1

func get_asteroid_spawn_location() -> PathFollow2D:
	"""Get asteroid spawn location"""

	var asteroid_spawn_location: PathFollow2D = $AsteroidPath/AsteroidSpawnLocation
	asteroid_spawn_location.progress_ratio = randf()

	return asteroid_spawn_location

func create_new_circle_collider(scale) -> CollisionShape2D:
	# Create new collider and shape, adjust radius to fit scale
	var new_collision_shape = CollisionShape2D.new()
	new_collision_shape.position = Vector2.ZERO
	var new_circle_shape = CircleShape2D.new()
	new_circle_shape.radius = scale * 16
	new_collision_shape.shape = new_circle_shape
	return new_collision_shape

func _on_asteroid_timer_timeout():
	print("Asteroid Spawning")
	# Create a new instance of the asteroid scene.
	var asteroid: RigidBody2D = asteroid_scene.instantiate()
	
	# Randomly choose a scale multiplier
	var asteroid_size_scalar = randf_range(1, max_asteroid_scale)

	# Choose a random location on Path2D.
	var spawn_location = get_asteroid_spawn_location()
	
	# Set the asteroid's position to a random location.
	asteroid.position = spawn_location.position
	
	# Set the asteroid's direction perpendicular to the path direction.
	var direction = spawn_location.rotation + PI / 2

	# Prevent asteroids from spawning halfway onto screen,
	# shift them back in the opposite direction of the normal vector
	var offset_by_size = Vector2.RIGHT.rotated(direction)
	asteroid.position -= offset_by_size * asteroid_size_scalar * 16

	# And add some randomness to the direction -> [-45, 45] degrees
	direction += randf_range(-PI / 4, PI / 4)
	asteroid.rotation = direction

	# Adjust asteroid scale to fit collider
	var asteroid_scale = Vector2(asteroid_size_scalar, asteroid_size_scalar)

	# Create a new scaled CircleShape2D collider
	var new_collision_shape: CollisionShape2D = create_new_circle_collider(asteroid_size_scalar)
	
	# Add new Collider2D with scaled CircleShape2D to asteroid
	asteroid.add_child(new_collision_shape)

	# Change scale of Sprite to match collider
	asteroid.get_node("AnimatedSprite2D").scale = asteroid_scale

	# Change screen exit scale to prevent asteroid from disappearing at its middle
	asteroid.get_node("VisibleOnScreenNotifier2D").scale = asteroid_scale

	# Change mass of asteroid based on scale
	asteroid.mass = asteroid_size_scalar

	# Randomly calculate the velocity for the asteroid
	var velocity = Vector2(
		randf_range(
			min_asteroid_speed + score_min_asteroid_speed_add,
			max_asteroid_speed + score_max_asteroid_speed_add,
			),
		0.0)
	asteroid.linear_velocity = velocity.rotated(direction)

	# Spawn the asteroid by adding it to the Main scene.
	add_child(asteroid)