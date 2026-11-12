class_name TextParser
extends RefCounted

## Parses story tags like {w01|pelataran} into BBCode with clickable meta links.

const TAG_REGEX := "\\{([wW]\\d{2})\\|([^}]+)\\}"


static func to_bbcode(raw: String, discovered_ids: PackedStringArray = PackedStringArray()) -> String:
	var re := RegEx.new()
	re.compile(TAG_REGEX)
	var result := raw
	var matches := re.search_all(raw)
	# Replace from end to start so indices stay valid
	for i in range(matches.size() - 1, -1, -1):
		var m: RegExMatch = matches[i]
		var word_id: String = m.get_string(1).to_lower()
		var form: String = m.get_string(2)
		var start := m.get_start()
		var end := m.get_end()
		var is_known := word_id in discovered_ids
		var color := "#f4d58d" if is_known else "#ffe8a3"
		var bb := "[url=%s][color=%s][u]%s[/u][/color][/url]" % [word_id, color, form]
		result = result.substr(0, start) + bb + result.substr(end)
	return result


static func extract_word_ids(raw: String) -> PackedStringArray:
	var re := RegEx.new()
	re.compile(TAG_REGEX)
	var ids := PackedStringArray()
	for m in re.search_all(raw):
		var word_id: String = m.get_string(1).to_lower()
		if word_id not in ids:
			ids.append(word_id)
	return ids


static func strip_tags(raw: String) -> String:
	var re := RegEx.new()
	re.compile(TAG_REGEX)
	return re.sub(raw, "$2", true)


static func format_template(template: String, values: Dictionary) -> String:
	var out := template
	for key in values.keys():
		out = out.replace("{%s}" % str(key), str(values[key]))
	return out
