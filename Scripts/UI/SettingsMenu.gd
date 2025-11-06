extends Control

## SettingsMenu - قائمة الإعدادات
## يدير إعدادات الصوت والموسيقى

@onready var sfx_toggle: TextureButton = $VBoxContainer/HBox_SFX/ToggleButton_SFX
@onready var music_toggle: TextureButton = $VBoxContainer/HBox_Music/ToggleButton_Music
@onready var back_button: TextureButton = $VBoxContainer/BackButton
@onready var toggle_fx: AnimationPlayer = $ToggleFX

var sfx_hover: AudioStream
var sfx_click: AudioStream

func _ready():
	# تحميل الأصوات
	if ResourceLoader.exists("res://assets/sfx/button_hover.mp3"):
		sfx_hover = load("res://assets/sfx/button_hover.mp3")
	if ResourceLoader.exists("res://assets/sfx/button_click.mp3"):
		sfx_click = load("res://assets/sfx/button_click.mp3")
	
	# إعداد الأزرار
	_setup_buttons()
	
	# تحميل الإعدادات
	_load_settings()
	
	# بدء تأثير glow
	if toggle_fx:
		toggle_fx.play("GlowPulse")

func _setup_buttons():
	if sfx_toggle:
		sfx_toggle.toggled.connect(_toggle_sfx)
		sfx_toggle.mouse_entered.connect(func(): _on_button_hover(sfx_toggle))
		sfx_toggle.mouse_exited.connect(func(): _on_button_exit(sfx_toggle))
	
	if music_toggle:
		music_toggle.toggled.connect(_toggle_music)
		music_toggle.mouse_entered.connect(func(): _on_button_hover(music_toggle))
		music_toggle.mouse_exited.connect(func(): _on_button_exit(music_toggle))
	
	if back_button:
		back_button.pressed.connect(_go_back)
		back_button.mouse_entered.connect(func(): _on_button_hover(back_button))
		back_button.mouse_exited.connect(func(): _on_button_exit(back_button))

func _on_button_hover(button: TextureButton):
	# تأثير hover - تكبير
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.2)
	
	# تشغيل صوت hover
	_play_sound(sfx_hover)

func _on_button_exit(button: TextureButton):
	# إرجاع الحجم الطبيعي
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _toggle_sfx(button_pressed: bool):
	# التحكم في SFX bus
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	if sfx_bus_index == -1:
		# إنشاء SFX bus إذا لم يكن موجوداً
		sfx_bus_index = AudioServer.bus_count
		AudioServer.add_bus(sfx_bus_index)
		AudioServer.set_bus_name(sfx_bus_index, "SFX")
	
	if sfx_bus_index >= 0:
		AudioServer.set_bus_mute(sfx_bus_index, !button_pressed)
	
	# تحديث modulate بناءً على الحالة
	_update_toggle_visual(sfx_toggle, button_pressed)
	
	_play_sound(sfx_click)
	_save_settings()

func _toggle_music(button_pressed: bool):
	# التحكم في Music bus
	var music_bus_index = AudioServer.get_bus_index("Music")
	if music_bus_index == -1:
		# إنشاء Music bus إذا لم يكن موجوداً
		music_bus_index = AudioServer.bus_count
		AudioServer.add_bus(music_bus_index)
		AudioServer.set_bus_name(music_bus_index, "Music")
	
	if music_bus_index >= 0:
		AudioServer.set_bus_mute(music_bus_index, !button_pressed)
	
	# تحديث modulate بناءً على الحالة
	_update_toggle_visual(music_toggle, button_pressed)
	
	_play_sound(sfx_click)
	_save_settings()

func _update_toggle_visual(toggle: TextureButton, is_on: bool):
	if toggle:
		if is_on:
			toggle.modulate = Color(1, 1, 1, 1)
		else:
			toggle.modulate = Color(0.6, 0.6, 0.6, 1)

func _go_back():
	_play_sound(sfx_click)
	
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await fade_out.finished
	
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _play_sound(sound: AudioStream):
	if sound:
		var player = AudioStreamPlayer.new()
		player.stream = sound
		player.volume_db = -6.0
		add_child(player)
		player.play()
		await player.finished
		player.queue_free()

func _save_settings():
	var data = {
		"sfx": sfx_toggle.button_pressed if sfx_toggle else true,
		"music": music_toggle.button_pressed if music_toggle else false
	}
	
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()

func _load_settings():
	if FileAccess.file_exists("user://settings.save"):
		var file = FileAccess.open("user://settings.save", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			
			if sfx_toggle:
				var sfx_state = data.get("sfx", true)
				sfx_toggle.button_pressed = sfx_state
				_update_toggle_visual(sfx_toggle, sfx_state)
			if music_toggle:
				var music_state = data.get("music", false)
				music_toggle.button_pressed = music_state
				_update_toggle_visual(music_toggle, music_state)
	else:
		# القيم الافتراضية
		if sfx_toggle:
			sfx_toggle.button_pressed = true
			_update_toggle_visual(sfx_toggle, true)
		if music_toggle:
			music_toggle.button_pressed = false
			_update_toggle_visual(music_toggle, false)

