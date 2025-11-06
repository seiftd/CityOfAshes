extends Control

## StartMenu - قائمة البدء
## يدير الأزرار والانتقالات

@onready var new_game_button: Button = $ButtonsContainer/NewGameButton
@onready var reload_button: Button = $ButtonsContainer/ReloadButton
@onready var stage_button: Button = $ButtonsContainer/StageButton
@onready var shop_button: Button = $ButtonsContainer/ShopButton
@onready var back_button: Button = $ButtonsContainer/BackButton
@onready var button_fx: AnimationPlayer = $ButtonFX
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

var buttons: Array[Button] = []

func _ready():
	# جمع جميع الأزرار
	buttons = [new_game_button, reload_button, stage_button, shop_button, back_button]
	
	# إعداد الأزرار
	_setup_buttons()

func _setup_buttons():
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
		new_game_button.mouse_entered.connect(func(): _on_button_hover(new_game_button))
		new_game_button.mouse_exited.connect(func(): _on_button_exit(new_game_button))
	
	if reload_button:
		reload_button.pressed.connect(_on_reload_pressed)
		reload_button.mouse_entered.connect(func(): _on_button_hover(reload_button))
		reload_button.mouse_exited.connect(func(): _on_button_exit(reload_button))
	
	if stage_button:
		stage_button.pressed.connect(_on_stage_pressed)
		stage_button.mouse_entered.connect(func(): _on_button_hover(stage_button))
		stage_button.mouse_exited.connect(func(): _on_button_exit(stage_button))
	
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)
		shop_button.mouse_entered.connect(func(): _on_button_hover(shop_button))
		shop_button.mouse_exited.connect(func(): _on_button_exit(shop_button))
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.mouse_entered.connect(func(): _on_button_hover(back_button))
		back_button.mouse_exited.connect(func(): _on_button_exit(back_button))

func _on_button_hover(button: Button):
	# تأثير hover - تكبير
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)
	
	# تأثير glow
	if button_fx:
		button_fx.play("HoverHighlight")
	
	# تشغيل صوت hover
	_play_hover_sound()

func _on_button_exit(button: Button):
	# إرجاع الحجم الطبيعي
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_new_game_pressed():
	_play_click_sound()
	_transition_to_scene("res://Scenes/Levels/Level1.tscn")

func _on_reload_pressed():
	_play_click_sound()
	# محاولة تحميل آخر حفظ
	if has_node("/root/SaveManager"):
		var save_manager = get_node("/root/SaveManager")
		if save_manager.has_method("load_last_save"):
			save_manager.load_last_save()
		else:
			print("SaveManager.load_last_save() not available, starting new game")
			_transition_to_scene("res://Scenes/Levels/Level1.tscn")
	else:
		print("SaveManager not found, starting new game")
		_transition_to_scene("res://Scenes/Levels/Level1.tscn")

func _on_stage_pressed():
	_play_click_sound()
	_transition_to_scene("res://Scenes/UI/StageSelect.tscn")

func _on_shop_pressed():
	_play_click_sound()
	_transition_to_scene("res://Scenes/UI/ShopMenu.tscn")

func _on_back_pressed():
	_play_click_sound()
	_transition_to_scene("res://Scenes/UI/MainMenu.tscn")

func _transition_to_scene(path: String):
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await fade_out.finished
	
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		print("Scene not found: ", path)
		# إرجاع fade in
		var fade_in = create_tween()
		fade_in.tween_property(self, "modulate:a", 1.0, 0.5)

func _play_hover_sound():
	if hover_sound:
		if ResourceLoader.exists("res://assets/sfx/button_hover.mp3"):
			var hover_file = load("res://assets/sfx/button_hover.mp3")
			if hover_file:
				hover_sound.stream = hover_file
				hover_sound.volume_db = -8.0
				hover_sound.play()
				return
		
		# استخدام click sound كـ backup
		if click_sound:
			click_sound.volume_db = -12.0
			click_sound.play()

func _play_click_sound():
	if click_sound:
		if ResourceLoader.exists("res://assets/sfx/button_click.mp3"):
			var click_file = load("res://assets/sfx/button_click.mp3")
			if click_file:
				click_sound.stream = click_file
				click_sound.volume_db = -5.0
				click_sound.play()

