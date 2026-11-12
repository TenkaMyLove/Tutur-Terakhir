extends Node

## Loads and exposes all JSON content from res://data/

var config: Dictionary = {}
var words_by_id: Dictionary = {} ## id -> Dictionary
var word_ids: PackedStringArray = PackedStringArray() ## all known ids (compat)
var mode_word_ids: Dictionary = {} ## mode_id -> PackedStringArray
var story_segments: Array = []
var reactions: Dictionary = {}
var questions: Array = []
var question_answers: Dictionary = {} ## word_id -> { q_id -> String }
var question_answers_akamsi: Dictionary = {}
var tutorial_steps: Array = []
var endings: Dictionary = {}

var _loaded := false


func _ready() -> void:
	reload()


func reload() -> void:
	config = _load_json("res://data/config.json")
	var words_root: Dictionary = _load_json("res://data/words.json")
	words_by_id.clear()
	word_ids = PackedStringArray()
	for w in words_root.get("words", []):
		var id: String = str(w.get("id", ""))
		if id.is_empty():
			continue
		words_by_id[id] = w
		word_ids.append(id)
	mode_word_ids.clear()
	var raw_modes: Dictionary = words_root.get("modeWordIds", {})
	for mode_key in raw_modes.keys():
		var arr := PackedStringArray()
		for wid in raw_modes[mode_key]:
			arr.append(str(wid))
		mode_word_ids[str(mode_key)] = arr
	if not mode_word_ids.has("pendatang"):
		mode_word_ids["pendatang"] = word_ids.duplicate()
	if not mode_word_ids.has("akamsi"):
		mode_word_ids["akamsi"] = word_ids.duplicate()
	var story_root: Dictionary = _load_json("res://data/story.json")
	story_segments = story_root.get("segments", [])
	reactions = _load_json("res://data/dialog_reaction.json")
	var q_root: Dictionary = _load_json("res://data/dialog_questions.json")
	questions = q_root.get("questions", [])
	question_answers = q_root.get("answers", {})
	question_answers_akamsi = q_root.get("answers_akamsi", {})
	var tut: Dictionary = _load_json("res://data/tutorial.json")
	tutorial_steps = tut.get("steps", [])
	var end_root: Dictionary = _load_json("res://data/endings.json")
	endings = end_root.get("endings", {})
	_loaded = true
	print("[GameData] Loaded %d words, %d segments." % [word_ids.size(), story_segments.size()])


func get_word(word_id: String) -> Dictionary:
	return words_by_id.get(word_id, {})


func get_word_ids_for_mode(mode_id: String) -> PackedStringArray:
	var key := "akamsi" if mode_id == "akamsi" else "pendatang"
	if mode_word_ids.has(key):
		return mode_word_ids[key]
	return word_ids


func get_mode(mode_id: String) -> Dictionary:
	var modes: Dictionary = config.get("modes", {})
	if mode_id == "pendatang" or mode_id == "normal":
		return modes.get("normal", {})
	if mode_id == "akamsi":
		return modes.get("akamsi", {})
	return modes.get(mode_id, {})


func get_question_answer(word_id: String, question_id: String, akamsi: bool = false) -> String:
	var pool: Dictionary = question_answers_akamsi if akamsi else question_answers
	var by_word: Dictionary = pool.get(word_id, {})
	if by_word.is_empty() and akamsi:
		by_word = question_answers.get(word_id, {})
	return str(by_word.get(question_id, "Nenek diam sejenak... Nenek kurang ingat, Nak."))


func pick_reaction(kind: String) -> String:
	var arr: Array = reactions.get(kind, [])
	if arr.is_empty():
		return ""
	return str(arr[randi() % arr.size()])


func evaluate_ending(correct_count: int) -> String:
	var g: Dictionary = config.get("game", {})
	var full: int = int(g.get("tierFull", 20))
	var legacy: int = int(g.get("tierLegacy", 18))
	var thin: int = int(g.get("tierThin", 15))
	if correct_count >= full:
		return "full"
	if correct_count >= legacy:
		return "legacy"
	if correct_count >= thin:
		return "thin"
	return "lose"


func get_ending(ending_id: String) -> Dictionary:
	return endings.get(ending_id, endings.get("lose", {}))


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Cannot open JSON: %s" % path)
		return {}
	var text := f.get_as_text()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON root must be object: %s" % path)
		return {}
	return data
