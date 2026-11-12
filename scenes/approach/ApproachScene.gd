extends Node2D

## Side-scroll approach: spawn on the RIGHT, walk LEFT to Nenek's house.
## Midway: anak memanjat pohon + ibu "Ehh awas kena tegugur".

const WORLD_WIDTH := 1100.0
const GROUND_Y := 210.0
const PLAYER_SPEED := 72.0
const SPAWN_X := 1040.0
const ARRIVE_X := 110.0
const VIGNETTE_X := 620.0

@onready var _camera: Camera2D = $Camera2D
@onready var _player: Sprite2D = $World/Player
@onready var _kid: Sprite2D = $World/Kid
@onready var _mother: Sprite2D = $World/Mother
@onready var _tree: Sprite2D = $World/Tree
@onready var _house: Sprite2D = $World/House
@onready var _neighbor: Sprite2D = $World/NeighborHouse
@onready var _bg: Sprite2D = $World/Background
@onready var _decor: Node2D = $World/Decor
@onready var _bubble: PanelContainer = $UI/SpeechBubble
@onready var _bubble_label: Label = $UI/SpeechBubble/Margin/Label
@onready var _hint: Label = $UI/Hint
@onready var _btn_walk: Button = $UI/BtnWalk
@onready var _tutorial: CanvasLayer = $TutorialPopup

var _can_move: bool = false
var _auto_walk: bool = false
var _arrived: bool = false
var _vignette_shown: bool = false
var _anim_t: float = 0.0
var _frame: int = 0
var _bubble_timer: float = 0.0


func _ready() -> void:
	_setup_world()
	_bubble.visible = false
	_hint.text = "← → atau A/D untuk berjalan · Spasi: lanjut tutorial"
	_btn_walk.text = "Jalan terus ←"
	_btn_walk.pressed.connect(_on_walk_pressed)
	_btn_walk.visible = false
	_player.position = Vector2(SPAWN_X, GROUND_Y)
	_player.flip_h = true
	_camera.position = Vector2(clampf(SPAWN_X, 240.0, WORLD_WIDTH - 240.0), 135.0)
	_camera.make_current()
	GameState.paused = true
	_tutorial.finished.connect(_on_tutorial_finished, CONNECT_ONE_SHOT)
	_tutorial.open()
	AudioManager.play_bgm("bgm_main")
	AudioManager.play_ambience("amb_cricket")


func _setup_world() -> void:
	_bg.texture = PixelArt.approach_sky(Vector2i(int(WORLD_WIDTH), 270))
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bg.centered = false
	_bg.position = Vector2.ZERO

	_tree.texture = PixelArt.tree_sprite()
	_tree.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_tree.centered = true
	_tree.position = Vector2(VIGNETTE_X, GROUND_Y - 28)

	_kid.texture = PixelArt.person_sprite("kid", 0)
	_kid.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_kid.centered = true
	_kid.position = Vector2(VIGNETTE_X + 2, GROUND_Y - 56)

	_mother.texture = PixelArt.person_sprite("mother", 0)
	_mother.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mother.centered = true
	_mother.position = Vector2(VIGNETTE_X + 42, GROUND_Y) # behind / watching from path side
	_mother.flip_h = true

	_house.texture = PixelArt.house_far()
	_house.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_house.centered = true
	_house.position = Vector2(ARRIVE_X - 10, GROUND_Y - 22)

	_neighbor.texture = PixelArt.house_neighbor()
	_neighbor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_neighbor.centered = true
	_neighbor.position = Vector2(ARRIVE_X - 95, GROUND_Y - 10)

	_player.texture = PixelArt.person_sprite("player", 0)
	_player.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_player.centered = true

	_spawn_decor()

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.08, 0.06, 0.94)
	sb.border_color = Color(0.95, 0.78, 0.42, 1)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(3)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	_bubble.add_theme_stylebox_override("panel", sb)
	_bubble_label.text = "Ehh awas kena tegugur!"
	_bubble_label.add_theme_font_size_override("font_size", 10)


func _spawn_decor() -> void:
	for c in _decor.get_children():
		c.queue_free()
	# Fence posts along the path (right side of village)
	for x in [860.0, 900.0, 940.0, 980.0]:
		var post := Sprite2D.new()
		post.texture = PixelArt.fence_post()
		post.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		post.centered = true
		post.position = Vector2(x, GROUND_Y - 2)
		_decor.add_child(post)
	# Extra small bushes as colored blocks near river bank
	for x in [280.0, 360.0, 740.0, 820.0]:
		var bush := Sprite2D.new()
		bush.texture = PixelArt.solid(Vector2i(18, 10), Color("2f6a32"))
		bush.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bush.centered = true
		bush.position = Vector2(x, GROUND_Y - 8)
		_decor.add_child(bush)


func _on_tutorial_finished() -> void:
	_can_move = true
	GameState.paused = false
	_btn_walk.visible = true
	_hint.text = "Berjalanlah ke kiri menuju rumah Nenek Wati."


func _on_walk_pressed() -> void:
	AudioManager.play_sfx("sfx_click")
	_auto_walk = true


func _process(delta: float) -> void:
	_anim_t += delta
	if _anim_t >= 0.28:
		_anim_t = 0.0
		_frame = (_frame + 1) % 2
		_kid.texture = PixelArt.person_sprite("kid", _frame)
		_kid.position.y = GROUND_Y - 56 - _frame * 2

	if _bubble.visible:
		_bubble_timer -= delta
		_update_bubble_pos()
		if _bubble_timer <= 0.0:
			_bubble.visible = false

	if not _can_move or _arrived:
		_camera.position.x = clampf(_player.position.x, 240.0, WORLD_WIDTH - 240.0)
		return

	var dir := 0.0
	if _auto_walk:
		dir = -1.0
	else:
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			dir += 1.0
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			dir -= 1.0

	if dir != 0.0:
		_player.position.x = clampf(_player.position.x + dir * PLAYER_SPEED * delta, ARRIVE_X - 20.0, SPAWN_X)
		_player.flip_h = dir < 0.0
		_player.texture = PixelArt.person_sprite("player", _frame)
	else:
		_player.texture = PixelArt.person_sprite("player", 0)

	_camera.position = Vector2(clampf(_player.position.x, 240.0, WORLD_WIDTH - 240.0), 135.0)

	if not _vignette_shown and _player.position.x <= VIGNETTE_X + 50.0:
		_show_vignette()

	if _player.position.x <= ARRIVE_X:
		_arrive()


func _show_vignette() -> void:
	_vignette_shown = true
	_bubble.visible = true
	_bubble_timer = 4.5
	_update_bubble_pos()
	_hint.text = "Seorang ibu mengawasi anaknya di pohon…"
	AudioManager.play_sfx("sfx_click")


func _update_bubble_pos() -> void:
	var screen_pos := _mother.get_global_transform_with_canvas().origin
	_bubble.position = screen_pos + Vector2(-70, -58)


func _arrive() -> void:
	if _arrived:
		return
	_arrived = true
	_can_move = false
	_auto_walk = false
	_btn_walk.visible = false
	_hint.text = "Kamu tiba di pelataran rumah Nenek…"
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/game/MainGame.tscn")
