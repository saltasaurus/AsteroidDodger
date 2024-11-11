extends Area2D

signal hit

@export var thrusters: Array[CPUParticles2D]
# BUG: When exporting, Player isn't initialized before and sets to NULL
# Unsure how to defer setting values until Player initialized. 
@export var speed = 10
@export var max_speed = 500
var stop_distance = 50

var screen_size: Vector2 # Size of the game window
var mouse_left_down: bool = false # Don't move on start
var mouse_position = null
var velocity: Vector2
var player_radius: Vector2
var can_move: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	# start(screen_size / 2)
		
func start(pos, is_activated: bool):
	"""Sets up player so that it is visible, can be moved,
	and interacts with the main scene"""

	position = pos
	
	# Enable collisions if activated
	$CollisionShape2D.disabled = !is_activated
	player_radius = $CollisionShape2D.shape.get_rect().size / 2

	can_move = is_activated
	velocity = Vector2.ZERO

	show()

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

func emit_thruster_particles(emit: bool = false):
	"""Enables and disables all CPUParticle2D nodes emitting property together"""
	for thruster in thrusters:
		thruster.emitting = emit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	
	# Calculate velocity and face mouse cursor
	var is_thrusting = handle_thrust()
	look_at(mouse_position)

	# Tell thrusters to emit only when thrusting
	emit_thruster_particles(is_thrusting)
	
	# Allows rotation and thruster particles, but not positional changes
	if !can_move:
		return
	
	var max_boundary = screen_size - player_radius

	# Move Player based on calculated velocity but prevent going off screen
	position += velocity * delta
	position = position.clamp(player_radius, max_boundary)

	# Create a hard stop at window boundaries.
	# Prevents acceleration lag when turning away from wall due to position clamping
	if position.x == player_radius.x or position.x == max_boundary.x:
		velocity.x = 0
	if position.y == player_radius.y or position.y == max_boundary.y:
		velocity.y = 0

func _on_body_entered(_body:Node2D) -> void:
	"""Makes sprite invisible, emits the hit signal, and turns off collider"""
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
