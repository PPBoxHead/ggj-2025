extends Control

@onready var enemyHand = $EnemyOptions/EnemyHandTexture
@onready var qtButton = $VSplitContainer/QTButton
@onready var qtTimer = $QTTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var enemyPaperHand: Texture2D
@export var enemyRockHand: Texture2D
@export var enemyScissorsHand: Texture2D

enum Choices {PAPER = 0, ROCK = 1, SCISSORS = 2}
enum MiniGameStates {PLAYER_LOSS = 0, DRAW = 1, SECOND_CHANCE = 2, PLAYER_WIN = 3, NOT_CHOOSED = 4}
var enemyChoice: Choices
var actualState: MiniGameStates
var actualEnemy: Node3D

func _ready() -> void:
	SystemEvents.start_combat.connect(start_combat)
	SystemEvents.finish_combat.connect(finish_combat)


func start_combat(enemy: Node3D) -> void:
	actualEnemy = enemy
	reset_combat()


func enemy_choice() -> void:
	match SystemGlobals.rng.randi_range(0, 2):
		0: enemyChoice = Choices.PAPER
		1: enemyChoice = Choices.ROCK
		2: enemyChoice = Choices.SCISSORS
		_: print("WTF is going on")
	
	match enemyChoice:
		Choices.PAPER: 
			enemyHand.texture = enemyPaperHand
			animation_player.play("show_enemy_hand")
		Choices.ROCK: 
			enemyHand.texture = enemyRockHand
			animation_player.play("show_enemy_hand")
		Choices.SCISSORS: 
			enemyHand.texture = enemyScissorsHand
			animation_player.play("show_enemy_hand")
	
	await animation_player.animation_finished


func _on_button_pressed(button_name: String) -> void:
	if actualState == MiniGameStates.PLAYER_WIN:
		print("This is a debug")
		return
	
	var playerChoice: Choices
	match button_name:
		"paper":
			playerChoice = Choices.PAPER
			animation_player.play("paper_choosed")
		"rock":
			playerChoice = Choices.ROCK
			animation_player.play("rock_choosed")
		"scissors":
			playerChoice = Choices.SCISSORS
			animation_player.play("scissors_choosed")
		_:
			print("Impossible")
	
	await animation_player.animation_finished
	
	enemy_choice()
	
	if playerChoice == enemyChoice:
		actualState = MiniGameStates.DRAW
	elif playerChoice == Choices.PAPER and enemyChoice == Choices.ROCK or \
		playerChoice == Choices.ROCK and enemyChoice == Choices.SCISSORS or \
		playerChoice == Choices.SCISSORS and enemyChoice == Choices.PAPER:
		actualState = MiniGameStates.PLAYER_WIN
	else:
		actualState = MiniGameStates.SECOND_CHANCE
		
	match actualState:
		MiniGameStates.PLAYER_WIN: 
			actualEnemy.die()
			SystemEvents.finish_combat.emit()
		MiniGameStates.DRAW: 
			reset_combat()
		MiniGameStates.SECOND_CHANCE:
			qtButton.visible = true
			qtTimer.start()


func finish_combat() -> void:
	print("This is finished, like, finished")
	self.visible = false
	qtTimer.stop()
	SystemEvents.bubble_soap_collected.emit(1)


func reset_combat() -> void:
	qtTimer.stop()
	qtButton.visible = false
	animation_player.play_backwards("show_enemy_hand")
	animation_player.play("RESET")
	await get_tree().create_timer(1.0).timeout
	
	actualState = MiniGameStates.NOT_CHOOSED
	self.visible = true
	animation_player.play("start_combat")
	
	await animation_player.animation_finished


func _on_qt_button_pressed() -> void:
	if actualState == MiniGameStates.PLAYER_WIN:
		print("Fast, so fast")
		return
		
	actualState = MiniGameStates.PLAYER_WIN
	actualEnemy.die()
	qtTimer.stop()
	SystemEvents.finish_combat.emit()


func _on_qt_timer_timeout() -> void:
	if actualState != MiniGameStates.PLAYER_WIN:
		actualState = MiniGameStates.PLAYER_LOSS
		reset_combat()
		return
		
	qtButton.visible = false
	SystemEvents.finish_combat.emit()
