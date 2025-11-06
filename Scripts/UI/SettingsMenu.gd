extends Control

## SettingsMenu - قائمة الإعدادات
## يستخدم AudioManager للتحكم في الصوت

@onready var toggle_sfx: TextureButton = $"VBoxContainer/HBox_SFX/ToggleButton_SFX"
@onready var toggle_music: TextureButton = $"VBoxContainer/HBox_Music/ToggleButton_Music"
@onready var back_btn: TextureButton = $"VBoxContainer/BackButton"
@onready var toggle_fx: AnimationPlayer = $ToggleFX

# Try to load PNG first, fallback to JPG
var TEX_ON: Texture2D
var TEX_OFF: Texture2D

func _load_textures():
	if ResourceLoader.exists("res://assets/ui/toggle_on.png"):
		TEX_ON = load("res://assets/ui/toggle_on.png")
		TEX_OFF = load("res://assets/ui/toggle_off.png")
	else:
		TEX_ON = load("res://assets/ui/toggle_on.jpg")
		TEX_OFF = load("res://assets/ui/toggle_off.jpg")

var click_snd := preload("res://assets/sfx/button_click.mp3")
var hover_snd := preload("res://assets/sfx/button_hover.mp3")

var asp_click: AudioStreamPlayer
var asp_hover: AudioStreamPlayer

func _ready() -> void:
	# Load textures
	_load_textures()
	
	# SFX players
	asp_click = AudioStreamPlayer.new()
	asp_click.bus = "SFX"
	add_child(asp_click)
	
	asp_hover = AudioStreamPlayer.new()
	asp_hover.bus = "SFX"
	add_child(asp_hover)
	
	# Initialize states from AudioManager
	_apply_toggle_visual(toggle_sfx, AudioManager.sfx_enabled)
	_apply_toggle_visual(toggle_music, AudioManager.music_enabled)
	
	# Set initial button states
	if toggle_sfx:
		toggle_sfx.button_pressed = AudioManager.sfx_enabled
	if toggle_music:
		toggle_music.button_pressed = AudioManager.music_enabled
	
	# Connect signals
	if toggle_sfx:
		toggle_sfx.toggled.connect(_on_toggle_sfx)
		toggle_sfx.mouse_entered.connect(_play_hover)
		toggle_sfx.mouse_exited.connect(func(): _on_button_exit(toggle_sfx))
	
	if toggle_music:
		toggle_music.toggled.connect(_on_toggle_music)
		toggle_music.mouse_entered.connect(_play_hover)
		toggle_music.mouse_exited.connect(func(): _on_button_exit(toggle_music))
	
	if back_btn:
		back_btn.pressed.connect(_on_back)
		back_btn.mouse_entered.connect(_play_hover)
		back_btn.mouse_exited.connect(func(): _on_button_exit(back_btn))
	
	# بدء تأثير glow
	if toggle_fx:
		toggle_fx.play("GlowPulse")

func _on_toggle_sfx(button_pressed: bool) -> void:
	AudioManager.set_sfx_enabled(button_pressed)
	_apply_toggle_visual(toggle_sfx, button_pressed)
	_play_click()

func _on_toggle_music(button_pressed: bool) -> void:
	AudioManager.set_music_enabled(button_pressed)
	_apply_toggle_visual(toggle_music, button_pressed)
	_play_click()

func _apply_toggle_visual(btn: TextureButton, enabled: bool) -> void:
	if not btn:
		return
	
	# Set textures
	if ResourceLoader.exists("res://assets/ui/toggle_on.png"):
		btn.texture_normal = load("res://assets/ui/toggle_off.png")
		btn.texture_pressed = load("res://assets/ui/toggle_on.png")
		btn.texture_hover = load("res://assets/ui/toggle_on.png")
	else:
		# Fallback to .jpg if .png doesn't exist
		btn.texture_normal = TEX_OFF
		btn.texture_pressed = TEX_ON
		btn.texture_hover = TEX_ON
	
	# Update button state
	btn.button_pressed = enabled
	
	# Visual effects based on state
	if enabled:
		btn.modulate = Color(0.8, 1.0, 1.0, 1.0)  # Cyan tint when ON
		btn.scale = Vector2(1.05, 1.05)
	else:
		btn.modulate = Color(1.0, 0.8, 0.8, 1.0)  # Red tint when OFF
		btn.scale = Vector2(1.0, 1.0)

func _on_button_exit(button: Control):
	# إرجاع الحجم الطبيعي
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_back() -> void:
	_play_click()
	
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await fade_out.finished
	
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _play_click() -> void:
	if click_snd and asp_click:
		asp_click.stream = click_snd
		asp_click.play()

func _play_hover() -> void:
	if hover_snd and asp_hover:
		asp_hover.stream = hover_snd
		asp_hover.play()
