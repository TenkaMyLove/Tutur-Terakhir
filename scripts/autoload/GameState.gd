extends Node

## Runtime session state for one playthrough.

signal energy_changed(value: float)
signal trust_changed(value: int, tier: String)
signal words_changed
signal questions_changed(remaining: int)
signal word_discovered(word_id: String)
signal guess_resolved(word_id: String, result: String) ## correct | wrong_first | wrong_missed
signal session_ended(ending_id: String)
signal active_word_changed(word_id: String)
signal nenek_state_changed(state: String)
signal highlight_icons_changed(icon_ids: Array)

enum WordStatus { UNDISCOVERED, BELUM, BENAR, TERLEWAT }

const MODE_PENDATANG := "pendatang"
const MODE_AKAMSI := "akamsi"

var mode_id: String = MODE_PENDATANG
var energy: float = 100.0
var trust: int = 60
var questions_left: int = 6
var active_word_id: String = ""
var nenek_state: String = "idle"
var highlighted_icons: Array = []
var story_complete: bool = false
var session_active: bool = false
var ending_id: String = ""
var paused: bool = false

## word_id -> { status: WordStatus, attempts: int, choices: PackedStringArray }
var vocab: Dictionary = {}

var tutorial_index: int = -1 ## -1 = not in tutorial / done; 0..n = step
var segment_index: int = 0
var line_index: int = 0
var in_reaction: bool = false


func start_session(p_mode: String) -> void:
	mode_id = MODE_AKAMSI if p_mode == MODE_AKAMSI or p_mode == "akamsi" else MODE_PENDATANG
	var e: Dictionary = GameData.config.get("energy", {})
	var t: Dictionary = GameData.config.get("trust", {})
	var g: Dictionary = GameData.config.get("game", {})
	energy = float(e.get("initial", 100.0))
	trust = int(t.get("initial", 60))
	questions_left = int(g.get("questionsPerSession", 6))
	active_word_id = ""
	nenek_state = "idle"
	highlighted_icons = []
	story_complete = false
	session_active = true
	ending_id = ""
	paused = false
	in_reaction = false
	tutorial_index = -1 ## Dialog tutorial disabled; MainGame shows TutorialPopup instead.
	segment_index = 0
	line_index = 0
	vocab.clear()
	for wid in GameData.get_word_ids_for_mode(mode_id):
		vocab[wid] = {
			"status": WordStatus.UNDISCOVERED,
			"attempts": 0,
			"choices": PackedStringArray(),
		}
	energy_changed.emit(energy)
	trust_changed.emit(trust, get_trust_tier())
	questions_changed.emit(questions_left)
	words_changed.emit()
	nenek_state_changed.emit(nenek_state)


func is_akamsi() -> bool:
	return mode_id == MODE_AKAMSI


func get_trust_tier() -> String:
	var t: Dictionary = GameData.config.get("trust", {})
	var high: int = int(t.get("highThreshold", 60))
	var mid: int = int(t.get("midThreshold", 30))
	if trust >= high:
		return "Percaya"
	if trust >= mid:
		return "Ragu"
	return "Waspada"


func get_correct_count() -> int:
	var n := 0
	for wid in vocab.keys():
		if vocab[wid]["status"] == WordStatus.BENAR:
			n += 1
	return n


func get_discovered_count() -> int:
	var n := 0
	for wid in vocab.keys():
		if vocab[wid]["status"] != WordStatus.UNDISCOVERED:
			n += 1
	return n


func get_resolved_count() -> int:
	var n := 0
	for wid in vocab.keys():
		var st: int = vocab[wid]["status"]
		if st == WordStatus.BENAR or st == WordStatus.TERLEWAT:
			n += 1
	return n


func all_discovered_resolved() -> bool:
	for wid in vocab.keys():
		var st: int = vocab[wid]["status"]
		if st == WordStatus.BELUM:
			return false
	return get_discovered_count() > 0


func status_label(word_id: String) -> String:
	match int(vocab.get(word_id, {}).get("status", WordStatus.UNDISCOVERED)):
		WordStatus.BELUM:
			return "belum ditebak"
		WordStatus.BENAR:
			return "terkunci benar"
		WordStatus.TERLEWAT:
			return "terlewat"
		_:
			return "belum ditemui"


func discover_words(word_ids: Array) -> void:
	var any := false
	for wid in word_ids:
		var id := str(wid)
		if not vocab.has(id):
			continue
		if vocab[id]["status"] == WordStatus.UNDISCOVERED:
			vocab[id]["status"] = WordStatus.BELUM
			vocab[id]["choices"] = _build_choices(id)
			any = true
			word_discovered.emit(id)
	if any:
		words_changed.emit()


func set_active_word(word_id: String) -> void:
	if word_id.is_empty() or not vocab.has(word_id):
		return
	if vocab[word_id]["status"] == WordStatus.UNDISCOVERED:
		discover_words([word_id])
	active_word_id = word_id
	active_word_changed.emit(word_id)


func set_nenek_state(state: String) -> void:
	nenek_state = state
	nenek_state_changed.emit(state)


func set_highlights(icon_ids: Array) -> void:
	highlighted_icons = icon_ids.duplicate()
	highlight_icons_changed.emit(highlighted_icons)


func tick_energy(delta: float) -> void:
	if not session_active or paused or ending_id != "":
		return
	var e: Dictionary = GameData.config.get("energy", {})
	var drain: float = float(e.get("passiveDrainPerSec", 0.22))
	var low: float = float(e.get("lowThreshold", 25.0))
	var mult: float = float(e.get("lowDrainMultiplier", 1.25))
	if energy <= low:
		drain *= mult
	_apply_energy(-drain * delta)


func _apply_energy(delta_e: float) -> void:
	var e: Dictionary = GameData.config.get("energy", {})
	var mx: float = float(e.get("max", 100.0))
	energy = clampf(energy + delta_e, 0.0, mx)
	energy_changed.emit(energy)
	if energy <= 0.0 and session_active:
		_end_session()


func _apply_trust(delta_t: int) -> void:
	var t: Dictionary = GameData.config.get("trust", {})
	var mn: int = int(t.get("min", 0))
	var mx: int = int(t.get("max", 100))
	trust = clampi(trust + delta_t, mn, mx)
	trust_changed.emit(trust, get_trust_tier())


func ask_question(question_id: String) -> String:
	if not session_active or questions_left <= 0:
		return ""
	if active_word_id.is_empty():
		return "Pilih dulu kata yang digarisbawahi, Nak, baru Nenek bisa jawab."
	var e: Dictionary = GameData.config.get("energy", {})
	var t: Dictionary = GameData.config.get("trust", {})
	var cost: float = float(e.get("onQuestionNormal", -4.0))
	if get_trust_tier() == "Waspada":
		cost = float(e.get("onQuestionWaspada", -6.0))
	questions_left -= 1
	questions_changed.emit(questions_left)
	_apply_energy(cost)
	_apply_trust(int(t.get("onQuestion", 0)))
	AudioManager.play_sfx("sfx_click")
	return GameData.get_question_answer(active_word_id, question_id, is_akamsi())


func submit_guess(word_id: String, choice: String) -> String:
	if not session_active or not vocab.has(word_id):
		return ""
	var entry: Dictionary = vocab[word_id]
	var st: int = entry["status"]
	if st != WordStatus.BELUM:
		return ""
	var word: Dictionary = GameData.get_word(word_id)
	var meaning: String = str(word.get("meaning", ""))
	var form: String = str(word.get("form", ""))
	var e: Dictionary = GameData.config.get("energy", {})
	var t: Dictionary = GameData.config.get("trust", {})
	var max_attempts: int = int(GameData.config.get("game", {}).get("maxAttemptsPerWord", 2))
	if choice == meaning:
		entry["status"] = WordStatus.BENAR
		entry["attempts"] = int(entry["attempts"]) + 1
		_apply_energy(float(e.get("onCorrect", 3.0)))
		_apply_trust(int(t.get("onCorrect", 8)))
		set_nenek_state("happy")
		AudioManager.play_sfx("sfx_correct")
		words_changed.emit()
		guess_resolved.emit(word_id, "correct")
		var line := GameData.pick_reaction("correct")
		_maybe_auto_end()
		return line
	# Wrong
	entry["attempts"] = int(entry["attempts"]) + 1
	_apply_energy(float(e.get("onWrong", -8.0)))
	_apply_trust(int(t.get("onWrong", -15)))
	AudioManager.play_sfx("sfx_wrong")
	if int(entry["attempts"]) >= max_attempts:
		entry["status"] = WordStatus.TERLEWAT
		set_nenek_state("tired")
		words_changed.emit()
		guess_resolved.emit(word_id, "wrong_missed")
		var tmpl := GameData.pick_reaction("wrong_missed")
		_maybe_auto_end()
		return TextParser.format_template(tmpl, {"meaning": meaning, "form": form})
	set_nenek_state("correct")
	words_changed.emit()
	guess_resolved.emit(word_id, "wrong_first")
	return GameData.pick_reaction("wrong_first")


func get_choices(word_id: String) -> PackedStringArray:
	if not vocab.has(word_id):
		return PackedStringArray()
	var choices: PackedStringArray = vocab[word_id]["choices"]
	if choices.is_empty():
		vocab[word_id]["choices"] = _build_choices(word_id)
		choices = vocab[word_id]["choices"]
	return choices


func _build_choices(word_id: String) -> PackedStringArray:
	var word: Dictionary = GameData.get_word(word_id)
	var opts: Array = []
	opts.append(str(word.get("meaning", "")))
	for d in word.get("distractors", []):
		opts.append(str(d))
	opts.shuffle()
	return PackedStringArray(opts)


func request_end_session() -> void:
	if session_active:
		_end_session()


func _maybe_auto_end() -> void:
	if story_complete and all_discovered_resolved():
		_end_session()


func _end_session() -> void:
	if not session_active:
		return
	session_active = false
	var correct := get_correct_count()
	ending_id = GameData.evaluate_ending(correct)
	if ending_id != "lose" and mode_id == MODE_PENDATANG:
		SaveManager.unlock_akamsi()
	set_nenek_state("tired" if ending_id == "lose" else "happy")
	session_ended.emit(ending_id)


func current_line_text() -> String:
	if tutorial_index >= 0 and tutorial_index < GameData.tutorial_steps.size():
		return str(GameData.tutorial_steps[tutorial_index].get("text", ""))
	var seg := _current_segment()
	if seg.is_empty():
		return ""
	var lines: Array = seg.get("lines", [])
	if line_index < 0 or line_index >= lines.size():
		return ""
	var line: Dictionary = lines[line_index]
	if is_akamsi():
		return str(line.get("text_akamsi", line.get("text_normal", "")))
	return str(line.get("text_normal", ""))


func current_line_data() -> Dictionary:
	if tutorial_index >= 0:
		return {}
	var seg := _current_segment()
	if seg.is_empty():
		return {}
	var lines: Array = seg.get("lines", [])
	if line_index < 0 or line_index >= lines.size():
		return {}
	return lines[line_index]


func _current_segment() -> Dictionary:
	if segment_index < 0 or segment_index >= GameData.story_segments.size():
		return {}
	return GameData.story_segments[segment_index]


func advance_story() -> bool:
	## Returns true if advanced to new content; false if waiting / ended.
	if in_reaction:
		in_reaction = false
		return true
	if tutorial_index >= 0:
		tutorial_index += 1
		if tutorial_index >= GameData.tutorial_steps.size():
			tutorial_index = -1
			segment_index = 0
			line_index = 0
			_apply_line_context()
			return true
		set_nenek_state("talk")
		return true
	# Advance line
	var seg := _current_segment()
	if seg.is_empty():
		return false
	var lines: Array = seg.get("lines", [])
	line_index += 1
	if line_index >= lines.size():
		segment_index += 1
		line_index = 0
		if segment_index >= GameData.story_segments.size():
			story_complete = true
			set_nenek_state("tired")
			set_highlights([])
			return false
	_apply_line_context()
	return true


func begin_story_presentation() -> void:
	if tutorial_index >= 0:
		set_nenek_state("talk")
		return
	_apply_line_context()


func _apply_line_context() -> void:
	var data := current_line_data()
	if data.is_empty():
		return
	var words: Array
	if is_akamsi() and data.has("words_akamsi"):
		words = data.get("words_akamsi", [])
	else:
		words = data.get("words", [])
	discover_words(words)
	if not words.is_empty():
		set_active_word(str(words[0]))
	var gesture: String
	if is_akamsi() and data.has("gesture_akamsi"):
		gesture = str(data.get("gesture_akamsi", "talk"))
	else:
		gesture = str(data.get("gesture", "talk"))
	set_nenek_state(gesture if gesture != "" else "talk")
	var icons: Array
	if is_akamsi() and data.has("highlightIcons_akamsi"):
		icons = data.get("highlightIcons_akamsi", [])
	else:
		icons = data.get("highlightIcons", [])
	set_highlights(icons)


func get_low_energy_line() -> String:
	return GameData.pick_reaction("low_energy")
