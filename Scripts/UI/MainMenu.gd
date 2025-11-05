extends Control

## MainMenu - القائمة الرئيسية للعبة
## يتضمن intro animation، أزرار، موسيقى، وتأثيرات

@onready var intro_texture: TextureRect = $IntroContainer/IntroTexture
@onready var main_container: VBoxContainer = $MainContainer
@onready var background: TextureRect = $Background
@onready var logo_label: Label = $MainContainer/LogoLabel
@onready var buttons_container: VBoxContainer = $MainContainer/ButtonsContainer
@onready var start_button: Button = $MainContainer/ButtonsContainer/StartButton
@onready var settings_button: Button = $MainContainer/ButtonsContainer/SettingsButton
@onready var exit_button: Button = $MainContainer/ButtonsContainer/ExitButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var camera: Camera2D = $Camera2D

var intro_duration: float = 3.0
var fade_duration: float = 1.0

func _ready():
	# إخفاء القائمة الرئيسية في البداية
	main_container.modulate.a = 0.0
	main_container.visible = false
	
	# إضافة تأثير glow للشعار
	_setup_logo_glow()
	
	# بدء intro animation
	_play_intro()
	
	# إعداد الأزرار
	_setup_buttons()
	
	# بدء الموسيقى
	if music_player:
		music_player.play()
	
	# بدء camera animation
	_start_camera_animation()

func _play_intro():
	# إظهار intro image
	if intro_texture:
		intro_texture.modulate.a = 0.0
		intro_texture.visible = true
		
		# fade in
		var fade_in = create_tween()
		fade_in.tween_property(intro_texture, "modulate:a", 1.0, fade_duration)
		
		# انتظار
		await get_tree().create_timer(intro_duration).timeout
		
		# fade out
		var fade_out = create_tween()
		fade_out.tween_property(intro_texture, "modulate:a", 0.0, fade_duration)
		await fade_out.finished
		
		intro_texture.visible = false
	
	# إظهار القائمة الرئيسية
	_show_main_menu()

func _show_main_menu():
	main_container.visible = true
	main_container.modulate.a = 0.0
	
	# fade in للقائمة
	var fade_in = create_tween()
	fade_in.tween_property(main_container, "modulate:a", 1.0, fade_duration)

func _setup_logo_glow():
	if logo_label:
		# إضافة تأثير glow للشعار
		var glow_tween = create_tween()
		glow_tween.set_loops()
		glow_tween.tween_property(logo_label, "modulate", Color(0.2, 0.8, 1.0, 1.0), 1.5)
		glow_tween.tween_property(logo_label, "modulate", Color(1.0, 0.6, 0.2, 1.0), 1.5)
		glow_tween.tween_property(logo_label, "modulate", Color.WHITE, 1.5)

func _setup_buttons():
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		start_button.mouse_entered.connect(func(): _on_button_hover(start_button))
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
		settings_button.mouse_entered.connect(func(): _on_button_hover(settings_button))
	
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)
		exit_button.mouse_entered.connect(func(): _on_button_hover(exit_button))

func _on_button_hover(button: Button):
	# استخدام button_click كـ hover sound إذا لم يكن hover موجود
	if hover_sound:
		var hover_file = load("res://assets/sfx/button_hover.mp3")
		if hover_file and ResourceLoader.exists("res://assets/sfx/button_hover.mp3"):
			hover_sound.stream = hover_file
			hover_sound.volume_db = -8.0
			hover_sound.play()
		elif click_sound:
			# استخدام click sound كـ backup
			click_sound.volume_db = -10.0
			click_sound.play()
	
	# تأثير hover
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_start_button_pressed():
	_play_click_sound()
	_transition_to_game()

func _on_settings_button_pressed():
	_play_click_sound()
	_transition_to_settings()

func _on_exit_button_pressed():
	_play_click_sound()
	_quit_game()

func _play_click_sound():
	if click_sound:
		click_sound.play()

func _transition_to_game():
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	await fade_out.finished
	
	# الانتقال للمستوى الأول
	get_tree().change_scene_to_file("res://Scenes/Levels/Level1.tscn")

func _transition_to_settings():
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	await fade_out.finished
	
	# الانتقال لإعدادات (سيتم إنشاؤها لاحقاً)
	var settings_path = "res://Scenes/UI/Settings.tscn"
	if ResourceLoader.exists(settings_path):
		get_tree().change_scene_to_file(settings_path)
	else:
		print("Settings scene not found, returning to main menu")
		_transition_back()

func _transition_back():
	var fade_in = create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, fade_duration)

func _quit_game():
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	await fade_out.finished
	
	get_tree().quit()

func _start_camera_animation():
	if camera:
		# تأثير zoom وpan خفيف
		var zoom_tween = create_tween()
		zoom_tween.set_loops()
		zoom_tween.tween_property(camera, "zoom", Vector2(1.05, 1.05), 3.0)
		zoom_tween.tween_property(camera, "zoom", Vector2(1.0, 1.0), 3.0)
		
		# تأثير pan خفيف
		var pan_tween = create_tween()
		pan_tween.set_loops()
		pan_tween.tween_property(camera, "position", Vector2(10, 0), 4.0)
		pan_tween.tween_property(camera, "position", Vector2(-10, 0), 4.0)
		pan_tween.tween_property(camera, "position", Vector2(0, 0), 4.0)

