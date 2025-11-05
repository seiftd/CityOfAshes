extends Node2D

## Level1 - سكريبت المستوى الأول
## يدير البيئة والأعداء والانتقالات

@onready var hud: CanvasLayer = $HUD
@onready var portal: Area2D = $PortalEnd
@onready var music_player: AudioStreamPlayer2D = $Music
@onready var ambient_player: AudioStreamPlayer2D = $Ambient
@onready var camera: Camera2D = $Camera2D

var player: Node2D = null

func _ready():
	# إعداد الموسيقى والصوت
	if music_player:
		music_player.play()
	
	if ambient_player:
		ambient_player.play()
	
	# البحث عن اللاعب
	player = get_tree().get_first_node_in_group("player")
	if player and camera:
		camera.target = player
	
	# ربط Portal
	if portal:
		portal.level_complete.connect(_on_level_complete)
	
	# إخفاء HUD بعد 10 ثواني
	if hud:
		await get_tree().create_timer(10.0).timeout
		var tutorial_label = hud.get_node_or_null("TutorialLabel")
		if tutorial_label:
			var tween = create_tween()
			tween.tween_property(tutorial_label, "modulate:a", 0.0, 1.0)

func _on_level_complete():
	print("Level 1 completed!")
	
	# انتقال ناعم
	var tween = create_tween()
	tween.tween_property(get_viewport(), "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	# الانتقال للمستوى التالي
	if GameManager:
		GameManager.complete_level()
		await get_tree().create_timer(0.5).timeout
		GameManager.goto_level(2)

