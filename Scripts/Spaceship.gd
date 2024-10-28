extends Area2D

signal hit

# BUG: When exporting, Player isn't initialized before and sets to NULL
# Unsure how to defer setting values until Player initialized. 
var speed = 10
var max_speed = 500
var stop_distance = 50

var screen_size # Size of the game window
var mouse_left_down = false # Don't move on start
var mouse_position = null
var velocity
var player_radius

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	start(screen_size / 2)
		
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	player_radius = $CollisionShape2D.shape.get_rect().size / 2
	velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	"""Accepts input events"""

	# Register global flag that mouse is pressed and held
	if event is InputEventMouseButton:
		if event.button_index != 1:
			return
		mouse_left_down = event.is_pressed()

func handle_thrust() -> bool:
	"""Handles thruster movement based on mouse position
	
	This function determines the distance to the mouse and applies an acceleration
	to the player until a maximum velocity is reached when mouse is pressed

	Returns
	-------
	bool
		Whether the player is actively applying movement. 
		This is false when the mouse is not pressed, or the Player 
		is within the mouse "deadzone" 
	"""
	var is_thrusting = false
	# Only change velocity if mouse is pressed
	if mouse_left_down:
		# Direction towards mouse 
		var to_mouse = mouse_position - position
		# To prevent overshoot jitter, ignore mouse within specific distance
		if position.distance_to(mouse_position) > stop_distance:
			var acceleration = to_mouse.normalized() * speed
			velocity += acceleration
			# Clamps magnitude of velocity to max speed
			if velocity.length() > max_speed:
				velocity = velocity.normalized() * max_speed
			is_thrusting = true

	return is_thrusting

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	
	# Calculate velocity and face mouse cursor
	var is_thrusting = handle_thrust()
	look_at(mouse_position)

	# Adjust animation if "adding" movement
	$AnimatedSprite2D.animation = "thruster" if is_thrusting else "idle"

	# Move Player based on calculated velocity but prevent going off screen
	position += velocity * delta
	position = position.clamp(Vector2.ZERO + player_radius, screen_size - player_radius)
	

func _on_body_entered(_body:Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

	# TODO: Play explode animation
