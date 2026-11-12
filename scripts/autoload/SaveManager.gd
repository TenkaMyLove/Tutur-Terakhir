extends Node

## Persists unlock + settings in user://save.cfg

const SAVE_PATH := "user://save.cfg"

var volume_master: float = 0.8
var volume_bgm: float = 0.7
var volume_sfx: float = 0.85
var text_size: int = 1 ## 0 small, 1 normal, 2 large
var akamsi_unlocked: bool = false


func _ready() -> void:
	load_save()


func load_save() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	volume_master = float(cfg.get_value("audio", "master", volume_master))
	volume_bgm = float(cfg.get_value("audio", "bgm", volume_bgm))
	volume_sfx = float(cfg.get_value("audio", "sfx", volume_sfx))
	text_size = int(cfg.get_value("ui", "text_size", text_size))
	akamsi_unlocked = bool(cfg.get_value("progress", "akamsi_unlocked", false))


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", volume_master)
	cfg.set_value("audio", "bgm", volume_bgm)
	cfg.set_value("audio", "sfx", volume_sfx)
	cfg.set_value("ui", "text_size", text_size)
	cfg.set_value("progress", "akamsi_unlocked", akamsi_unlocked)
	cfg.save(SAVE_PATH)


func unlock_akamsi() -> void:
	if akamsi_unlocked:
		return
	akamsi_unlocked = true
	save()


func is_akamsi_unlocked() -> bool:
	return akamsi_unlocked


func text_scale() -> float:
	match text_size:
		0:
			return 0.9
		2:
			return 1.2
		_:
			return 1.0
