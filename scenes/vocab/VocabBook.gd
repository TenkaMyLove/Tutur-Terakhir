extends CanvasLayer

signal closed
signal guess_made(word_id: String, reaction: String)

@onready var _list: ItemList = $Root/Panel/Margin/HBox/Left/WordList
@onready var _form: Label = $Root/Panel/Margin/HBox/Right/FormLabel
@onready var _status: Label = $Root/Panel/Margin/HBox/Right/StatusLabel
@onready var _clue: Label = $Root/Panel/Margin/HBox/Right/ClueLabel
@onready var _icon: TextureRect = $Root/Panel/Margin/HBox/Right/IconRow/Icon
@onready var _choices: VBoxContainer = $Root/Panel/Margin/HBox/Right/Choices
@onready var _close_btn: Button = $Root/Panel/Margin/HBox/Right/CloseBtn
@onready var _hint: Label = $Root/Panel/Margin/HBox/Right/HintLabel

var _selected_id: String = ""
var _choice_buttons: Array[Button] = []


func _ready() -> void:
	visible = false
	_style_panel($Root/Panel)
	_close_btn.pressed.connect(close)
	_list.item_selected.connect(_on_item_selected)
	for i in 4:
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 22)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_choice_pressed.bind(i))
		_choices.add_child(btn)
		_choice_buttons.append(btn)
	GameState.words_changed.connect(refresh)


func open(focus_word_id: String = "") -> void:
	visible = true
	GameState.paused = true
	AudioManager.play_sfx("sfx_book_open")
	refresh()
	if focus_word_id != "" and GameState.vocab.has(focus_word_id):
		_select_word(focus_word_id)
	elif _list.item_count > 0:
		_list.select(0)
		_on_item_selected(0)


func close() -> void:
	visible = false
	GameState.paused = false
	AudioManager.play_sfx("sfx_book_close")
	closed.emit()


func refresh() -> void:
	_list.clear()
	var ids: Array = []
	for wid in GameData.get_word_ids_for_mode(GameState.mode_id):
		if not GameState.vocab.has(wid):
			continue
		var st: int = GameState.vocab[wid]["status"]
		if st == GameState.WordStatus.UNDISCOVERED:
			continue
		ids.append(wid)
	for wid in ids:
		var word: Dictionary = GameData.get_word(wid)
		var form: String = str(word.get("form", wid))
		var label := "%s  ·  %s" % [form, GameState.status_label(wid)]
		var idx := _list.add_item(label)
		_list.set_item_metadata(idx, wid)
		match int(GameState.vocab[wid]["status"]):
			GameState.WordStatus.BENAR:
				_list.set_item_custom_fg_color(idx, Color("8fdf8a"))
			GameState.WordStatus.TERLEWAT:
				_list.set_item_custom_fg_color(idx, Color("d09090"))
			_:
				_list.set_item_custom_fg_color(idx, Color("f0e0c0"))
	if _selected_id != "":
		_select_word(_selected_id)
	elif _list.item_count == 0:
		_clear_detail()
		_hint.text = "Belum ada kata. Dengarkan cerita Nenek dulu."


func _on_item_selected(index: int) -> void:
	var wid: String = str(_list.get_item_metadata(index))
	_select_word(wid)


func _select_word(word_id: String) -> void:
	_selected_id = word_id
	GameState.set_active_word(word_id)
	var word: Dictionary = GameData.get_word(word_id)
	_form.text = str(word.get("form", word_id))
	_status.text = GameState.status_label(word_id)
	_clue.text = str(word.get("narrativeClue", ""))
	_icon.texture = PixelArt.icon_for_word(word_id, true)
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var st: int = GameState.vocab[word_id]["status"]
	var attempts: int = int(GameState.vocab[word_id]["attempts"])
	var max_a: int = int(GameData.config.get("game", {}).get("maxAttemptsPerWord", 2))
	if st == GameState.WordStatus.BELUM:
		_hint.text = "Percobaan %d/%d — pilih arti yang paling cocok." % [attempts + 1, max_a]
		var choices := GameState.get_choices(word_id)
		for i in _choice_buttons.size():
			var btn := _choice_buttons[i]
			if i < choices.size():
				btn.visible = true
				btn.disabled = false
				btn.text = choices[i]
			else:
				btn.visible = false
	elif st == GameState.WordStatus.BENAR:
		_hint.text = "Terkunci benar: %s" % str(word.get("meaning", ""))
		_hide_choices()
	else:
		_hint.text = "Terlewat. Arti: %s" % str(word.get("meaning", ""))
		_hide_choices()
	# Sync list selection
	for i in _list.item_count:
		if str(_list.get_item_metadata(i)) == word_id:
			_list.select(i)
			break


func _hide_choices() -> void:
	for btn in _choice_buttons:
		btn.visible = false


func _clear_detail() -> void:
	_selected_id = ""
	_form.text = "—"
	_status.text = ""
	_clue.text = ""
	_hint.text = ""
	_hide_choices()


func _on_choice_pressed(index: int) -> void:
	if _selected_id.is_empty():
		return
	var btn := _choice_buttons[index]
	if not btn.visible:
		return
	AudioManager.play_sfx("sfx_click")
	var reaction := GameState.submit_guess(_selected_id, btn.text)
	refresh()
	if reaction != "":
		guess_made.emit(_selected_id, reaction)
	# Keep book open unless session ended
	if not GameState.session_active:
		close()


func _style_panel(panel: PanelContainer) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.12, 0.08, 0.96)
	sb.border_color = Color(0.85, 0.65, 0.35, 1)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
