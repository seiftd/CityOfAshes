extends Node

## GameManager - يدير حالات اللعبة والانتقالات بين المشاهد
## يجب إضافته كـ Autoload في Project Settings

signal level_completed(level_number: int)
signal player_died
signal game_over

var current_level: int = 1
var player_health: int = 100
var player_score: int = 0

func _ready():
	print("GameManager initialized")

## الانتقال إلى مستوى معين
func goto_level(level_number: int):
	current_level = level_number
	var level_path = "res://Scenes/Levels/Level" + str(level_number) + ".tscn"
	
	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)
	else:
		print("Error: Level scene not found: ", level_path)

## إكمال المستوى
func complete_level():
	level_completed.emit(current_level)
	print("Level ", current_level, " completed!")

## العودة للقائمة الرئيسية
func goto_main_menu():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

## إعادة تشغيل المستوى الحالي
func restart_level():
	goto_level(current_level)

