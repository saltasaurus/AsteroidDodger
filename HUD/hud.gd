extends CanvasLayer

@export var spaceships: Array[PackedScene]
var spaceship_index: int = 0
var player_node_id: NodePath = "Player"

signal start_game

func _ready() -> void:
	show_start_menu()

func update_score(score: int):
	"""Replace the score text with the score param
	
	Parameters
	----------
	score : int
		Current score of the game
	"""
	$ScoreLabel.text = str(score)

func show_message(text: String):
	"""Show text for timers preset amount of seconds
	
	Parameters
	----------
	text : String
		Message to be displayed
	"""

	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_character_selector() -> void:
	"""Shows left and right arrows of the character selector"""

	$CharacterSelector/LeftArrow.show()
	$CharacterSelector/RightArrow.show()

func hide_character_selector() -> void:
	"""Hides left and right arrows of the character selector"""
	
	$CharacterSelector/LeftArrow.hide()
	$CharacterSelector/RightArrow.hide()

func show_start_menu():
	"""Handle all nodes visible in the start menu"""

	$Message.text = "Dodge the asteroids!"
	$Message.show()

	show_character_selector()
	show_spaceship()

	# Make a one-shot timer and wait for it to finish
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func show_spaceship() -> void:
	var selector = $CharacterSelector
	# Attempt to get the currently displayed ship if it exists so it can be removed
	var spaceship = selector.get_node_or_null(player_node_id)
	if spaceship != null:
		# To prevent object stacking i.e. Area2D@2, rename object to prevent name collisions
		spaceship.name = "temp_ship"
		spaceship.queue_free()
	# Create a new spaceship to be displayed
	var new_spaceship = spaceships[spaceship_index % len(spaceships)].instantiate()
	var ship_position = get_parent().get_node("StartPosition").position
	new_spaceship.start(ship_position, false)
	# Set name to be exactly the node name we search for
	new_spaceship.name = StringName(player_node_id)

	# Disable collisions while in start menu to prevent leftover asteroids from colliding
	var collider = new_spaceship.get_node("CollisionShape2D")
	collider.set_deferred("disabled", true)
	selector.add_child(new_spaceship)

func show_game_over():
	"""This function is called when the player loses.
	
	Show "Game Over" for 2 seconds,
	then return to the title screen and,
	after 1 second, show the "Start" button.
	"""
	show_message("Game Over")

	# Wait until the MessageTimer has counted down
	await $MessageTimer.timeout
	# Reset to start manu
	show_start_menu()
	
func _on_start_button_pressed() -> void:
	"""When pressed, hide start button and tell other nodes the game has started"""

	$StartButton.hide()
	hide_character_selector()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	"""After message has been displayed, hide it"""

	$Message.hide()

func _on_right_arrow_pressed() -> void:
	# if spaceship_index == len(spaceships) - 1:
	# 	return

	# spaceship_index = min(spaceship_index + 1, len(spaceships) - 1)
	spaceship_index += 1
	show_spaceship()

func _on_left_arrow_pressed() -> void:
	# if spaceship_index == 0:
	# 	return
	# spaceship_index = max(spaceship_index - 1, 0)
	spaceship_index -= 1
	show_spaceship()
