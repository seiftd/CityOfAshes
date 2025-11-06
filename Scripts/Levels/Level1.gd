extends Node2D

## Level1 - المستوى الأول
## يدير البيئة، الأعداء، والانتقالات

@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var enemies_container: Node2D = $Enemies
@onready var items_container: Node2D = $Items
@onready var hud: CanvasLayer = $HUD
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var enemies_count: int = 0

func _ready():
	# Setup camera
	if player and camera:
		camera.position = player.position
		camera.enabled = true
		camera.make_current()
	
	# Setup music
	if music_player:
		music_player.stream = load("res://assets/music/level1_theme.ogg")
		music_player.bus = "Music"
		music_player.volume_db = -6.0
		music_player.play()
	
	# Count enemies
	_count_enemies()
	
	# Connect player signals
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
	
	# Connect GameManager
	if GameManager:
		GameManager.set_enemies_count(enemies_count)
		GameManager.enemy_killed.connect(_on_enemy_killed)

func _process(delta):
	# Update camera to follow player
	if player and camera:
		camera.position = player.position

func _count_enemies():
	enemies_count = 0
	if enemies_container:
		for child in enemies_container.get_children():
			if child.is_in_group("enemies") or child.has_method("take_damage"):
				enemies_count += 1
				if not child.is_in_group("enemies"):
					child.add_to_group("enemies")
	
	print("Level 1: ", enemies_count, " enemies spawned")

func _on_player_died():
	print("Player died in Level 1")
	if GameManager:
		GameManager.player_died.emit()
		await get_tree().create_timer(2.0).timeout
		GameManager.goto_game_over()

func _on_enemy_killed():
	enemies_count -= 1
	print("Enemies remaining: ", enemies_count)
	
	if enemies_count <= 0:
		_level_complete()

func _level_complete():
	print("Level 1 completed!")
	
	# Stop music
	if music_player:
		music_player.stop()
	
	# Play victory sound
	if sfx_player:
		var victory_sound = load("res://assets/sfx/Win-Level-Complete.ogg")
		if victory_sound:
			sfx_player.stream = victory_sound
			sfx_player.bus = "SFX"
			sfx_player.play()
	
	# Complete level
	if GameManager:
		GameManager.complete_level()
