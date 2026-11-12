extends CanvasLayer

signal closed

@onready var _panel: PanelContainer = $Center/Panel
@onready var _master: HSlider = $Center/Panel/Margin/VBox/MasterSlider
@onready var _bgm: HSlider = $Center/Panel/Margin/VBox/BgmSlider
@onready var _sfx: HSlider = $Center/Panel/Margin/VBox/SfxSlider
@onready var _text_size: OptionButton = $Center/Panel/Margin/VBox/TextSize
@onready var _resume_btn: Button = $Center/Panel/Margin/VBox/Buttons/ResumeBtn
@onready var _menu_btn: Button = $Center/Panel/Margin/VBox/Buttons/MenuBtn

var show_menu_button: bool = true


func _ready() -> void:
	visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.1, 0.12, 0.96)
	sb.border_color = Color(0.7, 0.55, 0.4, 1)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(3)
	_panel.add_theme_stylebox_override("panel", sb)
	_master.value = SaveManager.volume_master
	_bgm.value = SaveManager.volume_bgm
	_sfx.value = SaveManager.volume_sfx
	_text_size.clear()
	_text_size.add_item("Kecil", 0)
	_text_size.add_item("Normal", 1)
	_text_size.add_item("Besar", 2)
	_text_size.select(SaveManager.text_size)
	_master.value_changed.connect(_on_master)
	_bgm.value_changed.connect(_on_bgm)
	_sfx.value_changed.connect(_on_sfx)
	_text_size.item_selected.connect(_on_text_size)
	_resume_btn.pressed.connect(close)
	_menu_btn.pressed.connect(_on_menu)
	_menu_btn.visible = show_menu_button


func open(p_show_menu: bool = true) -> void:
	show_menu_button = p_show_menu
	_menu_btn.visible = show_menu_button
	visible = true
	GameState.paused = true


func close() -> void:
	SaveManager.save()
	AudioManager.refresh_volumes()
	visible = false
	GameState.paused = false
	closed.emit()


func _on_master(v: float) -> void:
	SaveManager.volume_master = v
	AudioManager.refresh_volumes()


func _on_bgm(v: float) -> void:
	SaveManager.volume_bgm = v
	AudioManager.refresh_volumes()


func _on_sfx(v: float) -> void:
	SaveManager.volume_sfx = v
	AudioManager.refresh_volumes()


func _on_text_size(idx: int) -> void:
	SaveManager.text_size = idx
	SaveManager.save()


func _on_menu() -> void:
	SaveManager.save()
	GameState.session_active = false
	GameState.paused = false
	get_tree().change_scene_to_file("res://scenes/title/TitleScreen.tscn")
