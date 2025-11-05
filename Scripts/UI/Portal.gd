extends Area2D

## Portal - بوابة الانتقال للمستوى التالي

@export var next_level: int = 2
@export var portal_effect: AnimatedSprite2D

signal level_complete

func _ready():
	body_entered.connect(_on_body_entered)
	
	# إضافة تأثير بصري للبوابة
	if portal_effect:
		portal_effect.play("default")

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		_complete_level()

func _complete_level():
	# إصدار صوت النصر
	var audio_player = get_node_or_null("AudioStreamPlayer2D")
	if audio_player:
		var victory_sound = preload("res://assets/sfx/Win-Level-Complete.ogg")
		if victory_sound:
			audio_player.stream = victory_sound
			audio_player.play()
	
	# إظهار رسالة النصر
	level_complete.emit()
	
	# الانتقال للمستوى التالي بعد ثانيتين
	await get_tree().create_timer(2.0).timeout
	
	if GameManager:
		GameManager.complete_level()
		await get_tree().create_timer(1.0).timeout
		GameManager.goto_level(next_level)

