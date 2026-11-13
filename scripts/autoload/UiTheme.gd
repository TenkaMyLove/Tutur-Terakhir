extends Node

## Applies one warm-dusk theme to every Control in the game (buttons, panels,
## bars, lists, tooltips). Scene-level overrides still win where they exist.

const INK := Color("2a1a22")
const WOOD := Color("4a3040")
const WOOD_LT := Color("6a4650")
const GOLD := Color("e8b860")
const CREAM := Color("fbeed4")
const MUTED := Color("c8b4a4")


## Controls under a CanvasLayer (book, settings, tutorial) do not inherit
## Window.theme, so the theme is merged into the engine default theme, which
## every Control falls back to.
func _ready() -> void:
	ThemeDB.get_default_theme().merge_with(_build())


func _box(bg: Color, border: Color, bw: int = 2, margin_x: int = 14, margin_y: int = 8) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(0)
	sb.content_margin_left = margin_x
	sb.content_margin_right = margin_x
	sb.content_margin_top = margin_y
	sb.content_margin_bottom = margin_y
	sb.anti_aliasing = false
	return sb


## Square slider knob with a dark rim.
func _knob(fill: Color) -> ImageTexture:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(INK)
	img.fill_rect(Rect2i(3, 3, 18, 18), GOLD)
	img.fill_rect(Rect2i(5, 5, 14, 14), fill)
	return ImageTexture.create_from_image(img)


func _build() -> Theme:
	var th := Theme.new()
	th.default_font_size = 22

	# Buttons: wood plate, gold edge on hover, pressed looks sunk.
	var normal := _box(WOOD, Color("8a5a4a"))
	normal.border_width_bottom = 4
	normal.border_color = Color("8a5a4a")
	var hover := _box(WOOD_LT, GOLD)
	hover.border_width_bottom = 4
	var pressed := _box(Color("38242e"), GOLD)
	pressed.content_margin_top = 10
	pressed.content_margin_bottom = 6
	var disabled := _box(Color("2e2028"), Color("4a3a40"))
	var focus := _box(Color(0, 0, 0, 0), CREAM)
	focus.draw_center = false
	th.set_stylebox("normal", "Button", normal)
	th.set_stylebox("hover", "Button", hover)
	th.set_stylebox("pressed", "Button", pressed)
	th.set_stylebox("disabled", "Button", disabled)
	th.set_stylebox("focus", "Button", focus)
	th.set_color("font_color", "Button", CREAM)
	th.set_color("font_hover_color", "Button", Color.WHITE)
	th.set_color("font_pressed_color", "Button", GOLD)
	th.set_color("font_disabled_color", "Button", Color("8a7a78"))
	th.set_color("font_outline_color", "Button", INK)
	th.set_constant("outline_size", "Button", 4)

	# Panels
	var panel := _box(Color(0.16, 0.1, 0.14, 0.94), Color("c08a52"), 3, 12, 8)
	th.set_stylebox("panel", "PanelContainer", panel)
	th.set_stylebox("panel", "Panel", panel)

	# Labels: dark outline keeps text readable on any sky colour.
	th.set_color("font_color", "Label", CREAM)
	th.set_color("font_outline_color", "Label", INK)
	th.set_constant("outline_size", "Label", 6)
	th.set_color("default_color", "RichTextLabel", CREAM)
	th.set_color("font_outline_color", "RichTextLabel", INK)
	th.set_constant("outline_size", "RichTextLabel", 4)

	# Progress bars (energy / trust)
	var bar_bg := _box(Color("1c1218"), Color("8a5a4a"), 2, 0, 0)
	var bar_fill := _box(Color("f0b048"), Color("fff0b8"), 0, 0, 0)
	bar_fill.border_width_top = 3
	th.set_stylebox("background", "ProgressBar", bar_bg)
	th.set_stylebox("fill", "ProgressBar", bar_fill)

	# Item list (vocab book)
	th.set_stylebox("panel", "ItemList", _box(Color("24161e"), Color("6a4a50"), 2, 6, 6))
	var sel := _box(Color("7a4a52"), GOLD, 2, 6, 4)
	th.set_stylebox("selected", "ItemList", sel)
	th.set_stylebox("selected_focus", "ItemList", sel)
	th.set_stylebox("hovered", "ItemList", _box(Color("4a2e3a"), Color("8a5a4a"), 2, 6, 4))
	th.set_color("font_color", "ItemList", CREAM)
	th.set_color("font_selected_color", "ItemList", Color.WHITE)
	th.set_color("font_outline_color", "ItemList", Color(0, 0, 0, 0))
	th.set_constant("outline_size", "ItemList", 0)

	# Sliders / checkboxes (settings)
	var track := _box(Color("1c1218"), Color("6a4a50"), 2, 0, 5)
	th.set_stylebox("slider", "HSlider", track)
	th.set_stylebox("grabber_area", "HSlider", _box(GOLD, GOLD, 0, 0, 5))
	th.set_stylebox("grabber_area_highlight", "HSlider", _box(Color("fff0b8"), GOLD, 0, 0, 5))
	th.set_icon("grabber", "HSlider", _knob(Color("fff0b8")))
	th.set_icon("grabber_highlight", "HSlider", _knob(Color.WHITE))
	th.set_icon("grabber_disabled", "HSlider", _knob(Color("8a7a78")))
	th.set_color("font_color", "CheckBox", CREAM)

	# Tooltips
	th.set_stylebox("panel", "TooltipPanel", _box(Color("1c1218"), GOLD, 2, 10, 6))
	th.set_color("font_color", "TooltipLabel", CREAM)
	return th
