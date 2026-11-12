extends Control

const TYPEWRITER_CPS := 42.0

@onready var _bg: TextureRect = $Background
@onready var _nenek: TextureRect = $Stage/Nenek
@onready var _icons_row: HBoxContainer = $Stage/Icons
@onready var _fg_tint: ColorRect = $ForegroundTint
@onready var _energy_bar: ProgressBar = $HUD/EnergyBar
@onready var _energy_label: Label = $HUD/EnergyLabel
@onready var _word_counter: Label = $HUD/WordCounter
@onready var _trust_label: Label = $HUD/TrustLabel
@onready var _btn_book: Button = $HUD/BtnBook
@onready var _btn_pause: Button = $HUD/BtnPause
@onready var _speaker: Label = $Dialog/Margin/VBox/Speaker
@onready var _dialog_text: RichTextLabel = $Dialog/Margin/VBox/Text
@onready var _dialog_hint: Label = $Dialog/Margin/VBox/Hint
@onready var _questions: HBoxContainer = $Questions
@onready var _quota: Label = $QuestionsHeader/Quota
@onready var _btn_end: Button = $HUD/BtnEnd
@onready var _mode_badge: Label = $HUD/ModeBadge
@onready var _vocab: CanvasLayer = $VocabBook
@onready var _settings: CanvasLayer = $SettingsModal

var _icon_buttons: Dictionary = {} ## word_id -> TextureButton
var _full_bbcode: String = ""
var _visible_chars: int = 0
var _typing: bool = false
var _type_accum: float = 0.0
var _awaiting_advance: bool = false
var _low_energy_warned: bool = false
var _sky_dirty: bool = true
var _last_sky_bucket: int = -1
var _nenek_frame: int = 0
var _nenek_timer: float = 0.0
var _reaction_queue: String = ""


func _ready() -> void:
	if not GameState.session_active:
		GameState.start_session(GameState.MODE_PENDATANG)
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_nenek.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_speaker.text = "Nenek Wati"
	_mode_badge.text = "Mode Akamsi" if GameState.is_akamsi() else "Mode Pendatang"
	_apply_panel_style($Dialog)
	_build_icons()
	_on_highlights([])
	_build_question_buttons()
	_btn_book.pressed.connect(_on_open_book)
	_btn_pause.pressed.connect(_on_pause)
	_btn_end.pressed.connect(_on_end_pressed)
	_dialog_text.meta_clicked.connect(_on_word_meta)
	# Non-meta clicks bubble from RichTextLabel; meta clicks are accept_event()'d.
	$Dialog.gui_input.connect(_on_dialog_gui_input)
	_vocab.guess_made.connect(_on_guess_reaction)
	_vocab.closed.connect(_on_vocab_closed)
	GameState.energy_changed.connect(_on_energy)
	GameState.trust_changed.connect(_on_trust)
	GameState.words_changed.connect(_on_words)
	GameState.questions_changed.connect(_on_questions)
	GameState.nenek_state_changed.connect(_on_nenek_state)
	GameState.highlight_icons_changed.connect(_on_highlights)
	GameState.session_ended.connect(_on_session_ended)
	_on_energy(GameState.energy)
	_on_trust(GameState.trust, GameState.get_trust_tier())
	_on_words()
	_on_questions(GameState.questions_left)
	_refresh_sky(true)
	AudioManager.play_bgm("bgm_main")
	AudioManager.play_ambience("amb_cricket")
	# Tutorial already played on ApproachScene — begin porch story immediately.
	GameState.tutorial_index = -1
	GameState.begin_story_presentation()
	_show_current_line()


func _process(delta: float) -> void:
	if GameState.session_active and not GameState.paused:
		GameState.tick_energy(delta)
	_refresh_sky(false)
	_animate_nenek(delta)
	if _typing and not GameState.paused:
		_type_accum += delta * TYPEWRITER_CPS * SaveManager.text_scale()
		while _type_accum >= 1.0:
			_type_accum -= 1.0
			_visible_chars += 1
			_dialog_text.visible_characters = _visible_chars
			if _visible_chars >= _dialog_text.get_total_character_count():
				_finish_typing()
				break


func _unhandled_input(event: InputEvent) -> void:
	if _vocab.visible or _settings.visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER]):
		_on_advance_pressed()
		get_viewport().set_input_as_handled()


func _on_dialog_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_advance_pressed()



func _build_icons() -> void:
	for c in _icons_row.get_children():
		c.queue_free()
	_icon_buttons.clear()
	# Show a subset of stage icons (all 20 in a wrap row is fine for prototype)
	for wid in GameData.word_ids:
		var btn := TextureButton.new()
		btn.custom_minimum_size = Vector2(16, 16)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.texture_normal = PixelArt.icon_for_word(wid, false)
		btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		btn.tooltip_text = str(GameData.get_word(wid).get("form", wid))
		btn.pressed.connect(_on_icon_pressed.bind(wid))
		_icons_row.add_child(btn)
		_icon_buttons[wid] = btn


func _build_question_buttons() -> void:
	for c in _questions.get_children():
		c.queue_free()
	for q in GameData.questions:
		var btn := Button.new()
		btn.text = str(q.get("label", "?"))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 22)
		btn.add_theme_font_size_override("font_size", 9)
		var qid: String = str(q.get("id", ""))
		btn.pressed.connect(_on_question.bind(qid))
		_questions.add_child(btn)


func _show_current_line() -> void:
	if _reaction_queue != "":
		_present_text(_reaction_queue, false)
		_reaction_queue = ""
		GameState.in_reaction = true
		return
	if GameState.story_complete and GameState.tutorial_index < 0:
		_present_text(
			"Cerita Nenek sudah sampai ujung, Nak. Masih ada waktu untuk menebak kata di buku… atau akhiri sesi dari tombol di atas.",
			false
		)
		_btn_end.visible = true
		GameState.set_nenek_state("tired")
		return
	var raw := GameState.current_line_text()
	if raw.is_empty():
		return
	_present_text(raw, true)
	_btn_end.visible = GameState.story_complete


func _present_text(raw: String, parse_tags: bool) -> void:
	var discovered := PackedStringArray()
	for wid in GameState.vocab.keys():
		if GameState.vocab[wid]["status"] != GameState.WordStatus.UNDISCOVERED:
			discovered.append(wid)
	if parse_tags:
		_full_bbcode = TextParser.to_bbcode(raw, discovered)
	else:
		_full_bbcode = raw
	_dialog_text.clear()
	_dialog_text.append_text(_full_bbcode)
	_dialog_text.visible_characters = 0
	_visible_chars = 0
	_typing = true
	_type_accum = 0.0
	_awaiting_advance = false
	_dialog_hint.text = "Klik / Spasi untuk percepat"
	var scale := SaveManager.text_scale()
	_dialog_text.add_theme_font_size_override("normal_font_size", int(11 * scale))


func _finish_typing() -> void:
	_typing = false
	_dialog_text.visible_characters = -1
	_awaiting_advance = true
	_dialog_hint.text = "Klik / Spasi untuk lanjut"


func _on_advance_pressed() -> void:
	if _vocab.visible or _settings.visible:
		return
	if not GameState.session_active and GameState.ending_id != "":
		return
	AudioManager.play_sfx("sfx_click")
	if _typing:
		_finish_typing()
		return
	if not _awaiting_advance:
		return
	_awaiting_advance = false
	if GameState.in_reaction:
		GameState.in_reaction = false
		if GameState.energy <= float(GameData.config.get("energy", {}).get("lowThreshold", 25)):
			GameState.set_nenek_state("tired")
		elif GameState.tutorial_index < 0 and not GameState.story_complete:
			var data := GameState.current_line_data()
			var g: String = str(data.get("gesture", "talk"))
			GameState.set_nenek_state(g if g != "" else "idle")
		else:
			GameState.set_nenek_state("idle")
		_show_current_line()
		return
	if GameState.story_complete:
		_show_current_line()
		return
	var advanced := GameState.advance_story()
	if advanced or GameState.story_complete:
		_show_current_line()
	else:
		_show_current_line()


func _on_word_meta(meta: Variant) -> void:
	var wid := str(meta)
	GameState.set_active_word(wid)
	AudioManager.play_sfx("sfx_click")
	_vocab.open(wid)


func _on_icon_pressed(word_id: String) -> void:
	if GameState.vocab.get(word_id, {}).get("status", GameState.WordStatus.UNDISCOVERED) == GameState.WordStatus.UNDISCOVERED:
		return
	GameState.set_active_word(word_id)
	AudioManager.play_sfx("sfx_click")


func _on_question(question_id: String) -> void:
	if GameState.paused or not GameState.session_active:
		return
	var answer := GameState.ask_question(question_id)
	if answer.is_empty():
		return
	GameState.set_nenek_state("talk")
	_reaction_queue = answer
	# Interrupt current wait and show answer
	GameState.in_reaction = false
	_show_current_line()


func _on_open_book() -> void:
	AudioManager.play_sfx("sfx_click")
	_vocab.open(GameState.active_word_id)


func _on_pause() -> void:
	AudioManager.play_sfx("sfx_click")
	_settings.open(true)


func _on_end_pressed() -> void:
	AudioManager.play_sfx("sfx_click")
	GameState.request_end_session()


func _on_guess_reaction(_word_id: String, reaction: String) -> void:
	_reaction_queue = reaction
	# Will show when book closes or immediately if still open—queue for after close
	_on_words()


func _on_vocab_closed() -> void:
	if _reaction_queue != "":
		_show_current_line()
	_on_words()


func _on_energy(value: float) -> void:
	_energy_bar.max_value = float(GameData.config.get("energy", {}).get("max", 100))
	_energy_bar.value = value
	_energy_label.text = "Energi %d" % int(ceil(value))
	var low := float(GameData.config.get("energy", {}).get("lowThreshold", 25))
	if value <= low:
		_energy_bar.modulate = Color(1.0, 0.45 + 0.2 * sin(Time.get_ticks_msec() * 0.01), 0.35)
		if not _low_energy_warned and GameState.session_active:
			_low_energy_warned = true
			_reaction_queue = GameState.get_low_energy_line()
			GameState.set_nenek_state("tired")
	else:
		_energy_bar.modulate = Color.WHITE
	# Rebuild sky only when energy crosses ~5% buckets (web-friendly).
	var bucket := int(value / 5.0)
	if bucket != _last_sky_bucket:
		_last_sky_bucket = bucket
		_sky_dirty = true


func _on_trust(value: int, tier: String) -> void:
	_trust_label.text = "Kepercayaan: %s (%d)" % [tier, value]
	match tier:
		"Percaya":
			_trust_label.add_theme_color_override("font_color", Color("9adf8a"))
		"Ragu":
			_trust_label.add_theme_color_override("font_color", Color("e0c060"))
		_:
			_trust_label.add_theme_color_override("font_color", Color("e08070"))


func _on_words() -> void:
	var need := int(GameData.config.get("game", {}).get("winThreshold", 15))
	var got := GameState.get_correct_count()
	_word_counter.text = "%d/%d" % [got, need]
	if got >= need:
		_word_counter.add_theme_color_override("font_color", Color("9adf8a"))
	else:
		_word_counter.add_theme_color_override("font_color", Color("f5e6c8"))


func _on_questions(remaining: int) -> void:
	var max_q: int = int(GameData.config.get("game", {}).get("questionsPerSession", 6))
	_quota.text = "Pertanyaan %d/%d" % [remaining, max_q]
	for btn in _questions.get_children():
		if btn is Button:
			btn.disabled = remaining <= 0 or not GameState.session_active


func _on_nenek_state(state: String) -> void:
	_nenek.texture = PixelArt.nenek_frame(state, _nenek_frame)


func _on_highlights(icon_ids: Array) -> void:
	for wid in _icon_buttons.keys():
		var btn: TextureButton = _icon_buttons[wid]
		var hl: bool = wid in icon_ids
		btn.texture_normal = PixelArt.icon_for_word(wid, hl)
		btn.modulate = Color(1.3, 1.2, 0.9) if hl else Color(0.75, 0.7, 0.65, 0.85)


func _animate_nenek(delta: float) -> void:
	_nenek_timer += delta
	if _nenek_timer >= 0.35:
		_nenek_timer = 0.0
		_nenek_frame = (_nenek_frame + 1) % 8
		_nenek.texture = PixelArt.nenek_frame(GameState.nenek_state, _nenek_frame)


func _refresh_sky(force: bool) -> void:
	var low := float(GameData.config.get("energy", {}).get("lowThreshold", 25))
	if GameState.energy <= low:
		_energy_bar.modulate = Color(1.0, 0.45 + 0.2 * sin(Time.get_ticks_msec() * 0.01), 0.35)
	if not force and not _sky_dirty:
		return
	_sky_dirty = false
	var max_e := float(GameData.config.get("energy", {}).get("max", 100))
	var t := 1.0 - clampf(GameState.energy / max_e, 0.0, 1.0)
	t = pow(t, 0.85)
	_bg.texture = PixelArt.dusk_sky(Vector2i(480, 270), t)
	if _fg_tint:
		_fg_tint.color = Color(0.25, 0.1, 0.35, t * 0.22)


func _on_session_ended(_ending_id: String) -> void:
	await get_tree().create_timer(0.35).timeout
	get_tree().change_scene_to_file("res://scenes/ending/EndingScreen.tscn")


func _apply_panel_style(panel: PanelContainer) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.16, 0.1, 0.08, 0.92)
	sb.border_color = Color(0.72, 0.5, 0.28, 1)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", sb)
