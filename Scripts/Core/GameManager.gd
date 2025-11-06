extends Node

## GameManager - يدير حالات اللعبة والانتقالات بين المشاهد
## يجب إضافته كـ Autoload في Project Settings

signal level_completed(level_number: int)
signal player_died
signal game_over
signal wave_started(wave_number: int)
signal enemy_killed

var current_level: int = 1
var current_wave: int = 1
var player_health: int = 100
var player_score: int = 0
var enemies_remaining: int = 0

func _ready():
	print("GameManager initialized")

## الانتقال إلى مستوى معين
func goto_level(level_number: int):
	current_level = level_number
	current_wave = 1
	player_score = 0
	var level_path = "res://Scenes/Levels/Level" + str(level_number) + ".tscn"
	
	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)
	else:
		print("Error: Level scene not found: ", level_path)

## إكمال المستوى
func complete_level():
	level_completed.emit(current_level)
	print("Level ", current_level, " completed!")
	
	# Transition to victory or next level
	await get_tree().create_timer(2.0).timeout
	if current_level == 1:
		# Go to victory screen or next level
		var victory_path = "res://Scenes/UI/Victory.tscn"
		if ResourceLoader.exists(victory_path):
			get_tree().change_scene_to_file(victory_path)
		else:
			goto_level(2)

## العودة للقائمة الرئيسية
func goto_main_menu():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

## إعادة تشغيل المستوى الحالي
func restart_level():
	goto_level(current_level)

## Game Over
func goto_game_over():
	var game_over_path = "res://Scenes/UI/GameOver.tscn"
	if ResourceLoader.exists(game_over_path):
		get_tree().change_scene_to_file(game_over_path)
	else:
		print("GameOver scene not found, returning to main menu")
		goto_main_menu()

## Update enemies count
func set_enemies_count(count: int):
	enemies_remaining = count

func enemy_killed():
	enemies_remaining -= 1
	player_score += 100
	enemy_killed.emit()
	
	if enemies_remaining <= 0:
		complete_level()

