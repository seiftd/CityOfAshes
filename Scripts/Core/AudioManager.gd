extends Node


## AudioManager - يدير إعدادات الصوت والموسيقى
## Singleton (Autoload) للتحكم في Audio buses

const SAVE_PATH := "user://settings_audio.save"

var sfx_enabled: bool = true
var music_enabled: bool = true

func _ready() -> void:
	_ensure_buses()
	load_settings()
	_apply_all()

func _ensure_buses() -> void:
	# Ensure SFX and Music buses exist; if not, create them under Master.
	var ab := AudioServer
	var master := ab.get_bus_index("Master")
	
	if ab.get_bus_index("SFX") == -1:
		ab.add_bus(ab.bus_count)
		ab.set_bus_name(ab.bus_count - 1, "SFX")
		ab.set_bus_send(ab.get_bus_index("SFX"), "Master")
	
	if ab.get_bus_index("Music") == -1:
		ab.add_bus(ab.bus_count)
		ab.set_bus_name(ab.bus_count - 1, "Music")
		ab.set_bus_send(ab.get_bus_index("Music"), "Master")

func set_sfx_enabled(v: bool) -> void:
	sfx_enabled = v
	var idx := AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_mute(idx, not v)
	save_settings()

func set_music_enabled(v: bool) -> void:
	music_enabled = v
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		AudioServer.set_bus_mute(idx, not v)
	save_settings()

func _apply_all() -> void:
	set_sfx_enabled(sfx_enabled)
	set_music_enabled(music_enabled)

func save_settings() -> void:
	var data := {"sfx_enabled": sfx_enabled, "music_enabled": music_enabled}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_var(data)
		f.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var data: Dictionary = f.get_var()
		f.close()
		sfx_enabled = bool(data.get("sfx_enabled", true))
		music_enabled = bool(data.get("music_enabled", true))

