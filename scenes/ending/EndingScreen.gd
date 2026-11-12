extends Control

@onready var _bg: TextureRect = $Background
@onready var _title: Label = $Root/Title
@onready var _body: RichTextLabel = $Root/Body
@onready var _score: Label = $Root/Score
@onready var _btn_replay: Button = $Root/Buttons/Replay
@onready var _btn_menu: Button = $Root/Buttons/Menu
@onready var _unlock: Label = $Root/UnlockNote


func _ready() -> void:
	var eid: String = GameState.ending_id
	if eid.is_empty():
		eid = GameData.evaluate_ending(GameState.get_correct_count())
		GameState.ending_id = eid
	var ending: Dictionary = GameData.get_ending(eid)
	var is_win := eid != "lose"
	_bg.texture = PixelArt.dusk_sky(Vector2i(480, 270), 0.25 if is_win else 0.85)
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_title.text = str(ending.get("title", "Selesai"))
	_title.add_theme_color_override("font_color", Color("ffe29a") if is_win else Color("c8b0d0"))
	var lines: Array = ending.get("lines", [])
	_body.clear()
	for i in lines.size():
		_body.append_text(str(lines[i]))
		if i < lines.size() - 1:
			_body.append_text("\n\n")
	var win_th: int = int(GameData.config.get("game", {}).get("winThreshold", 15))
	_score.text = "Kata terselamatkan: %d / %d  (target %d)" % [
		GameState.get_correct_count(),
		GameData.word_ids.size(),
		win_th,
	]
	_unlock.visible = is_win and SaveManager.is_akamsi_unlocked()
	_unlock.text = "Mode Akamsi terbuka untuk sesi berikutnya."
	_btn_replay.pressed.connect(_on_replay)
	_btn_menu.pressed.connect(_on_menu)
	if is_win:
		AudioManager.play_bgm("bgm_win")
	else:
		AudioManager.play_bgm("bgm_lose")


func _on_replay() -> void:
	AudioManager.play_sfx("sfx_click")
	var mode := GameState.mode_id
	GameState.start_session(mode)
	get_tree().change_scene_to_file("res://scenes/approach/ApproachScene.tscn")


func _on_menu() -> void:
	AudioManager.play_sfx("sfx_click")
	get_tree().change_scene_to_file("res://scenes/title/TitleScreen.tscn")
