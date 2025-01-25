extends Control

@onready var labelEnemyResult = $VSplitContainer/CenterContainer/EnemyResult
@onready var labelCombatResult = $"VSplitContainer/VBoxContainer-2/Result"
@onready var paperButton = $VSplitContainer/VBoxContainer/HBoxContainer/Paper
@onready var rockButton = $VSplitContainer/VBoxContainer/HBoxContainer/Rock
@onready var scissorsButton = $VSplitContainer/VBoxContainer/HBoxContainer/Scissors

enum Choices {PAPER = 0, ROCK = 1, SCISSORS = 2}
var enemyChoice: Choices

func _ready() -> void:
	SystemGlobals.game_can_process = false
	
	match SystemGlobals.rng.randi_range(0, 2):
		0: enemyChoice = Choices.PAPER
		1: enemyChoice = Choices.ROCK
		2: enemyChoice = Choices.SCISSORS
		_: print("WTF is going on")
	


func _on_button_pressed(button_name: String) -> void:
	var playerChoice: Choices
	match button_name:
		"paper": playerChoice = Choices.PAPER
		"rock": playerChoice = Choices.ROCK
		"scissors": playerChoice = Choices.SCISSORS
		_: print("Impossible")
	
	match enemyChoice:
		Choices.PAPER: labelEnemyResult.text = "Paper"
		Choices.ROCK: labelEnemyResult.text = "Rock"
		Choices.SCISSORS: labelEnemyResult.text = "Scissors"
	
	if playerChoice == enemyChoice:
		labelCombatResult.text = "Draw"
	else:
		if playerChoice == Choices.PAPER and enemyChoice == Choices.ROCK:
			labelCombatResult.text = "Player Wins"
		elif playerChoice == Choices.ROCK and enemyChoice == Choices.SCISSORS:
			labelCombatResult.text = "Player Wins"
		elif playerChoice == Choices.SCISSORS and enemyChoice == Choices.PAPER:
			labelCombatResult.text = "Player Wins"
		else:
			labelCombatResult.text = "Enemy Wins"
