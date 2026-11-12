extends Control

@onready var _title: Label = $Root/Title
@onready var _subtitle: Label = $Root/Subtitle
@onready var _btn_pendatang: Button = $Root/Modes/BtnPendatang
@onready var _btn_akamsi: Button = $Root/Modes/BtnAkamsi
@onready var _akamsi_lock: Label = $Root/Modes/AkamsiLock
@onready var _btn_settings: Button = $Root/TopRow/BtnSettings
@onready var _btn_quit: Button = $Root/BtnQuit
@onready var _bg: TextureRect = $Background
@onready var _settings: CanvasLayer = $SettingsModal


func _ready() -> void:
	_bg.texture = PixelArt.dusk_sky(Vector2i(480, 270), 0.15)
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_title.text = str(GameData.config.get("game", {}).get("title", "Tutur Terakhir"))
	_subtitle.text = "Rekam tutur terakhir sebelum senja selesai"
	_btn_pendatang.pressed.connect(_on_pendatang)
	_btn_akamsi.pressed.connect(_on_akamsi)
	_btn_settings.pressed.connect(_on_settings)
	_btn_quit.pressed.connect(_on_quit)
	_refresh_modes()
	AudioManager.play_bgm("bgm_main")


func _refresh_modes() -> void:
	var unlocked := SaveManager.is_akamsi_unlocked()
	_btn_akamsi.disabled = not unlocked
	_akamsi_lock.visible = not unlocked
	_akamsi_lock.text = "Terkunci — tamatkan Mode Pendatang dulu"
	var normal := GameData.get_mode("normal")
	var akamsi := GameData.get_mode("akamsi")
	_btn_pendatang.text = "Mode %s" % str(normal.get("label", "Pendatang"))
	_btn_akamsi.text = "Mode %s" % str(akamsi.get("label", "Akamsi"))
	$Root/Modes/PendatangHint.text = str(normal.get("subtitle", ""))
	$Root/Modes/AkamsiHint.text = str(akamsi.get("subtitle", ""))


func _on_pendatang() -> void:
	AudioManager.play_sfx("sfx_click")
	GameState.start_session(GameState.MODE_PENDATANG)
	get_tree().change_scene_to_file("res://scenes/approach/ApproachScene.tscn")


func _on_akamsi() -> void:
	if not SaveManager.is_akamsi_unlocked():
		return
	AudioManager.play_sfx("sfx_click")
	GameState.start_session(GameState.MODE_AKAMSI)
	get_tree().change_scene_to_file("res://scenes/approach/ApproachScene.tscn")


func _on_settings() -> void:
	AudioManager.play_sfx("sfx_click")
	_settings.open(false)


func _on_quit() -> void:
	# Web export: hide quit or no-op; desktop quits.
	if OS.has_feature("web"):
		return
	get_tree().quit()
