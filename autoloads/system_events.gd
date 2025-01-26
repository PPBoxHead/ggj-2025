extends Node

## Emitted when the New Game button is pressed on the menu, it should load the 1st scene and reset all the player stats
signal game_new_run_start_requested
## Emitted when the Continue button is pressed, also emits game_paused_request(false), just a return to play a current run
signal game_continue_run_requested
## This one triggers when the soap value is the max one
signal game_run_finished
## When this is emitted, it should show the main menu and pause the game with game_paused_requested(true)
signal game_menu_requested
## Emitted when player press [ESC] button on the keyboard
## it should show the main menu and pause the game when paused is set to true
## when paused is false, should change some menu things also
signal game_paused_requested(paused: bool)

## Emitted when the game starts loading a scene
signal game_loading_started
## Emitted when the game finishes loading a scene
signal game_loading_finished


signal character_dialogue_requested()
signal character_comment_requested()

signal player_interaction_requested(interaction_type: String)

signal bubble_soap_collected(soap_value: int)

signal start_combat(enemy: Node3D)
signal finish_combat
