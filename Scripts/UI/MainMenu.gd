extends Control

## MainMenu - القائمة الرئيسية مع تأثيرات بصرية متقدمة
## يدير الأزرار، التأثيرات، والانتقالات

@onready var start_button: Button = $ButtonsContainer/StartButton
@onready var settings_button: Button = $ButtonsContainer/SettingsButton
@onready var exit_button: Button = $ButtonsContainer/ExitButton
@onready var button_effects: AnimationPlayer = $ButtonEffects
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

var buttons: Array[Button] = []

func _ready():
	# جمع جميع الأزرار
	buttons = [start_button, settings_button, exit_button]
	
	# إعداد الأزرار
	_setup_buttons()
	
	# بدء تأثير glow loop
	if button_effects:
		button_effects.play("GlowLoop")

func _setup_buttons():
	for button in buttons:
		if button:
			button.pressed.connect(_on_button_pressed.bind(button))
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_exit.bind(button))

func _on_button_hover(button: Button):
	# تأثير hover - تكبير
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.07, 1.07), 0.2)
	
	# تشغيل صوت hover
	_play_hover_sound()

func _on_button_exit(button: Button):
	# إرجاع الحجم الطبيعي
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_button_pressed(button: Button):
	# تأثير click - تألق وتصغير سريع
	_play_click_sound()
	
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# تأثير glow أقوى
	var glow_tween = create_tween()
	glow_tween.tween_property(button, "modulate", Color(0.8, 1.0, 1.2, 1.0), 0.1)
	glow_tween.tween_property(button, "modulate", Color.WHITE, 0.2)
	
	# تنفيذ الإجراء
	if button == start_button:
		_on_start_button_pressed()
	elif button == settings_button:
		_on_settings_button_pressed()
	elif button == exit_button:
		_on_exit_button_pressed()

func _on_start_button_pressed():
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await fade_out.finished
	
	# الانتقال لـ StartMenu
	var start_menu_path = "res://Scenes/UI/StartMenu.tscn"
	if ResourceLoader.exists(start_menu_path):
		get_tree().change_scene_to_file(start_menu_path)
	else:
		# fallback إلى Level1 إذا لم يكن StartMenu موجود
		get_tree().change_scene_to_file("res://Scenes/Levels/Level1.tscn")

func _on_settings_button_pressed():
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await fade_out.finished
	
	# الانتقال للإعدادات
	var settings_path = "res://Scenes/UI/Settings.tscn"
	if ResourceLoader.exists(settings_path):
		get_tree().change_scene_to_file(settings_path)
	else:
		print("Settings scene not found")
		var fade_in = create_tween()
		fade_in.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_exit_button_pressed():
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await fade_out.finished
	
	get_tree().quit()

func _play_hover_sound():
	if hover_sound:
		var hover_file = load("res://assets/sfx/button_hover.mp3")
		if hover_file and ResourceLoader.exists("res://assets/sfx/button_hover.mp3"):
			hover_sound.stream = hover_file
			hover_sound.volume_db = -8.0
			hover_sound.play()
		elif click_sound:
			# استخدام click sound كـ backup
			click_sound.volume_db = -12.0
			click_sound.play()

func _play_click_sound():
	if click_sound:
		var click_file = load("res://assets/sfx/button_click.mp3")
		if click_file:
			click_sound.stream = click_file
			click_sound.volume_db = -5.0
			click_sound.play()
