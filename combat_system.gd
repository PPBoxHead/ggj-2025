extends Control

@onready var enemyHand = $VSplitContainer/CenterContainer/EnemyHand
@onready var labelEnemyResult = $VSplitContainer/CenterContainer/EnemyResult
@onready var labelCombatResult = $"VSplitContainer/VBoxContainer-2/Result"
@onready var paperButton = $VSplitContainer/VBoxContainer/HBoxContainer/Paper
@onready var rockButton = $VSplitContainer/VBoxContainer/HBoxContainer/Rock
@onready var scissorsButton = $VSplitContainer/VBoxContainer/HBoxContainer/Scissors
@onready var qtButton = $VSplitContainer/QTButton
@onready var qtTimer = $QTTimer

@export var enemyPaperHand: Texture2D
@export var enemyRockHand: Texture2D
@export var enemyScissorsHand: Texture2D

enum Choices {PAPER = 0, ROCK = 1, SCISSORS = 2}
enum MiniGameStates {PLAYER_LOSS = 0, DRAW = 1, SECOND_CHANCE = 2, PLAYER_WIN = 3}
var enemyChoice: Choices
var actualState: MiniGameStates

func _ready() -> void:
	SystemGlobals.game_can_process = false
	
	match SystemGlobals.rng.randi_range(0, 2):
		0: enemyChoice = Choices.PAPER
		1: enemyChoice = Choices.ROCK
		2: enemyChoice = Choices.SCISSORS
		_: print("WTF is going on")
		
	match enemyChoice:
		Choices.PAPER: 
			labelEnemyResult.text = "Paper"
			enemyHand.texture = enemyPaperHand
		Choices.ROCK: 
			labelEnemyResult.text = "Rock"
			enemyHand.texture = enemyRockHand
		Choices.SCISSORS: 
			labelEnemyResult.text = "Scissors"
			enemyHand.texture = enemyScissorsHand
	

func _on_button_pressed(button_name: String) -> void:
	var playerChoice: Choices
	match button_name:
		"paper": playerChoice = Choices.PAPER
		"rock": playerChoice = Choices.ROCK
		"scissors": playerChoice = Choices.SCISSORS
		_: print("Impossible")
	
	if playerChoice == enemyChoice:
		actualState = MiniGameStates.DRAW
	elif playerChoice == Choices.PAPER and enemyChoice == Choices.ROCK or	\
		playerChoice == Choices.ROCK and enemyChoice == Choices.SCISSORS or \
		playerChoice == Choices.SCISSORS and enemyChoice == Choices.PAPER:
		actualState = MiniGameStates.PLAYER_WIN
	else:
		actualState = MiniGameStates.SECOND_CHANCE
		
	match actualState:
		MiniGameStates.PLAYER_WIN: labelCombatResult.text = "Player Win"
		MiniGameStates.DRAW: 
			match enemyChoice:
				Choices.PAPER: paperButton.visible = false
				Choices.ROCK: rockButton.visible = false
				Choices.SCISSORS: scissorsButton.visible = false
		MiniGameStates.SECOND_CHANCE:
			qtButton.visible = true
			qtTimer.start()


func _on_qt_button_pressed() -> void:
	actualState = MiniGameStates.PLAYER_WIN
	labelCombatResult.text = "Player Win"


func _on_qt_timer_timeout() -> void:
	if actualState != MiniGameStates.PLAYER_WIN:
		actualState = MiniGameStates.PLAYER_LOSS
		labelCombatResult.text = "Enemy Win"
		
	qtButton.visible = false
