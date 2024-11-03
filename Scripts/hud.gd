extends CanvasLayer

signal start_game
signal left_arrow_pressed
signal right_arrow_pressed

func update_score(score):
	$ScoreLabel.text = str(score)

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_start_menu():
	$Message.text = "Dodge the asteroids!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

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
	start_game.emit()


func _on_message_timer_timeout() -> void:
	"""After message has been displayed, hide it"""
	$Message.hide()

func _on_right_arrow_pressed() -> void:
	right_arrow_pressed.emit()

func _on_left_arrow_pressed() -> void:
	left_arrow_pressed.emit()
