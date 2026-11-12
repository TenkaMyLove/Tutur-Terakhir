extends CanvasLayer

signal finished

@onready var _panel: PanelContainer = $Center/Panel
@onready var _title: Label = $Center/Panel/Margin/VBox/Title
@onready var _speaker: Label = $Center/Panel/Margin/VBox/Speaker
@onready var _body: Label = $Center/Panel/Margin/VBox/Body
@onready var _step_label: Label = $Center/Panel/Margin/VBox/StepLabel
@onready var _btn_next: Button = $Center/Panel/Margin/VBox/Buttons/NextBtn
@onready var _btn_skip: Button = $Center/Panel/Margin/VBox/Buttons/SkipBtn

var _steps: Array = []
var _index: int = 0


func _ready() -> void:
	visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.09, 0.07, 0.97)
	sb.border_color = Color(0.85, 0.62, 0.32, 1)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(3)
	_panel.add_theme_stylebox_override("panel", sb)
	_btn_next.pressed.connect(_on_next)
	_btn_skip.pressed.connect(_on_skip)
	_title.text = "Petunjuk untuk Pendatang"


func open() -> void:
	_steps = GameData.tutorial_steps.duplicate()
	_index = 0
	visible = true
	GameState.paused = true
	_refresh()


func _refresh() -> void:
	if _steps.is_empty():
		_close()
		return
	var step: Dictionary = _steps[_index]
	_speaker.text = str(step.get("speaker", "Narator"))
	_body.text = str(step.get("text", ""))
	_step_label.text = "%d / %d" % [_index + 1, _steps.size()]
	var last := _index >= _steps.size() - 1
	_btn_next.text = "Mulai berjalan" if last else "Lanjut"
	_btn_skip.visible = not last


func _on_next() -> void:
	AudioManager.play_sfx("sfx_click")
	if _index >= _steps.size() - 1:
		_close()
		return
	_index += 1
	_refresh()


func _on_skip() -> void:
	AudioManager.play_sfx("sfx_click")
	_close()


func _close() -> void:
	visible = false
	GameState.paused = false
	finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER]):
		_on_next()
		get_viewport().set_input_as_handled()
