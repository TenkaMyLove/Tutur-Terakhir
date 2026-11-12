extends Node

## Audio hooks with safe null checks — slots ready for OGG assets.

var bgm_player: AudioStreamPlayer
var amb_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var _streams: Dictionary = {} ## key -> AudioStream (optional)


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGM"
	bgm_player.bus = "Master"
	add_child(bgm_player)
	amb_player = AudioStreamPlayer.new()
	amb_player.name = "Ambience"
	add_child(amb_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFX"
	add_child(sfx_player)
	_apply_volumes()


func register_stream(key: String, stream: AudioStream) -> void:
	if stream == null:
		return
	_streams[key] = stream


func play_bgm(key: String = "bgm_main") -> void:
	var stream: AudioStream = _streams.get(key, null)
	if stream == null or bgm_player == null:
		return
	if bgm_player.stream != stream:
		bgm_player.stream = stream
	if not bgm_player.playing:
		bgm_player.play()


func stop_bgm() -> void:
	if bgm_player and bgm_player.playing:
		bgm_player.stop()


func play_sfx(key: String) -> void:
	var stream: AudioStream = _streams.get(key, null)
	if stream == null or sfx_player == null:
		return
	sfx_player.stream = stream
	sfx_player.play()


func play_ambience(key: String = "amb_cricket") -> void:
	var stream: AudioStream = _streams.get(key, null)
	if stream == null or amb_player == null:
		return
	if amb_player.stream != stream:
		amb_player.stream = stream
	if not amb_player.playing:
		amb_player.play()


func _apply_volumes() -> void:
	var master := linear_to_db(clampf(SaveManager.volume_master, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master)
	if bgm_player:
		bgm_player.volume_db = linear_to_db(clampf(SaveManager.volume_bgm, 0.0, 1.0))
	if sfx_player:
		sfx_player.volume_db = linear_to_db(clampf(SaveManager.volume_sfx, 0.0, 1.0))
	if amb_player:
		amb_player.volume_db = linear_to_db(clampf(SaveManager.volume_bgm * 0.8, 0.0, 1.0))


func refresh_volumes() -> void:
	_apply_volumes()
