class_name PixelArt
extends RefCounted

## Procedural warm-dusk pixel art for Tutur Terakhir (GL Compatibility / Web).
## Public entry point for all generated textures. Drawing primitives live in
## Px.gd, Nenek in NenekArt.gd and word icons in IconArt.gd.
## Textures are cached, so animation ticks no longer redraw whole images.

## Backgrounds are drawn at half the 1280x720 viewport and shown at exactly 2x.
const SKY_SIZE := Vector2i(640, 360)
const APPROACH_SIZE := Vector2i(1100, 360)
## Ground line of the porch background (fraction of height). Nenek's mat is
## placed on the deck just above it, clear of the dialog box at the bottom.
const GROUND_RATIO := 0.66

static var _cache: Dictionary = {}


static func _cached(key: String) -> Variant:
	return _cache.get(key, null)


static var _sky_keys: Array = []


static func _store(key: String, t: ImageTexture) -> ImageTexture:
	if _cache.size() > 160:
		_cache.clear()
		_sky_keys.clear()
	_cache[key] = t
	return t


## Sky textures are ~0.9 MB each, so only the most recent few are kept.
static func _store_sky(key: String, t: ImageTexture) -> ImageTexture:
	_sky_keys.append(key)
	while _sky_keys.size() > 6:
		_cache.erase(_sky_keys.pop_front())
	_cache[key] = t
	return t


static func solid(size: Vector2i, color: Color) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


static func rect_bordered(size: Vector2i, fill: Color, border: Color, border_w: int = 1) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(border)
	var inner := Rect2i(border_w, border_w, max(1, size.x - border_w * 2), max(1, size.y - border_w * 2))
	img.fill_rect(inner, fill)
	return ImageTexture.create_from_image(img)


# ------------------------------------------------------------------ characters
static func nenek_frame(state: String, frame: int = 0) -> ImageTexture:
	var key := "nenek:%s:%d" % [state, frame % 8]
	var hit: Variant = _cached(key)
	if hit != null:
		return hit
	return _store(key, Px.tex(NenekArt.render(state, frame % 8)))


static func icon_for_word(word_id: String, highlighted: bool = false) -> ImageTexture:
	var key := "icon:%s:%s" % [word_id, highlighted]
	var hit: Variant = _cached(key)
	if hit != null:
		return hit
	return _store(key, Px.tex(IconArt.render(word_id, highlighted)))


static func person_sprite(kind: String, frame: int = 0) -> ImageTexture:
	var key := "person:%s:%d" % [kind, frame % 2]
	var hit: Variant = _cached(key)
	if hit != null:
		return hit
	return _store(key, Px.tex(_person(kind, frame % 2)))


static func _person(kind: String, frame: int) -> Image:
	var skin := Color("d9a074")
	var shirt := Color("3f7fa0")
	var pants := Color("2f3550")
	var hair := Color("2a1a1c")
	var shoe := Color("4a2c22")
	match kind:
		"kid":
			shirt = Color("e8604e")
			pants = Color("3f5f9a")
			hair = Color("3a2418")
		"mother":
			shirt = Color("b04a80")
			pants = Color("70284e")
			hair = Color("1a1014")
			skin = Color("c99068")
		"player":
			shirt = Color("3f8a64")
			pants = Color("2c4838")
			hair = Color("2a2018")
			skin = Color("c88c62")
	var img := Px.canvas(28, 48)
	var b := frame
	if kind == "kid":
		# climbing pose: arms up, legs apart
		Px.rect(img, 9, 28 + b, 4, 11, pants)
		Px.rect(img, 15, 28, 4, 10 - b, pants)
		Px.rect(img, 9, 38 + b, 5, 2, shoe)
		Px.rect(img, 15, 37 - b, 5, 2, shoe)
		Px.box(img, 8, 16 + b, 12, 13, shirt)
		Px.rect(img, 8, 22 + b, 12, 1, Px.shade(shirt, 0.15))
		Px.thick(img, 9.0, 18.0 + b, 6.0, 11.0 - b, 1.7, skin)
		Px.thick(img, 19.0, 18.0 + b, 22.0, 11.0 + b, 1.7, skin)
		Px.ball(img, 14, 10 + b, 6, 6, skin)
		Px.ellipse(img, 14, 6 + b, 6, 3, hair)
		Px.rect(img, 8, 7 + b, 2, 4, hair)
		Px.px(img, 12, 11 + b, Px.OUTLINE)
		Px.px(img, 16, 11 + b, Px.OUTLINE)
		Px.px(img, 14, 13 + b, Color("a04848"))
	elif kind == "mother":
		# standing, hand raised, looking up
		Px.rect(img, 9, 33, 4, 11, skin)
		Px.rect(img, 15, 33, 4, 11, skin)
		Px.rect(img, 8, 43, 6, 2, shoe)
		Px.rect(img, 15, 43, 6, 2, shoe)
		Px.tri(img, 5, 34, 23, 34, 14, 17, pants)
		Px.rect(img, 5, 33, 18, 2, pants)
		Px.rect(img, 5, 33, 18, 1, Color("f0c070"))
		Px.box(img, 8, 17, 12, 12, shirt)
		Px.thick(img, 9.0, 20.0, 5.0, 13.0, 1.8, skin)
		Px.px(img, 5, 12, Color("ecc2a0"))
		Px.thick(img, 19.0, 21.0, 22.0, 28.0, 1.8, skin)
		Px.ball(img, 14, 11, 6, 7, skin)
		Px.ellipse(img, 14, 6, 7, 4, hair)
		Px.rect(img, 7, 6, 3, 10, hair)
		Px.ball(img, 21, 8, 3, 3, hair)
		Px.px(img, 12, 10, Px.OUTLINE)
		Px.px(img, 16, 10, Px.OUTLINE)
		Px.rect(img, 13, 14, 3, 1, Color("8a4040"))
		Px.px(img, 13, 14, Color("5a2828"))
	else:
		# player walking
		var f := frame
		Px.rect(img, 9, 30, 4, 13 - f, pants)
		Px.rect(img, 15, 30 + f, 4, 13 - f, pants)
		Px.rect(img, 8, 43 - f, 6, 3, shoe)
		Px.rect(img, 15, 43, 6, 3 - f, shoe)
		Px.box(img, 8, 16, 12, 15, shirt)
		Px.rect(img, 8, 29, 12, 2, Px.shade(pants, 0.1))
		Px.rect(img, 14, 17, 1, 12, Px.shade(shirt, 0.18))
		Px.thick(img, 8.0, 18.0, 5.0, 25.0 - f * 2.0, 1.8, skin)
		Px.thick(img, 20.0, 18.0, 23.0, 25.0 - (1 - f) * 2.0, 1.8, skin)
		Px.rect(img, 7, 16, 2, 3, shirt)
		Px.rect(img, 19, 16, 2, 3, shirt)
		Px.ball(img, 14, 10, 6, 6, skin)
		Px.ellipse(img, 14, 6, 6, 3, hair)
		Px.rect(img, 8, 6, 2, 4, hair)
		Px.px(img, 12, 11, Px.OUTLINE)
		Px.px(img, 16, 11, Px.OUTLINE)
		Px.rect(img, 13, 14, 2, 1, Color("8a4040"))
		# satchel strap
		Px.line(img, 9, 17, 19, 28, Color("7a4a2a"))
		Px.box(img, 17, 26, 6, 5, Color("9a6a3a"))
	Px.rim(img, Color("ffbc70"), 0.4)
	Px.outline(img)
	var out := Px.canvas(28, 48)
	Px.ellipse(out, 14, 45, 9, 2, Color(0.05, 0.02, 0.1, 0.3))
	Px.blit(out, img, Vector2i.ZERO)
	return out


# ------------------------------------------------------------------ skies
static func dusk_sky(size: Vector2i, t: float) -> ImageTexture:
	t = snappedf(clampf(t, 0.0, 1.0), 0.05)
	var key := "dusk:%d:%d:%.2f" % [size.x, size.y, t]
	var hit: Variant = _cached(key)
	if hit != null:
		return hit
	return _store_sky(key, Px.tex(_dusk_image(size, t)))


static func _dusk_image(size: Vector2i, t: float) -> Image:
	var w := size.x
	var h := size.y
	var img := Px.canvas(w, h)
	var horizon := int(h * 0.56)
	var gy := int(h * GROUND_RATIO)
	var stops: Array = [
		[0.0, Px.kf(t, "5a3a8a", "261a54", "0a0820")],
		[0.35, Px.kf(t, "d8607a", "6a3a7e", "1a1236")],
		[0.7, Px.kf(t, "ff9a52", "c85a6e", "3a2250")],
		[1.0, Px.kf(t, "ffd27a", "f0905a", "5a3258")],
	]
	Px.sky_bands(img, 0, h, stops, 22)
	# stars
	var star_a := clampf((t - 0.3) / 0.5, 0.0, 1.0)
	if star_a > 0.0:
		for i in range(46):
			var sx := int(Px.rnd(i * 3 + 1) * float(w))
			var sy := int(Px.rnd(i * 3 + 2) * float(horizon) * 0.8)
			if Px.rnd(i * 5 + 9) > star_a:
				continue
			var big := Px.rnd(i * 7 + 3) > 0.86
			Px.px(img, sx, sy, Color(1, 0.96, 0.82, 0.9))
			if big:
				Px.px(img, sx - 1, sy, Color(1, 0.96, 0.82, 0.45))
				Px.px(img, sx + 1, sy, Color(1, 0.96, 0.82, 0.45))
				Px.px(img, sx, sy - 1, Color(1, 0.96, 0.82, 0.45))
				Px.px(img, sx, sy + 1, Color(1, 0.96, 0.82, 0.45))
	# sun sinking -> moon rising
	var sx0 := int(w * 0.8)
	var sun_y := int(lerpf(float(horizon) - 34.0, float(horizon) + 18.0, clampf(t * 1.5, 0.0, 1.0)))
	if t < 0.72:
		Px.glow(img, sx0, sun_y, 46, Color(1.0, 0.7, 0.35, 0.6 * (1.0 - t)), 1.0)
		Px.ball(img, sx0, sun_y, 12, 12, Px.kf(t, "fff0a8", "ffb868", "e07a58"))
	if t > 0.38:
		var ma := clampf((t - 0.38) / 0.4, 0.0, 1.0)
		var mx := int(w * 0.2)
		var my := int(lerpf(46.0, 30.0, ma))
		Px.glow(img, mx, my, 26, Color(0.8, 0.85, 1.0, 0.35 * ma), 1.0)
		Px.ellipse(img, mx, my, 9, 9, Color(0.94, 0.94, 0.86, ma))
		Px.ellipse(img, mx + 4, my - 2, 7, 7, _mix_bg(img, mx + 4, my - 2))
		Px.px(img, mx - 4, my + 3, Color(0.8, 0.8, 0.7, ma))
	_clouds(img, t, horizon)
	_hills(img, t, horizon)
	_ground(img, t, gy)
	_palm(img, 26, gy, 1.35, t)
	_palm(img, w - 24, gy, 1.25, t)
	_palm(img, int(w * 0.6), gy - 4, 0.8, t)
	# Houses keep a fixed pixel size so they stay readable at any canvas size.
	var deck_y := gy - 12
	_stilt_house(img, Rect2i(10, deck_y - 84, 150, 84), t, true)
	_stilt_house(img, Rect2i(int(w * 0.30), deck_y - 104, 280, 104), t, false)
	_foreground(img, t, gy)
	_fireflies(img, t)
	_vignette(img)
	return img


static var _vig_cache: Dictionary = {}


## Dithered edge darkening. The set of darkened pixels depends only on the
## image size, so it is computed once and reused by every sky.
static func _vignette(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var key := Vector2i(w, h)
	if not _vig_cache.has(key):
		var idx := PackedInt32Array()
		for y in range(h):
			var dy := absf(float(y) - h * 0.5) / (h * 0.5)
			for x in range(w):
				var dx := absf(float(x) - w * 0.5) / (w * 0.5)
				var v := (dx * dx + dy * dy - 0.55) * 0.3
				if v > 0.02 and Px.bayer(x, y) < v * 2.5:
					idx.append((y * w + x) * 4)
		_vig_cache[key] = idx
	var data := img.get_data()
	var tint := Color(0.05, 0.02, 0.1) * (0.35 * 255.0)
	for i in (_vig_cache[key] as PackedInt32Array):
		data[i] = int(float(data[i]) * 0.65 + tint.r)
		data[i + 1] = int(float(data[i + 1]) * 0.65 + tint.g)
		data[i + 2] = int(float(data[i + 2]) * 0.65 + tint.b)
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)

static func _gy(img: Image) -> int:
	return int(img.get_height() * GROUND_RATIO)


static func _mix_bg(img: Image, x: int, y: int) -> Color:
	return img.get_pixel(clampi(x, 0, img.get_width() - 1), clampi(y, 0, img.get_height() - 1))


static func _clouds(img: Image, t: float, horizon: int) -> void:
	var base := Px.kf(t, "ffc8a0", "d87a98", "46345e")
	var top := Px.kf(t, "fff0d0", "ffb088", "5e4878")
	var under := Px.kf(t, "d8708a", "8a4a82", "2a1e46")
	var w := img.get_width()
	var defs := [[int(w * 0.14), 52, 40], [int(w * 0.40), 34, 48], [int(w * 0.68), 66, 36], [int(w * 0.88), 44, 44], [int(w * 0.27), 96, 28]]
	for d in defs:
		var cx: int = d[0]
		var cy: int = d[1]
		var cw: int = d[2]
		for k in range(5):
			var ox := int((Px.rnd(cx + k) - 0.5) * float(cw))
			var oy := int((Px.rnd(cy + k * 3) - 0.5) * 3.0)
			Px.ellipse(img, cx + ox, cy + oy + 2, int(cw / 3.0) + 2, 3, under)
		for k in range(5):
			var ox2 := int((Px.rnd(cx + k) - 0.5) * float(cw))
			var oy2 := int((Px.rnd(cy + k * 3) - 0.5) * 3.0)
			Px.ellipse(img, cx + ox2, cy + oy2, int(cw / 3.0) + 2, 3, base)
			Px.ellipse(img, cx + ox2 + 1, cy + oy2 - 1, int(cw / 4.0), 1, top)


static func _hills(img: Image, t: float, horizon: int) -> void:
	var w := img.get_width()
	var far := Px.kf(t, "a8607a", "5a3a6e", "1c1438")
	var mid := Px.kf(t, "7a4a6a", "3e2a5a", "140e2a")
	var near := Px.kf(t, "4a3a4a", "2a2044", "0e0a1e")
	for x in range(w):
		var h1 := horizon - 6 - int(6.0 * sin(float(x) * 0.021 + 1.0) + 3.0 * sin(float(x) * 0.07))
		Px.rect(img, x, h1, 1, _gy(img) - h1, far)
		var h2 := horizon + 2 - int(5.0 * sin(float(x) * 0.034 + 3.0) + 2.0 * sin(float(x) * 0.11))
		Px.rect(img, x, h2, 1, _gy(img) - h2, mid)
		var h3 := horizon + 10 - int(3.0 * sin(float(x) * 0.05 + 0.5))
		var rise := int(Px.rnd(x / 5) * 5.0)
		Px.rect(img, x, h3 - rise, 1, _gy(img) - (h3 - rise), near)
	# tiny river glimmer between hills
	for x in range(0, w, 3):
		if Px.rnd(x) > 0.6:
			Px.px(img, x, horizon + 10, Color(1.0, 0.8, 0.6, 0.35 * (1.0 - t)))


static func _ground(img: Image, t: float, gy: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var grass := Px.kf(t, "5a8a3e", "3a5a40", "16241f")
	var grass_lt := Px.kf(t, "8ab852", "587a4a", "223a2c")
	var dirt := Px.kf(t, "8a5a34", "5a3a3a", "20141c")
	var dirt_lt := Px.kf(t, "a87444", "74504a", "2a1c24")
	Px.rect(img, 0, gy, w, 5, grass)
	Px.rect(img, 0, gy, w, 1, grass_lt)
	Px.rect(img, 0, gy + 5, w, h - gy - 5, dirt)
	for x in range(0, w):
		if Px.rnd(x * 2) > 0.55:
			Px.px(img, x, gy + 1 + int(Px.rnd(x) * 3.0), grass_lt)
	for i in range(60):
		var x := int(Px.rnd(i + 100) * float(w))
		var y := gy + 6 + int(Px.rnd(i + 200) * float(h - gy - 7))
		Px.rect(img, x, y, 2 + int(Px.rnd(i) * 3.0), 1, dirt_lt)
	for y in range(gy + 5, h):
		var u := float(y - gy - 5) / float(maxi(1, h - gy - 5))
		for x in range(w):
			if u > 0.6 and Px.bayer(x, y) < (u - 0.6) * 1.2:
				Px.px(img, x, y, Color(0.06, 0.02, 0.08, 0.4))


static func _foreground(img: Image, t: float, gy: int) -> void:
	var w := img.get_width()
	var leaf := Px.kf(t, "3a7a38", "28502f", "0e1c18")
	var leaf_lt := Px.kf(t, "6aa848", "3e6e3e", "162a22")
	for i in range(14):
		var x := int(Px.rnd(i + 300) * float(w))
		var hgt := 4 + int(Px.rnd(i + 400) * 6.0)
		for k in range(3):
			Px.thick(img, float(x), float(gy + 3), float(x + (k - 1) * 3), float(gy + 3 - hgt), 0.6, leaf)
		Px.px(img, x, gy + 3 - hgt, leaf_lt)
	# bamboo fence at both edges
	var bam := Px.kf(t, "a89850", "6a5a4a", "20201c")
	var bam_dk := Px.shade(bam, 0.25)
	for fx in [6, 14, 22, w - 30, w - 22, w - 14, w - 6]:
		var topy := gy - 12 - int(Px.rnd(fx) * 4.0)
		Px.rect(img, fx, topy, 3, gy + 6 - topy, bam)
		Px.rect(img, fx, topy, 1, gy + 6 - topy, bam_dk)
		Px.rect(img, fx, topy, 3, 1, Px.light(bam, 0.2))
		Px.rect(img, fx, topy + 5, 3, 1, bam_dk)
	Px.rect(img, 4, gy - 4, 21, 1, bam_dk)
	Px.rect(img, w - 32, gy - 4, 27, 1, bam_dk)


static func _fireflies(img: Image, t: float) -> void:
	if t < 0.55:
		return
	var a := clampf((t - 0.55) / 0.3, 0.0, 1.0)
	for i in range(9):
		var x := 30 + int(Px.rnd(i + 500) * float(img.get_width() - 60))
		var y := int(img.get_height() * 0.5) + int(Px.rnd(i + 600) * 70.0)
		Px.glow(img, x, y, 4, Color(0.9, 1.0, 0.5, 0.7 * a), 1.0)
		Px.px(img, x, y, Color(1.0, 1.0, 0.7, a))


static func _stilt_house(img: Image, rect: Rect2i, t: float, neighbor: bool) -> void:
	var wood := Px.kf(t, "8a5a3a", "5a3a46", "1e1424")
	var wood_lt := Px.light(wood, 0.12)
	var wood_dk := Px.shade(wood, 0.18)
	var roof := Px.kf(t, "5a3a30", "3a2638", "120c1c")
	var roof_lt := Px.light(roof, 0.14)
	var post := Px.shade(wood, 0.3)
	if neighbor:
		wood = wood.darkened(0.12)
		roof = roof.darkened(0.1)
	var x := rect.position.x
	var y := rect.position.y
	var w := rect.size.x
	var h := rect.size.y
	var gy := _gy(img)
	var glow := 0.25 + t * 0.75
	# shadow
	Px.ellipse(img, x + w / 2, gy + 3, w / 2 + 10, 3, Color(0.05, 0.02, 0.08, 0.3))
	# stilts
	for sx in [x + 6, x + w / 2 - 1, x + w - 9]:
		Px.rect(img, sx, y + h - 2, 3, gy - (y + h) + 4, post)
		Px.rect(img, sx + 2, y + h - 2, 1, gy - (y + h) + 4, Px.light(post, 0.1))
	Px.rect(img, x + 3, y + h + 6, w - 6, 1, post)
	# stairs
	if not neighbor:
		for i in range(5):
			Px.rect(img, x + w / 2 - 8 + i, y + h + 2 + i * 3, 16 - i * 2, 2, wood_lt)
	# walls with plank lines
	Px.rect(img, x, y + 9, w, h - 17, wood)
	for px_ in range(x, x + w, 5):
		Px.rect(img, px_, y + 9, 1, h - 17, wood_dk)
	Px.rect(img, x, y + 9, w, 1, wood_lt)
	Px.rect(img, x + w - 2, y + 9, 2, h - 17, wood_lt)
	# deck
	Px.rect(img, x - 6, y + h - 8, w + 12, 6, wood_lt)
	Px.rect(img, x - 6, y + h - 3, w + 12, 2, wood_dk)
	for i in range(0, w + 10, 8):
		Px.rect(img, x - 5 + i, y + h - 8, 1, 5, wood_dk)
	# railing
	var rail := Px.light(wood, 0.25)
	for i in range(0, w + 8, 6):
		Px.rect(img, x - 4 + i, y + h - 18, 2, 10, rail)
	Px.rect(img, x - 4, y + h - 18, w + 8, 2, Px.light(rail, 0.15))
	# pelita hanging lamp at the eave
	var lamp_x := x + w - 14
	Px.rect(img, lamp_x, y + 9, 1, 6, post)
	Px.ball(img, lamp_x, y + 17, 2, 3, Color(1.0, 0.82, 0.4, 1.0))
	Px.glow(img, lamp_x, y + 17, 20, Color(1.0, 0.75, 0.3, 0.9), glow)
	# windows with warm interior
	var win_y := y + 15
	var win_xs: Array = [x + 8, x + w - 28]
	if w > 200:
		win_xs = [x + 18, x + w / 2 - 54, x + w / 2 + 42, x + w - 32]
	for wx in win_xs:
		if neighbor and wx != x + 8:
			continue
		Px.rect(img, wx - 1, win_y - 1, 14, 12, wood_dk)
		var lit := Px.kf(t, "7aa8b8", "ffc27a", "ffd48a")
		Px.rect(img, wx, win_y, 12, 10, lit)
		Px.rect(img, wx + 5, win_y, 1, 10, wood_dk)
		Px.rect(img, wx, win_y + 4, 12, 1, wood_dk)
		Px.glow(img, wx + 6, win_y + 5, 14, Color(1.0, 0.7, 0.3, 0.6), glow * 0.8)
	# door
	var door_w := 12
	Px.rect(img, x + w / 2 - 6, y + 17, door_w, h - 26, Px.kf(t, "2a1810", "241426", "0a0812"))
	Px.rect(img, x + w / 2 - 6, y + 17, door_w, 1, wood_lt)
	if not neighbor:
		Px.glow(img, x + w / 2, y + h - 12, 16, Color(1.0, 0.7, 0.3, 0.6), glow * 0.6, 0.7)
	# roof: layered thatch/shingle with curved eaves
	for i in range(5):
		var rx := x - 10 + i * 2
		var ry := y + 8 - i * 3
		var rw := w + 20 - i * 4
		var c := roof if i % 2 == 0 else Px.shade(roof, 0.1)
		Px.rect(img, rx, ry, rw, 3, c)
		Px.rect(img, rx, ry, rw, 1, roof_lt)
		for sx in range(rx, rx + rw, 4):
			Px.px(img, sx, ry + 2, Px.shade(roof, 0.25))
	# gable "tanduk" ornament at the roof peak
	Px.thick(img, float(x + w / 2 - 8), float(y - 7), float(x + w / 2 - 12), float(y - 14), 0.6, roof)
	Px.thick(img, float(x + w / 2 + 8), float(y - 7), float(x + w / 2 + 12), float(y - 14), 0.6, roof)
	if neighbor:
		# kitchen window glow and rising smoke
		Px.glow(img, x + w - 12, y + 24, 14, Color(1.0, 0.5, 0.18, 0.9), 0.5 + glow * 0.5)
		for i in range(6):
			var sx2 := x + w - 6 + int(sin(float(i) * 1.3) * 3.0)
			Px.ellipse(img, sx2, y - 4 - i * 6, 3 + i / 2, 2 + i / 3, Color(0.82, 0.78, 0.86, 0.34 - float(i) * 0.04))
		Px.rect(img, x + w - 8, y + 2, 4, 8, wood_dk)


static func _palm(img: Image, bx: int, by: int, scale: float, t: float) -> void:
	var trunk := Px.kf(t, "7a5232", "4a3040", "1a1220")
	var leaf := Px.kf(t, "3e8a40", "2a5a3a", "0e2418")
	var leaf_lt := Px.kf(t, "7ac050", "4a8a4a", "1c3a28")
	var leaf_dk := Px.shade(leaf, 0.25)
	var th := int(54.0 * scale)
	var lean := int(5.0 * scale)
	var tx := bx
	var ty := by
	for i in range(th):
		var u := float(i) / float(th)
		var x := bx + int(float(lean) * u * u)
		var y := by - i
		var wdt := 3 if i < th / 3 else 2
		Px.rect(img, x - wdt / 2, y, wdt, 1, trunk)
		Px.px(img, x + wdt / 2, y, Px.light(trunk, 0.15))
		if i % 4 == 0:
			Px.px(img, x - wdt / 2, y, Px.shade(trunk, 0.25))
		tx = x
		ty = y
	# fronds
	var len := int(26.0 * scale)
	for a in [-165, -140, -112, -80, -50, -20, 10]:
		var rad := deg_to_rad(float(a))
		var px_ := float(tx)
		var py_ := float(ty)
		for s in range(len):
			var u2 := float(s) / float(len)
			px_ = float(tx) + cos(rad) * float(s)
			py_ = float(ty) + sin(rad) * float(s) * 0.55 + u2 * u2 * float(len) * 0.55
			var c := leaf_lt if u2 < 0.5 else leaf
			Px.rect(img, int(px_), int(py_), 2, 1, c)
			if s % 2 == 0:
				Px.px(img, int(px_), int(py_) + 1, leaf_dk)
				Px.px(img, int(px_) + 1, int(py_) - 1, leaf)
	Px.ball(img, tx, ty + 2, 2, 2, Px.shade(trunk, 0.1))
	Px.ball(img, tx + 3, ty + 3, 2, 2, Px.shade(trunk, 0.1))


# ------------------------------------------------------------------ approach scene
static func approach_sky(size: Vector2i) -> ImageTexture:
	var key := "approach:%d:%d" % [size.x, size.y]
	var hit: Variant = _cached(key)
	if hit != null:
		return hit
	return _store(key, Px.tex(_approach_image(size)))


static func _approach_image(size: Vector2i) -> Image:
	var w := size.x
	var h := size.y
	var img := Px.canvas(w, h)
	var horizon := int(h * 0.6)
	var stops: Array = [
		[0.0, Color("6a3e8a")],
		[0.3, Color("d8607a")],
		[0.62, Color("ff9a52")],
		[1.0, Color("ffd88a")],
	]
	Px.sky_bands(img, 0, h, stops, 28)
	var sun_x := int(w * 0.35)
	Px.glow(img, sun_x, horizon - 20, 70, Color(1.0, 0.72, 0.36, 0.7), 1.0)
	Px.ball(img, sun_x, horizon - 20, 20, 20, Color("fff0a8"))
	Px.ellipse(img, sun_x, horizon - 20, 12, 12, Color("fffadc"))
	# cloud streaks
	for i in range(9):
		var cx := 60 + i * 124 + int(Px.rnd(i) * 40.0)
		var cy := 24 + int(Px.rnd(i + 7) * 52.0)
		var cw := 34 + int(Px.rnd(i + 3) * 26.0)
		Px.ellipse(img, cx, cy + 2, cw, 3, Color("c0587a"))
		Px.ellipse(img, cx, cy, cw, 3, Color("f08a8e"))
		Px.ellipse(img, cx + 4, cy - 1, int(cw * 0.6), 1, Color("ffd0a0"))
	# birds
	for b in [[420, 40], [440, 46], [470, 36], [760, 30]]:
		Px.px(img, b[0], b[1], Color("4a2a4a"))
		Px.px(img, b[0] + 1, b[1] - 1, Color("4a2a4a"))
		Px.px(img, b[0] + 2, b[1], Color("4a2a4a"))
		Px.px(img, b[0] + 3, b[1] - 1, Color("4a2a4a"))
		Px.px(img, b[0] + 4, b[1], Color("4a2a4a"))
	# far mountains and treeline (two layers)
	for x in range(w):
		var m := horizon - 10 - int(14.0 * absf(sin(float(x) * 0.008 + 1.0)) + 6.0 * sin(float(x) * 0.03))
		Px.rect(img, x, m, 1, horizon - m + 6, Color("a8607e"))
	for x in range(w):
		var m2 := horizon - 2 - int(7.0 * absf(sin(float(x) * 0.021)) + Px.rnd(x / 3) * 6.0)
		Px.rect(img, x, m2, 1, horizon - m2 + 8, Color("6a3e6a"))
	# near treeline
	for x in range(0, w, 3):
		var th := 10 + int(absf(sin(float(x) * 0.05)) * 14.0) + int(Px.rnd(x) * 6.0)
		var ty := horizon + 6 - th
		Px.ellipse(img, x, ty, 4, 5, Color("2e3a44"))
		Px.ellipse(img, x + 1, ty - 1, 2, 3, Color("3e4a4e"))
	Px.rect(img, 0, horizon + 6, w, 8, Color("2a3440"))
	# river
	var ry := horizon + 14
	for y in range(ry, ry + 22):
		var u := float(y - ry) / 22.0
		for x in range(w):
			var c := Color("ff9a62").lerp(Color("5a4a7e"), u)
			var wave := sin(float(x) * 0.19 + float(y) * 0.9)
			if wave > 0.82:
				c = c.lightened(0.28)
			elif wave < -0.9:
				c = c.darkened(0.15)
			img.set_pixel(x, y, c)
	# sun reflection column
	for y in range(ry, ry + 22):
		var half := 3 + int(float(y - ry) * 0.5)
		for x in range(sun_x - half, sun_x + half):
			if (x + y) % 3 != 0:
				Px.px(img, x, y, Color(1.0, 0.95, 0.65, 0.65))
	# little boats
	for bx in [180, 640, 910]:
		Px.rect(img, bx, ry + 8, 14, 2, Color("3a2430"))
		Px.rect(img, bx + 2, ry + 10, 10, 1, Color("241420"))
		Px.rect(img, bx + 7, ry + 1, 1, 8, Color("3a2430"))
		Px.tri(img, bx + 8, ry + 1, bx + 8, ry + 7, bx + 13, ry + 7, Color("e0a078"))
	# bank
	var bank := ry + 22
	Px.rect(img, 0, bank, w, 6, Color("4a7438"))
	Px.rect(img, 0, bank, w, 1, Color("86b04c"))
	# grass field + path
	var path_y := int(h * 0.78)
	Px.rect(img, 0, bank + 6, w, path_y - bank - 6, Color("5a8a3e"))
	for i in range(220):
		var x := int(Px.rnd(i + 11) * float(w))
		var y := bank + 6 + int(Px.rnd(i + 99) * float(path_y - bank - 8))
		Px.rect(img, x, y, 1, 2, Color("86b84c"))
		Px.px(img, x + 1, y + 1, Color("3e6a30"))
	# flowers
	for i in range(34):
		var x2 := int(Px.rnd(i + 700) * float(w))
		var y2 := bank + 8 + int(Px.rnd(i + 800) * float(path_y - bank - 12))
		var fc := Color("f8e8a0") if i % 3 == 0 else (Color("f09ab8") if i % 3 == 1 else Color("fff4e8"))
		Px.px(img, x2, y2, fc)
	Px.rect(img, 0, path_y - 3, w, 3, Color("4a7a34"))
	Px.rect(img, 0, path_y, w, h - path_y, Color("9a6a3e"))
	Px.rect(img, 0, path_y, w, 2, Color("b88850"))
	for x in range(w):
		if Px.rnd(x * 4) > 0.82:
			Px.px(img, x, path_y + 3 + int(Px.rnd(x) * (h - path_y - 4)), Color("7a4e2c"))
		if Px.rnd(x * 5) > 0.9:
			Px.px(img, x, path_y + 3 + int(Px.rnd(x + 1) * (h - path_y - 4)), Color("c8985c"))
	for x in range(0, w, 17):
		Px.ellipse(img, x + 4, path_y + 10 + int(Px.rnd(x) * 12.0), 3, 1, Color("86582f"))
	# palms
	for p in [[160, 1.4], [520, 1.7], [780, 1.35], [985, 1.55], [330, 1.15], [880, 1.05]]:
		_palm(img, p[0], path_y - 4, p[1], 0.1)
	# foreground grass tufts along the path edge
	for x in range(0, w, 11):
		var th2 := 3 + int(Px.rnd(x) * 4.0)
		for k in range(3):
			Px.line(img, x + k, path_y - 1, x + k - 1 + k, path_y - 1 - th2, Color("6aa83e"))
		Px.px(img, x + 1, path_y - 1 - th2, Color("a4d868"))
	# evening light haze at the bottom
	for y in range(h - 40, h):
		for x in range(w):
			var u3 := float(y - (h - 40)) / 40.0
			if Px.bayer(x, y) < u3 * 0.5:
				Px.px(img, x, y, Color(0.18, 0.08, 0.2, 0.38))
	return img


# ------------------------------------------------------------------ props
static func tree_sprite() -> ImageTexture:
	var hit: Variant = _cached("tree")
	if hit != null:
		return hit
	var img := Px.canvas(72, 160)
	var bark := Color("7a4e30")
	# trunk with taper, roots and shaded sides
	for y in range(52, 154):
		var u := float(y - 52) / 102.0
		var half := 5 + int(u * u * 4.0)
		var cx := 36 + int(sin(float(y) * 0.06) * 1.5)
		for x in range(cx - half, cx + half + 1):
			var c := bark
			if x < cx - half + 3:
				c = Px.shade(bark, 0.25)
			elif x > cx + half - 3:
				c = Px.light(bark, 0.18)
			if (x * 7 + y * 3) % 11 == 0:
				c = Px.shade(c, 0.2)
			Px.px(img, x, y, c)
	for r in [[-9, 0], [9, 0]]:
		Px.tri(img, 36 + r[0], 148, 36 + r[0] * 2, 154, 36 + int(r[0] / 2.0), 154, Px.shade(bark, 0.1))
	# footholds
	for i in range(8):
		Px.rect(img, 27, 70 + i * 10, 5, 2, Color("e0b878"))
		Px.rect(img, 41, 75 + i * 10, 5, 2, Color("e0b878"))
	# branch the kid climbs
	Px.thick(img, 40.0, 70.0, 62.0, 56.0, 2.0, bark)
	# canopy: layered clumps
	var dk := Color("1f5a30")
	var md := Color("2f8a3e")
	var lt := Color("5ab852")
	var hi := Color("9ae070")
	var clumps := [[36, 40, 24, 18], [18, 34, 14, 12], [54, 32, 15, 12], [36, 18, 17, 12], [26, 52, 11, 8], [48, 50, 12, 8]]
	for c in clumps:
		Px.ellipse(img, c[0], c[1], c[2], c[3], dk)
	for c in clumps:
		Px.ellipse(img, c[0] + 1, c[1] - 2, c[2] - 3, c[3] - 3, md)
	for c in clumps:
		Px.ellipse(img, c[0] + 3, c[1] - 4, int((c[2] - 6) * 0.8), int((c[3] - 6) * 0.7), lt)
	for i in range(34):
		var lx := 14 + int(Px.rnd(i + 3) * 44.0)
		var ly := 8 + int(Px.rnd(i + 9) * 44.0)
		if img.get_pixel(lx, ly).a > 0.5:
			Px.rect(img, lx, ly, 2, 1, hi)
	for i in range(26):
		var lx2 := 10 + int(Px.rnd(i + 31) * 52.0)
		var ly2 := 10 + int(Px.rnd(i + 41) * 50.0)
		if img.get_pixel(lx2, ly2).a > 0.5:
			Px.rect(img, lx2, ly2, 2, 2, dk)
	# fruit
	for p in [[22, 40], [50, 28], [38, 46], [30, 24]]:
		Px.ball(img, p[0], p[1], 1, 1, Color("f0a040"))
	Px.rim(img, Color("ffc27a"), 0.3)
	Px.outline(img, Color("1a1a2a"))
	var out := Px.canvas(72, 160)
	Px.ellipse(out, 36, 153, 22, 4, Color(0.05, 0.02, 0.1, 0.32))
	Px.blit(out, img, Vector2i.ZERO)
	return _store("tree", Px.tex(out))


static func house_far() -> ImageTexture:
	var hit: Variant = _cached("house_far")
	if hit != null:
		return hit
	var img := Px.canvas(128, 110)
	var wood := Color("9a6638")
	var wood_lt := Px.light(wood, 0.14)
	var wood_dk := Px.shade(wood, 0.22)
	var dark := Color("4a2a28")
	var roof := Color("6a3a30")
	# stilts + cross brace
	for sx in [26, 62, 98]:
		Px.rect(img, sx, 80, 4, 22, dark)
		Px.rect(img, sx + 3, 80, 1, 22, Px.light(dark, 0.15))
	Px.line(img, 28, 90, 62, 100, dark)
	Px.line(img, 62, 90, 98, 100, dark)
	# stairs
	for i in range(5):
		Px.rect(img, 54 + i, 82 + i * 4, 22 - i * 2, 3, wood if i % 2 == 0 else wood_dk)
		Px.rect(img, 54 + i, 82 + i * 4, 22 - i * 2, 1, wood_lt)
	# deck
	Px.rect(img, 14, 72, 100, 9, wood_lt)
	Px.rect(img, 14, 78, 100, 3, wood_dk)
	for i in range(8):
		Px.rect(img, 18 + i * 12, 72, 1, 7, wood_dk)
	# walls
	Px.rect(img, 22, 34, 84, 39, wood)
	for x in range(22, 106, 6):
		Px.rect(img, x, 34, 1, 39, wood_dk)
	Px.rect(img, 22, 34, 84, 2, wood_lt)
	Px.rect(img, 104, 34, 2, 39, wood_lt)
	# door
	Px.rect(img, 55, 46, 18, 27, Color("2a1820"))
	Px.rect(img, 55, 46, 18, 2, wood_lt)
	Px.glow(img, 64, 66, 20, Color(1.0, 0.7, 0.3, 0.8), 0.7)
	# windows with shutters
	for wx in [30, 82]:
		Px.rect(img, wx - 1, 43, 16, 14, wood_dk)
		Px.rect(img, wx, 44, 14, 12, Color("ffc880"))
		Px.rect(img, wx + 6, 44, 2, 12, wood_dk)
		Px.rect(img, wx, 49, 14, 1, wood_dk)
		Px.glow(img, wx + 7, 50, 14, Color(1.0, 0.7, 0.3, 0.7), 0.7)
	# railing
	for i in range(11):
		Px.rect(img, 18 + i * 9, 62, 2, 11, Color("b88850"))
	Px.rect(img, 18, 62, 92, 2, Color("d8a868"))
	# roof: three tiers + peak ornaments
	for i in range(5):
		var rw := 112 - i * 14
		var rx := 8 + i * 7
		var ry := 32 - i * 7
		Px.rect(img, rx, ry, rw, 8, roof if i % 2 == 0 else Px.shade(roof, 0.12))
		Px.rect(img, rx, ry, rw, 1, Px.light(roof, 0.2))
		for sx in range(rx, rx + rw, 5):
			Px.px(img, sx, ry + 5, Px.shade(roof, 0.3))
			Px.px(img, sx + 2, ry + 3, Px.shade(roof, 0.2))
	Px.thick(img, 40.0, 4.0, 34.0, -6.0 + 6.0, 0.7, roof)
	Px.thick(img, 88.0, 4.0, 94.0, 0.0, 0.7, roof)
	# hanging lamp
	Px.rect(img, 100, 36, 1, 8, dark)
	Px.ball(img, 100, 46, 2, 3, Color("ffd070"))
	Px.glow(img, 100, 46, 14, Color(1.0, 0.75, 0.3, 0.9), 1.0)
	# potted plant + jars on deck
	Px.box(img, 20, 66, 6, 6, Color("b05a3a"))
	Px.ball(img, 23, 62, 4, 4, Color("4a9a44"))
	Px.rim(img, Color("ffc27a"), 0.3)
	Px.outline(img, Color("1a1020"))
	var out := Px.canvas(128, 110)
	Px.ellipse(out, 64, 103, 52, 5, Color(0.05, 0.02, 0.1, 0.3))
	Px.blit(out, img, Vector2i.ZERO)
	return _store("house_far", Px.tex(out))


static func house_neighbor() -> ImageTexture:
	var hit: Variant = _cached("house_neighbor")
	if hit != null:
		return hit
	var img := Px.canvas(96, 90)
	var wood := Color("8a5c3a")
	var wood_dk := Px.shade(wood, 0.22)
	var wood_lt := Px.light(wood, 0.14)
	var dark := Color("4a2a28")
	var roof := Color("5a3434")
	for sx in [16, 44, 72]:
		Px.rect(img, sx, 66, 4, 18, dark)
	Px.rect(img, 10, 60, 74, 8, wood_lt)
	Px.rect(img, 10, 66, 74, 2, wood_dk)
	Px.rect(img, 16, 30, 64, 31, wood)
	for x in range(16, 80, 5):
		Px.rect(img, x, 30, 1, 31, wood_dk)
	Px.rect(img, 16, 30, 64, 2, wood_lt)
	Px.rect(img, 38, 40, 14, 21, Color("2a1820"))
	Px.rect(img, 22, 38, 11, 10, Color("ffc880"))
	Px.rect(img, 27, 38, 1, 10, wood_dk)
	# kitchen window
	Px.rect(img, 62, 38, 14, 12, wood_dk)
	Px.rect(img, 63, 39, 12, 10, Color("ff9a3a"))
	Px.glow(img, 69, 44, 14, Color(1.0, 0.5, 0.18, 0.9), 0.9)
	Px.rect(img, 63, 46, 12, 1, wood_dk)
	# roof
	for i in range(4):
		var rw := 84 - i * 14
		var rx := 6 + i * 7
		var ry := 24 - i * 7
		Px.rect(img, rx, ry, rw, 8, roof if i % 2 == 0 else Px.shade(roof, 0.12))
		Px.rect(img, rx, ry, rw, 1, Px.light(roof, 0.2))
		for sx in range(rx, rx + rw, 5):
			Px.px(img, sx, ry + 5, Px.shade(roof, 0.3))
	Px.rect(img, 66, 8, 6, 12, wood_dk)
	# smoke
	for i in range(6):
		var sx2 := 69 + int(sin(float(i) * 1.2) * 3.0)
		Px.ellipse(img, sx2, 6 - i * 3 + 4, 3 + i / 2, 2, Color(0.82, 0.78, 0.86, 0.5 - float(i) * 0.07))
	Px.rim(img, Color("ffc27a"), 0.3)
	Px.outline(img, Color("1a1020"))
	var out := Px.canvas(96, 90)
	Px.ellipse(out, 48, 85, 40, 4, Color(0.05, 0.02, 0.1, 0.28))
	Px.blit(out, img, Vector2i.ZERO)
	return _store("house_neighbor", Px.tex(out))


static func fence_post() -> ImageTexture:
	var hit: Variant = _cached("fence")
	if hit != null:
		return hit
	var img := Px.canvas(8, 28)
	Px.box(img, 2, 2, 4, 26, Color("a87c48"))
	Px.rect(img, 1, 0, 6, 3, Color("c89a5c"))
	Px.rect(img, 0, 9, 8, 2, Color("8a5e34"))
	Px.rect(img, 0, 17, 8, 2, Color("8a5e34"))
	Px.rect(img, 0, 9, 8, 1, Color("c89a5c"))
	Px.rect(img, 0, 17, 8, 1, Color("c89a5c"))
	Px.outline(img, Color("1a1020"))
	return _store("fence", Px.tex(img))


## Rounded bush used along the approach path (replaces the old flat rectangle).
static func bush_sprite() -> ImageTexture:
	var hit: Variant = _cached("bush")
	if hit != null:
		return hit
	var img := Px.canvas(26, 16)
	Px.ball(img, 7, 10, 6, 5, Color("3a8a3e"))
	Px.ball(img, 18, 10, 6, 5, Color("3a8a3e"))
	Px.ball(img, 13, 7, 8, 6, Color("4a9a44"))
	for p in [[10, 5], [15, 4], [18, 8], [7, 9]]:
		Px.rect(img, p[0], p[1], 2, 1, Color("a0e070"))
	for p in [[12, 9], [16, 10], [9, 11]]:
		Px.px(img, p[0], p[1], Color("f06a5a"))
	Px.outline(img, Color("14201c"))
	return _store("bush", Px.tex(img))
